import {
  describe,
  it,
  expect,
  beforeEach,
  afterEach,
  jest,
} from '@jest/globals';
import { handler } from '../src/index.js';
import { TotemInvalidOrNotFound } from '../src/Exception.js';

describe('Authorizer Handler', () => {
  beforeEach(() => {
    process.env.AUTHORIZER_KEY = 'valid-token-123';

    jest.spyOn(console, 'log').mockImplementation();
    jest.spyOn(console, 'warn').mockImplementation();
    jest.spyOn(console, 'error').mockImplementation();
  });

  afterEach(() => {
    jest.restoreAllMocks();
    delete process.env.AUTHORIZER_KEY;
  });

  describe('Successful authorization', () => {
    it('should authorize valid token', async () => {
      const event = {
        headers: {
          authorization: 'valid-token-123',
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

    it('should reject request with invalid token', async () => {
      const event = {
        headers: {
          authorization: 'invalid-token',
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
  });

  describe('Environment variables', () => {
    it('should use AUTHORIZER_KEY environment variable', async () => {
      process.env.AUTHORIZER_KEY = 'custom-key-123';

      const event = {
        headers: {
          authorization: 'custom-key-123',
        },
      };

      const result = await handler(event);

      expect(result).toEqual({
        isAuthorized: true,
        context: {},
      });
    });

    it('should reject when token does not match AUTHORIZER_KEY', async () => {
      process.env.AUTHORIZER_KEY = 'expected-key';

      const event = {
        headers: {
          authorization: 'wrong-key',
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
});
