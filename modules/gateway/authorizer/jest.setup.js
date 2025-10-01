// Jest setup file for global configurations

// Set up environment variables for tests
process.env.DB_NAME = 'test_db';
process.env.DB_HOST = 'localhost';
process.env.DB_PASSWORD = 'test_password';
process.env.DB_PORT = '5432';
process.env.DB_USER = 'test_user';

// Global test timeout
jest.setTimeout(10000);

// Mock console methods to reduce noise in tests (optional)
// global.console = {
//   ...console,
//   log: jest.fn(),
//   warn: jest.fn(),
//   error: jest.fn(),
// };
