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

describe('Authorizer Integration Tests', () => {
  beforeAll(() => {
    process.env.AUTHORIZER_KEY = 'integration-test-key-123';
  });

  beforeEach(() => {
    jest.spyOn(console, 'log').mockImplementation();
    jest.spyOn(console, 'warn').mockImplementation();
    jest.spyOn(console, 'error').mockImplementation();
  });

  afterAll(() => {
    jest.restoreAllMocks();
    delete process.env.AUTHORIZER_KEY;
  });

  describe('Complete authorization flow', () => {
    it('should successfully authorize valid token', async () => {
      const validToken = 'integration-test-key-123';
      const event = {
        headers: {
          authorization: validToken,
        },
      };

      const result = await handler(event);

      expect(result).toEqual({
        isAuthorized: true,
        context: {},
      });

      expect(console.log).toHaveBeenCalledWith('Validating token format');
      expect(console.log).toHaveBeenCalledWith('Token format is valid');
    });

    it('should handle complete flow with invalid token', async () => {
      const invalidToken = 'invalid-token';
      const event = {
        headers: {
          authorization: invalidToken,
        },
      };

      const result = await handler(event);

      expect(result).toEqual({
        isAuthorized: false,
        context: {
          reason: 'Totem invalid or not found',
        },
      });

      expect(console.warn).toHaveBeenCalledWith('Token is not valid');
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

    it('should handle different AUTHORIZER_KEY values', async () => {
      process.env.AUTHORIZER_KEY = 'dynamic-key-456';

      const event = {
        headers: {
          authorization: 'dynamic-key-456',
        },
      };

      const result = await handler(event);

      expect(result.isAuthorized).toBe(true);
      expect(result.context).toEqual({});
    });

    it('should handle missing AUTHORIZER_KEY environment variable', async () => {
      delete process.env.AUTHORIZER_KEY;

      const event = {
        headers: {
          authorization: 'any-token',
        },
      };

      const result = await handler(event);

      expect(result.isAuthorized).toBe(false);
      expect(result.context.reason).toBe('Totem invalid or not found');
    });
  });
});
