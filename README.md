# 🚀 Aponti FAP — Flash Sales API

API de alta performance desenvolvida para o processamento de vendas relâmpago (Flash Sales), utilizando Node.js, TypeScript e Express. O projeto foi estruturado com foco em escalabilidade, resiliência, automação de infraestrutura e boas práticas de DevSecOps.

A solução integra Redis para cache, PostgreSQL para persistência de dados, Prometheus e Grafana para observabilidade, Terraform para Infraestrutura como Código (IaC) e Kubernetes para orquestração de containers.

### 📑 Sumário
- Visão Geral
- Tecnologias Utilizadas
- Arquitetura da Solução
- Estrutura do Projeto
- Pré-requisitos
- Execução com Docker Compose
- Testes Automatizados
- Infraestrutura com Terraform
- Deploy no Kubernetes
- Monitoramento e Observabilidade
- Endpoints da API
- Considerações de Segurança

### 🎯 Visão Geral
O Aponti FAP Flash Sales API foi projetado para demonstrar uma arquitetura modular capaz de atender cenários de alta demanda, especialmente durante picos de acesso provocados por campanhas promocionais e vendas relâmpago.

### Principais funcionalidades e características
API REST: implementação de endpoints HTTP com Node.js, TypeScript e Express.
Cache de alta velocidade: utilização do Redis para operações que exigem baixa latência.
Persistência relacional: armazenamento de pedidos no PostgreSQL.
Escalabilidade horizontal: configuração de réplicas e autoscaling com Kubernetes HPA.
Observabilidade: coleta de métricas com Prometheus e visualização em dashboards Grafana.
Infraestrutura como Código: definição declarativa de recursos com Terraform.
Automação de CI/CD: estrutura preparada para pipelines com GitHub Actions.
Testes automatizados: utilização do Jest para validar as regras de negócio.

### 🛠️ Tecnologias Utilizadas
Tecnologia	Finalidade
Node.js	Ambiente de execução da aplicação
TypeScript	Tipagem estática e organização do código
Express	Framework para construção da API REST
PostgreSQL	Banco de dados relacional
Redis	Cache e suporte a operações de baixa latência
Docker	Containerização da aplicação
Docker Compose	Orquestração do ambiente local
Kubernetes	Orquestração e escalabilidade dos containers
Terraform	Provisionamento de infraestrutura como código
Prometheus	Coleta e consulta de métricas
Grafana	Visualização de métricas e dashboards
Jest	Testes automatizados
GitHub Actions	Automação de CI/CD

### 🏗️ Arquitetura da Solução

A aplicação utiliza uma arquitetura modular dividida em camadas, buscando separar as responsabilidades de roteamento, controle das requisições, regras de negócio, persistência e infraestrutura.

Visão arquitetural

```bash
                         ┌──────────────────────┐
                         │   Cliente / HTTP      │
                         └──────────┬───────────┘
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │ Kubernetes Service   │
                         │     api-service      │
                         └──────────┬───────────┘
                                    │
                    ┌───────────────┴──────────────┐
                    ▼                              ▼
          ┌──────────────────┐           ┌──────────────────┐
          │    API Pod 1     │           │    API Pod 2     │
          │ Node.js/Express  │           │ Node.js/Express  │
          └────────┬─────────┘           └────────┬─────────┘
                   │                              │
                   └──────────────┬───────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    ▼                           ▼
          ┌──────────────────┐        ┌──────────────────┐
          │    PostgreSQL    │        │      Redis       │
          │ Persistência     │        │ Cache            │
          └──────────────────┘        └──────────────────┘

                    ┌─────────────────────────────┐
                    │       Observabilidade        │
                    │                             │
                    │ Prometheus ──► Grafana       │
                    └─────────────────────────────┘
```

### Componentes da arquitetura

API Layer — Node.js, TypeScript e Express

Responsável por receber as requisições HTTP, encaminhá-las aos controladores e executar as regras de negócio por meio da camada de serviços.

### Camada de serviços — Business Logic

Concentra as regras de processamento de pedidos e exportação de dados, mantendo a lógica de negócio desacoplada das rotas HTTP.

### Persistência — PostgreSQL

Armazena os dados relacionais dos pedidos, utilizando a entidade Order para representar as informações da aplicação.

