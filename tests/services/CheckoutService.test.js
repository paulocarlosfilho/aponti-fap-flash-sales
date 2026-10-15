"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const CheckoutService_1 = require("../../src/services/CheckoutService");
const redis_1 = require("../../src/config/redis");
const database_1 = require("../../src/config/database");
jest.mock("../../src/config/redis", () => ({
    redis: {
        eval: jest.fn(),
    },
}));
jest.mock("../../src/config/database", () => {
    return {
        AppDataSource: {
            getRepository: jest.fn(),
        },
    };
});
describe("CheckoutService", () => {
    let checkoutService;
    let mockOrderRepository;
    beforeEach(() => {
        checkoutService = new CheckoutService_1.CheckoutService();
        mockOrderRepository = {
            create: jest.fn(),
            save: jest.fn(),
        };
        database_1.AppDataSource.getRepository.mockReturnValue(mockOrderRepository);
        jest.clearAllMocks();
    });
    it("should process checkout successfully when tickets are available", async () => {
        // Mock do redis.eval para retornar 1 (sucesso na subtração)
        redis_1.redis.eval.mockResolvedValue(1);
        mockOrderRepository.create.mockReturnValue({
            id: "mocked-uuid",
            eventId: "event1",
            userId: "user1",
            quantity: 2,
            status: "confirmed",
        });
        const order = await checkoutService.processCheckout("event1", "user1", 2);
        expect(redis_1.redis.eval).toHaveBeenCalledTimes(1);
        expect(mockOrderRepository.create).toHaveBeenCalledWith({
            eventId: "event1",
            userId: "user1",
            quantity: 2,
            status: "confirmed",
        });
        expect(mockOrderRepository.save).toHaveBeenCalledTimes(1);
        expect(order.status).toBe("confirmed");
    });
    it("should throw an error when tickets are sold out or insufficient", async () => {
        // Mock do redis.eval para retornar 0 (falha)
        redis_1.redis.eval.mockResolvedValue(0);
        await expect(checkoutService.processCheckout("event1", "user1", 5))
            .rejects.toThrow("Tickets sold out or insufficient quantity");
        expect(redis_1.redis.eval).toHaveBeenCalledTimes(1);
        expect(mockOrderRepository.create).not.toHaveBeenCalled();
        expect(mockOrderRepository.save).not.toHaveBeenCalled();
    });
});
//# sourceMappingURL=CheckoutService.test.js.map