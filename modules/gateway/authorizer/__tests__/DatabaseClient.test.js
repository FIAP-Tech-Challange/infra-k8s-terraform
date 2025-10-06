import {
  describe,
  it,
  expect,
  beforeEach,
  afterEach,
  jest,
} from '@jest/globals';
import { DatabaseClient } from '../src/DatabaseClient.js';

const mockClient = {
  connect: jest.fn(),
  query: jest.fn(),
  end: jest.fn(),
};

jest.mock('pg', () => ({
  Client: jest.fn(() => mockClient),
}));

describe('DatabaseClient', () => {
  let mockPgClient;

  beforeEach(() => {
    mockPgClient = mockClient;

    jest.clearAllMocks();
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  describe('Constructor', () => {
    it('should throw error when called directly', () => {
      expect(() => {
        new DatabaseClient({});
      }).toThrow(
        'DatabaseClient constructor can only be called from initDbClient method'
      );
    });
  });

  describe('initDbClient', () => {
    const validConfig = {
      host: 'localhost',
      port: 5432,
      user: 'test_user',
      password: 'test_password',
      database: 'test_db',
    };

    it('should successfully initialize database client with valid config', async () => {
      mockPgClient.connect.mockResolvedValue();

      const dbClient = await DatabaseClient.initDbClient(validConfig);

      expect(dbClient).toBeInstanceOf(DatabaseClient);
      expect(mockPgClient.connect).toHaveBeenCalledTimes(1);
    });

    it('should throw error when database connection fails', async () => {
      const connectionError = new Error('Connection failed');
      mockPgClient.connect.mockRejectedValue(connectionError);

      await expect(DatabaseClient.initDbClient(validConfig)).rejects.toThrow(
        'DB client initialization failed'
      );

      expect(mockPgClient.connect).toHaveBeenCalledTimes(1);
    });

    it('should create pg.Client with correct config', async () => {
      mockPgClient.connect.mockResolvedValue();
      const pg = require('pg');

      await DatabaseClient.initDbClient(validConfig);

      expect(pg.Client).toHaveBeenCalledWith({
        host: validConfig.host,
        port: validConfig.port,
        user: validConfig.user,
        password: validConfig.password,
        database: validConfig.database,
        ssl: {
          rejectUnauthorized: false,
        },
      });
    });
  });

  describe('query', () => {
    let dbClient;

    beforeEach(async () => {
      mockPgClient.connect.mockResolvedValue();
      dbClient = await DatabaseClient.initDbClient({
        host: 'localhost',
        port: 5432,
        user: 'test_user',
        password: 'test_password',
        database: 'test_db',
      });
    });

    it('should execute query with parameters', async () => {
      const expectedResult = { rows: [{ id: 1, name: 'test' }] };
      mockPgClient.query.mockResolvedValue(expectedResult);

      const result = await dbClient.query('SELECT * FROM users WHERE id = $1', [
        1,
      ]);

      expect(mockPgClient.query).toHaveBeenCalledWith(
        'SELECT * FROM users WHERE id = $1',
        [1]
      );
      expect(result).toEqual(expectedResult);
    });

    it('should execute query without parameters', async () => {
      const expectedResult = { rows: [] };
      mockPgClient.query.mockResolvedValue(expectedResult);

      const result = await dbClient.query('SELECT * FROM users');

      expect(mockPgClient.query).toHaveBeenCalledWith(
        'SELECT * FROM users',
        undefined
      );
      expect(result).toEqual(expectedResult);
    });

    it('should propagate query errors', async () => {
      const queryError = new Error('Query failed');
      mockPgClient.query.mockRejectedValue(queryError);

      await expect(dbClient.query('INVALID SQL')).rejects.toThrow(
        'Query failed'
      );
    });
  });
});