### Cache — Redis

Disponibiliza uma camada de acesso rápido a dados, podendo ser utilizada no gerenciamento de estoque e em operações críticas de vendas.

### Orquestração — Kubernetes

Gerencia os containers, disponibiliza serviços internos e permite configurar escalabilidade horizontal por meio do Horizontal Pod Autoscaler (HPA).

### Observabilidade — Prometheus e Grafana

O Prometheus coleta métricas expostas pela aplicação, enquanto o Grafana apresenta os dados em dashboards para acompanhamento operacional.

### Infraestrutura — Terraform

Define recursos de infraestrutura por meio de arquivos declarativos, facilitando a reprodução e o gerenciamento dos ambientes.

Nota: o diagrama representa a arquitetura lógica planejada. A implementação efetiva de cada fluxo, incluindo controle concorrente de estoque e integração entre os componentes, depende do código e das configurações implantadas.

### 📁 Estrutura do Projeto
```bash
aponti-fap-flash-sales/
├── .github/
│   └── workflows/                     # Pipelines de CI/CD
│
├── k8s/
│   ├── api.yaml                       # Deployment e Service da API
│   ├── configmap.yaml                 # Configurações não sensíveis
│   ├── hpa.yaml                       # Autoscaling horizontal
│   ├── persistence.yaml               # Volumes persistentes
│   ├── postgres.yaml                  # Recursos do PostgreSQL
│   ├── redis.yaml                     # Recursos do Redis
│   └── secret.yaml                    # Referências a dados sensíveis
│
├── monitoring/
│   ├── grafana/
│   │   ├── dashboards/
│   │   │   └── api-fap-contratos-dashboard.json
│   │   └── provisioning/              # Provisionamento de dashboards
│   │
│   └── prometheus/
│       └── prometheus.yml             # Configuração de scraping
│
├── src/
│   ├── config/
│   │   ├── database.ts                # Conexão com PostgreSQL
│   │   └── redis.ts                   # Conexão com Redis
│   │
│   ├── controllers/
│   │   ├── CheckoutController.ts      # Controlador de checkout
│   │   └── ExportController.ts        # Controlador de exportação
│   │
│   ├── entities/
│   │   └── Order.ts                   # Entidade de pedido
│   │
│   ├── middlewares/
│   │   ├── errorHandler.ts            # Tratamento centralizado de erros
│   │   └── metricsMiddleware.ts       # Instrumentação de métricas
│   │
│   ├── routes/
│   │   └── index.ts                   # Definição das rotas
│   │
│   ├── services/
│   │   ├── CheckoutService.ts         # Regras de checkout
│   │   └── ExportService.ts           # Regras de exportação
│   │
│   ├── app.ts                         # Configuração do Express
│   └── server.ts                      # Inicialização do servidor
│
├── terraform/
│   ├── compute.tf                     # Recursos computacionais
│   ├── network.tf                     # Rede, VPC e sub-redes
│   ├── outputs.tf                     # Saídas da infraestrutura
│   ├── provider.tf                    # Provedores
│   ├── storage.tf                     # Recursos de armazenamento
│   └── variables.tf                   # Variáveis de configuração
│
├── tests/
│   └── services/
│       └── CheckoutService.test.ts    # Testes do serviço de checkout
│
├── .dockerignore
├── .gitignore
├── docker-compose.yml
├── Dockerfile
├── jest.config.js
├── package.json
├── tsconfig.json
└── README.md
```
A árvore acima organiza os arquivos informados. O diretório .github/workflows/ deve existir no repositório para que os arquivos de workflow do GitHub Actions sejam reconhecidos automaticamente.

### 📋 Pré-requisitos
Antes de executar o projeto, verifique se as ferramentas necessárias estão instaladas.

Node.js e npm.
Docker e Docker Compose.
Terraform, para os testes de IaC.
kubectl e um cluster Kubernetes, para o deploy.
Acesso a um registry de imagens, caso a aplicação seja publicada em um ambiente Kubernetes remoto.
As ferramentas Terraform e Kubernetes são necessárias apenas para as respectivas etapas.

### 🐳 Execução com Docker Compose
O Docker Compose permite executar a aplicação e seus serviços auxiliares em um ambiente local.

