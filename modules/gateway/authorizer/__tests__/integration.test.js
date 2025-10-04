import {
  describe,
  it,
  expect,
  beforeAll,
  afterAll,
  beforeEach,
  jest,
} from '@jest/globals';
import { handler } from '../src/index.js';

const mockPgClient = {
  connect: jest.fn(),
  query: jest.fn(),
  end: jest.fn(),
};

jest.mock('pg', () => ({
  Client: jest.fn(() => mockPgClient),
}));

describe('Authorizer Integration Tests', () => {
  beforeAll(() => {
    process.env.DB_NAME = 'test_db';
    process.env.DB_HOST = 'localhost';
    process.env.DB_PASSWORD = 'test_password';
    process.env.DB_PORT = '5432';
    process.env.DB_USER = 'test_user';
  });

  beforeEach(() => {
    jest.clearAllMocks();
    mockPgClient.connect.mockResolvedValue();

    jest.spyOn(console, 'log').mockImplementation();
    jest.spyOn(console, 'warn').mockImplementation();
    jest.spyOn(console, 'error').mockImplementation();
  });

  afterAll(() => {
    jest.restoreAllMocks();
  });

  describe('Complete authorization flow', () => {
    it('should successfully authorize valid totem token', async () => {
      // Setup
      const validToken = 'totem-abc-123';
      const event = {
        headers: {
          authorization: validToken,
        },
      };

      const dbResult = {
        rows: [
          {
            id: 'totem-id-456',
            token_access: validToken,
          },
        ],
      };

      mockPgClient.query.mockResolvedValue(dbResult);

      const result = await handler(event);

      expect(result).toEqual({
        isAuthorized: true,
        context: {
          totemId: 'totem-id-456',
        },
      });

      expect(mockPgClient.connect).toHaveBeenCalledTimes(1);
      expect(mockPgClient.query).toHaveBeenCalledWith(
        'SELECT id, token_access from totems WHERE token_access = ?',
        [validToken]
      );
    });

    it('should handle complete flow with invalid token', async () => {
      const invalidToken = 'invalid-token';
      const event = {
        headers: {
          authorization: invalidToken,
        },
      };

      const dbResult = {
        rows: [],
      };

      mockPgClient.query.mockResolvedValue(dbResult);

      const result = await handler(event);

      expect(result).toEqual({
        isAuthorized: false,
        context: {
          reason: 'Totem invalid or not found',
        },
      });

      expect(mockPgClient.connect).toHaveBeenCalledTimes(1);
      expect(mockPgClient.query).toHaveBeenCalledWith(
        'SELECT id, token_access from totems WHERE token_access = ?',
        [invalidToken]
      );
    });

    it('should handle database connection failure', async () => {
      const event = {
        headers: {
          authorization: 'some-token',
        },
      };

      mockPgClient.connect.mockRejectedValue(new Error('Connection failed'));

      const result = await handler(event);

      expect(result).toEqual({
        isAuthorized: false,
        context: {
          reason: 'Internal server error',
        },
      });

      expect(mockPgClient.connect).toHaveBeenCalledTimes(1);
      expect(console.error).toHaveBeenCalledWith(
        'Unexpected error during authorization:',
        expect.any(Error)
      );
    });

    it('should handle query execution failure', async () => {
      const event = {
        headers: {
          authorization: 'some-token',
        },
      };

      mockPgClient.connect.mockResolvedValue();
      mockPgClient.query.mockRejectedValue(new Error('Query execution failed'));

      const result = await handler(event);

      expect(result).toEqual({
        isAuthorized: false,
        context: {
          reason: 'Internal server error',
        },
      });
    });
  });

  describe('Edge cases in integration', () => {
    it('should handle malformed event gracefully', async () => {
      const malformedEvents = [
        null,
        undefined,
        {},
        { headers: null },
        { headers: undefined },
      ];

      for (const event of malformedEvents) {
        const result = await handler(event);

        expect(result.isAuthorized).toBe(false);
        expect(result.context.reason).toBeTruthy();
      }
    });

    it('should handle multiple totems with same token (should return first)', async () => {
      const token = 'duplicate-token';
      const event = {
        headers: {
          authorization: token,
        },
      };

      const dbResult = {
        rows: [
          { id: 'totem-1', token_access: token },
          { id: 'totem-2', token_access: token },
        ],
      };

      mockPgClient.query.mockResolvedValue(dbResult);

      const result = await handler(event);

      expect(result).toEqual({
        isAuthorized: true,
        context: {
          totemId: 'totem-1',
        },
      });
    });

    it('should handle database returning null rows', async () => {
      const event = {
        headers: {
          authorization: 'some-token',
        },
      };

      mockPgClient.query.mockResolvedValue({ rows: null });

      const result = await handler(event);

      expect(result.isAuthorized).toBe(false);
    });
  });
});
