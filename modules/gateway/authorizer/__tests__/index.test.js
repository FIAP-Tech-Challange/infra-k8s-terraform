import {
  describe,
  it,
  expect,
  beforeEach,
  afterEach,
  jest,
} from '@jest/globals';
import { handler } from '../src/index.js';
import { DatabaseClient } from '../src/DatabaseClient.js';
import { TotemInvalidOrNotFound } from '../src/Exception.js';

jest.mock('../src/DatabaseClient.js', () => ({
  DatabaseClient: {
    initDbClient: jest.fn(),
  },
}));

describe('Authorizer Handler', () => {
  let mockDbClient;

  beforeEach(() => {
    process.env.DB_NAME = 'test_db';
    process.env.DB_HOST = 'localhost';
    process.env.DB_PASSWORD = 'test_password';
    process.env.DB_PORT = '5432';
    process.env.DB_USER = 'test_user';

    mockDbClient = {
      query: jest.fn(),
    };

    DatabaseClient.initDbClient.mockResolvedValue(mockDbClient);

    jest.spyOn(console, 'log').mockImplementation();
    jest.spyOn(console, 'warn').mockImplementation();
    jest.spyOn(console, 'error').mockImplementation();
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  describe('Successful authorization', () => {
    it('should authorize valid token and return totem ID', async () => {
      const event = {
        headers: {
          authorization: 'valid-token-123',
        },
      };

      const mockDbResult = {
        rows: [{ id: 'totem-123', token_access: 'valid-token-123' }],
      };

      mockDbClient.query.mockResolvedValue(mockDbResult);

      const result = await handler(event);

      expect(result).toEqual({
        isAuthorized: true,
        context: {
          totemId: 'totem-123',
        },
      });

      expect(DatabaseClient.initDbClient).toHaveBeenCalledWith({
        database: 'test_db',
        host: 'localhost',
        password: 'test_password',
        port: 5432,
        user: 'test_user',
      });

      expect(mockDbClient.query).toHaveBeenCalledWith(
        'SELECT id, token_access from totems WHERE token_access = $1',
        ['valid-token-123']
      );
    });
  });

  describe('Token validation', () => {
    it('should reject request with no token', async () => {
      const event = {
        headers: {},
      };

      const result = await handler(event);

      expect(result).toEqual({
        isAuthorized: false,
        context: {
          reason: 'Totem invalid or not found',
        },
      });

      expect(console.warn).toHaveBeenCalledWith('No token provided');
    });

    it('should reject request with null authorization header', async () => {
      const event = {
        headers: {
          authorization: null,
        },
      };

      const result = await handler(event);

      expect(result).toEqual({
        isAuthorized: false,
        context: {
          reason: 'Totem invalid or not found',
        },
      });
    });

    it('should reject request with undefined authorization header', async () => {
      const event = {
        headers: {
          authorization: undefined,
        },
      };

      const result = await handler(event);

      expect(result).toEqual({
        isAuthorized: false,
        context: {
          reason: 'Totem invalid or not found',
        },
      });
    });

    it('should reject request with non-string token', async () => {
      const event = {
        headers: {
          authorization: 123,
        },
      };

      const result = await handler(event);

      expect(result).toEqual({
        isAuthorized: false,
        context: {
          reason: 'Totem invalid or not found',
        },
      });

      expect(console.warn).toHaveBeenCalledWith('Token is not a string');
    });

    it('should reject request with empty string token', async () => {
      const event = {
        headers: {
          authorization: '',
        },
      };

      const result = await handler(event);

      expect(result).toEqual({
        isAuthorized: false,
        context: {
          reason: 'Totem invalid or not found',
        },
      });

      expect(console.warn).toHaveBeenCalledWith('No token provided');
    });
  });

  describe('Token verification with database', () => {
    const validEvent = {
      headers: {
        authorization: 'valid-token-123',
      },
    };

    it('should reject token not found in database', async () => {
      const mockDbResult = {
        rows: [],
      };

      mockDbClient.query.mockResolvedValue(mockDbResult);

      const result = await handler(validEvent);

      expect(result).toEqual({
        isAuthorized: false,
        context: {
          reason: 'Totem invalid or not found',
        },
      });

      expect(console.warn).toHaveBeenCalledWith('Totem not found for token');
    });

    it('should handle database errors gracefully', async () => {
      mockDbClient.query.mockRejectedValue(
        new Error('Database connection failed')
      );

      const result = await handler(validEvent);

      expect(result).toEqual({
        isAuthorized: false,
        context: {
          reason: 'Internal server error',
        },
      });

      expect(console.error).toHaveBeenCalledWith(
        'Unexpected error during authorization:',
        expect.any(Error)
      );
    });

    it('should handle database client initialization errors', async () => {
      DatabaseClient.initDbClient.mockRejectedValue(
        new Error('DB init failed')
      );

      const result = await handler(validEvent);

      expect(result).toEqual({
        isAuthorized: false,
        context: {
          reason: 'Internal server error',
        },
      });
    });
  });

  describe('Event structure handling', () => {
    it('should handle event with no headers', async () => {
      const event = {};

      const result = await handler(event);

      expect(result).toEqual({
        isAuthorized: false,
        context: {
          reason: 'Totem invalid or not found',
        },
      });
    });

    it('should handle null event', async () => {
      const result = await handler(null);

      expect(result).toEqual({
        isAuthorized: false,
        context: {
          reason: 'Internal server error',
        },
      });
    });

    it('should extract token correctly from headers', async () => {
      const event = {
        headers: {
          authorization: 'test-token',
          'content-type': 'application/json',
        },
      };

      mockDbClient.query.mockResolvedValue({ rows: [] });

      await handler(event);

      expect(console.log).toHaveBeenCalledWith(
        'Extracted token:',
        'test-token'
      );
    });
  });

  describe('Environment variables', () => {
    it('should use correct environment variables for database connection', async () => {
      process.env.DB_NAME = 'prod_db';
      process.env.DB_HOST = 'prod.example.com';
      process.env.DB_PASSWORD = 'prod_password';
      process.env.DB_PORT = '3306';
      process.env.DB_USER = 'prod_user';

      const event = {
        headers: {
          authorization: 'valid-token',
        },
      };

      mockDbClient.query.mockResolvedValue({ rows: [{ id: '1' }] });

      await handler(event);

      expect(DatabaseClient.initDbClient).toHaveBeenCalledWith({
        database: 'prod_db',
        host: 'prod.example.com',
        password: 'prod_password',
        port: 3306,
        user: 'prod_user',
      });
    });

    it('should handle invalid DB_PORT environment variable', async () => {
      process.env.DB_PORT = 'invalid-port';

      const event = {
        headers: {
          authorization: 'valid-token',
        },
      };

      await handler(event);

      expect(DatabaseClient.initDbClient).toHaveBeenCalledWith({
        database: 'test_db',
        host: 'localhost',
        password: 'test_password',
        port: NaN,
        user: 'test_user',
      });
    });
  });
});
