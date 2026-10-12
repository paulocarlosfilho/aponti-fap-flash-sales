# ======================================================================
# Flash Sales API — Dockerfile multi-stage
#
# Estágios:
#   1) base              -> SO + ferramentas mínimas, reaproveitado pelos demais
#   2) dependencies       -> instala TODAS as deps (p/ compilar)
#   3) build              -> compila TypeScript -> JavaScript (dist/)
#   4) prod-dependencies  -> instala SOMENTE deps de produção (sem devDeps)
#   5) runtime            -> imagem final: só dist/ + node_modules de produção
#
# Build:   docker build -t flash-sales-api:local .
# Run:     docker run -p 3000:3000 --env-file .env flash-sales-api:local
# ======================================================================

ARG NODE_VERSION=22.11.0-alpine3.20


# ----------------------------------------------------------------------
# 1) base — imagem comum a todos os estágios seguintes
# ----------------------------------------------------------------------
FROM node:${NODE_VERSION} AS base

RUN apk add --no-cache dumb-init

RUN addgroup -g 10001 -S appgroup \
  && adduser -u 10001 -S appuser -G appgroup

WORKDIR /usr/src/app

ENV NODE_ENV=production \
    NPM_CONFIG_UPDATE_NOTIFIER=false \
    NPM_CONFIG_FUND=false


# ----------------------------------------------------------------------
# 2) dependencies — todas as deps (incl. devDependencies), só para build
# ----------------------------------------------------------------------
FROM base AS dependencies

ENV NODE_ENV=development

COPY package.json package-lock.json ./

RUN --mount=type=cache,target=/root/.npm,id=npm-cache-dev \
    npm ci --include=dev


# ----------------------------------------------------------------------
# 3) build — compila TypeScript -> JavaScript (gera /dist)
# ----------------------------------------------------------------------
FROM dependencies AS build

COPY tsconfig.json ./
COPY src ./src

RUN npm run build \
  && test -f dist/server.js


# ----------------------------------------------------------------------
# 4) prod-dependencies — só as deps de produção (sem TypeScript, Jest, etc.)
# ----------------------------------------------------------------------
FROM base AS prod-dependencies

ENV NODE_ENV=production

COPY package.json package-lock.json ./

RUN --mount=type=cache,target=/root/.npm,id=npm-cache-prod \
    npm ci --omit=dev


# ----------------------------------------------------------------------
# 5) runtime — imagem final: enxuta, não-root, sem ferramentas de build
# ----------------------------------------------------------------------
FROM base AS runtime

LABEL org.opencontainers.image.title="flash-sales-api" \
      org.opencontainers.image.description="API de checkout/venda de ingressos (flash sale) com Redis + PostgreSQL" \
      org.opencontainers.image.source="https://github.com/paulocarlosfilho/flash-sales"

ENV NODE_ENV=production \
    PORT=3000

COPY --chown=appuser:appgroup --from=prod-dependencies /usr/src/app/node_modules ./node_modules
COPY --chown=appuser:appgroup --from=build /usr/src/app/dist ./dist
COPY --chown=appuser:appgroup package.json ./

USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD node -e "require('http').get('http://127.0.0.1:' + (process.env.PORT || 3000) + '/health', r => process.exit(r.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"

ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/server.js"]