1. Construir as imagens e iniciar os serviços
Na raiz do projeto, execute:

docker compose up -d --build

2. Verificar o estado dos containers

docker compose ps

Para acompanhar os logs:

docker compose logs -f

Para consultar apenas os logs da API:

docker compose logs -f api

O nome api deve corresponder ao nome do serviço definido no arquivo docker-compose.yml.

3. Testar o endpoint de métricas

curl -i http://localhost:8080/metrics

Se a aplicação estiver configurada para expor métricas nessa porta e nesse caminho, a resposta deverá apresentar os dados disponibilizados para o Prometheus.

4. Encerrar o ambiente

docker compose down

Para remover também os volumes declarados no Compose:

docker compose down -v

Atenção: o parâmetro -v pode excluir dados persistidos nos volumes, incluindo dados locais do 

PostgreSQL. Utilize-o somente quando desejar realmente remover esses dados.

### 🧪 Testes Automatizados
O projeto utiliza Jest para executar testes das camadas de serviço.

1. Instalar as dependências

npm install

2. Executar os testes

npm test

3. Executar em modo watch

npm run test:watch

O modo watch permite reexecutar os testes conforme os arquivos são alterados.

### Cobertura de testes
O arquivo de teste informado na estrutura do projeto é:

```bash
tests/
└── services/
    └── CheckoutService.test.ts
```
Para verificar a cobertura, consulte os scripts definidos no package.json. Caso ainda não exista um script específico, você pode configurar o Jest para gerar relatórios de cobertura.


### ☁️ Infraestrutura como Código com Terraform
Os arquivos Terraform descrevem os recursos de infraestrutura necessários para o ambiente de implantação.

1. Acessar o diretório
cd terraform

2. Inicializar o Terraform
terraform init

3. Validar a configuração
terraform validate

4. Visualizar o plano de execução
terraform plan

5. Aplicar as alterações
Em um ambiente controlado, após revisar o plano:

terraform apply

6. Remover os recursos

Quando necessário, após verificar os impactos:

terraform destroy

Importante: os recursos provisionados dependem dos provedores, das variáveis e das configurações definidas nos arquivos .tf. Configure as credenciais do provedor e revise o plano antes de aplicar ou destruir recursos. Evite utilizar -auto-approve em ambientes produtivos sem controles adicionais.

### ☸️ Deploy no Kubernetes
Esta seção apresenta o fluxo básico para publicar a API em um cluster Kubernetes.

1. Preparar a imagem Docker
Na raiz do projeto, construa a imagem:

docker build -t aponti-fap-flash-sales:latest .

Adicione a tag do registry:

docker tag aponti-fap-flash-sales:latest \
  paulocarlosfilho/aponti-fap-flash-sales:latest

Publique a imagem:

docker push paulocarlosfilho/aponti-fap-flash-sales:latest

Antes do envio, autentique-se no registry, se necessário, e confirme que o nome da imagem corresponde ao configurado no Deployment.

2. Aplicar os manifestos
Na raiz do projeto:

kubectl apply -f ./k8s/

3. Verificar os recursos
Listar os recursos:

kubectl get all

Verificar os Pods:

kubectl get pods

Verificar os Services:

kubectl get services

Verificar o Horizontal Pod Autoscaler:

kubectl get hpa

4. Acompanhar a implantação da API

kubectl rollout status deployment/api-deployment

Se a implantação apresentar problemas, consulte os detalhes:

kubectl describe deployment api-deployment

kubectl logs deployment/api-deployment

5. Encaminhar a porta para o ambiente local
Execute:

kubectl port-forward service/api-service 8080:80

Mantenha esse comando em execução e utilize outro terminal para realizar as requisições.

6. Testar a API
Health check

curl -i http://localhost:8080/health

Checkout

curl -i -X POST http://localhost:8080/api/checkout \
  -H "Content-Type: application/json" \
  -d '{
    "product_id": "item-123",
    "quantity": 1
  }'

O resultado esperado depende das validações, das regras de negócio e do formato de resposta implementados na aplicação.

Certifique-se de que o endpoint /health, a rota /api/checkout e os nomes dos recursos Kubernetes correspondam aos definidos no código e nos manifestos.

### 📊 Monitoramento e Observabilidade
O projeto contempla Prometheus para coleta de métricas e Grafana para visualização dos indicadores da aplicação.

### Endereços locais

- Serviço	Endereço
API	http://localhost:8080
Métricas da API	http://localhost:8080/metrics
Prometheus	http://localhost:9090
Grafana	http://localhost:3000

Os endereços acima pressupõem que os serviços estejam publicados nessas portas pelo Docker Compose ou por encaminhamento de portas.

### Prometheus
Arquivo de configuração:

monitoring/prometheus/prometheus.yml

O Prometheus deve estar configurado para realizar o scraping do endpoint de métricas da aplicação.

### Grafana
Os arquivos de provisionamento e dashboards ficam no diretório:

monitoring/grafana/

Dashboard informado no projeto:

dashboards/api-fap-contratos-dashboard.json

A importação automática depende da configuração de provisionamento e da disponibilidade da fonte de dados Prometheus.

### 🔌 Endpoints da API
Com base nos comandos de teste apresentados, os seguintes endpoints são utilizados:

Método	Endpoint	Finalidade
GET	/health	Verificação de disponibilidade
GET	/metrics	Exposição de métricas para monitoramento
POST	/api/checkout	Processamento de checkout
Exemplo de requisição de checkout
Endpoint: POST /api/checkout

Content-Type: application/json

{
  "product_id": "item-123",
  "quantity": 1
}

Os endpoints acima foram documentados com base nos exemplos de execução fornecidos. Consulte os arquivos de rotas e controladores para confirmar os métodos HTTP, os contratos de resposta e as demais rotas disponíveis.

### 🔐 Considerações de Segurança
Como o projeto possui foco em DevSecOps, recomenda-se observar as seguintes práticas:

Gerenciamento de segredos: não versionar senhas, tokens ou credenciais reais no Git.
Kubernetes Secrets: utilizar mecanismos adequados de proteção e gerenciamento de segredos; a existência de um objeto Secret não garante, por si só, criptografia em repouso ou controle de acesso suficiente.
Terraform: evitar armazenar credenciais diretamente nos arquivos .tf e proteger o estado da infraestrutura, que pode conter informações sensíveis.
Imagens Docker: utilizar imagens confiáveis, versões controladas e builds reproduzíveis.
CI/CD: incorporar verificações de dependências, análise estática e varredura de vulnerabilidades.
API: validar os dados de entrada, limitar requisições conforme o risco e tratar erros sem expor informações internas.
Banco de dados: utilizar credenciais com privilégios mínimos e conexões protegidas quando aplicável.
Checkout e estoque: garantir consistência transacional e proteção contra concorrência para evitar vendas acima do estoque disponível.
Monitoramento: evitar expor publicamente endpoints administrativos, métricas sensíveis ou interfaces de monitoramento sem autenticação e controles de rede apropriados.

### 📌 Considerações Finais
O Aponti FAP Flash Sales API reúne tecnologias utilizadas no desenvolvimento de APIs modernas e na construção de ambientes automatizados e observáveis.

A integração entre Node.js, TypeScript, PostgreSQL, Redis, Docker, Kubernetes, Terraform, Prometheus e Grafana oferece uma base para explorar escalabilidade, automação, monitoramento e práticas de DevSecOps.

A configuração final e o comportamento de cada componente devem ser validados conforme os arquivos efetivamente implementados no repositório.

Desenvolvido como projeto de estudo e aplicação prática de conceitos de desenvolvimento backend, infraestrutura como código, containerização, orquestração e observabilidade.

O que eu melhorei
Organização: criei um sumário navegável e seções em uma ordem lógica, da arquitetura até a execução.

Leitura técnica: separei os comandos por etapa, facilitando a reprodução do ambiente.

Apresentação visual: padronizei títulos, tabelas, diagramas e blocos de código.

Precisão: sinalizei os pontos que dependem das configurações reais do projeto, sem assumir que funcionalidades estão implementadas só porque aparecem na documentação.

Segurança: acrescentei cuidados com credenciais, volumes persistentes, Terraform e estoque concorrente.

GitHub: deixei a documentação em Markdown, pronta para ser colocada na raiz do repositório.