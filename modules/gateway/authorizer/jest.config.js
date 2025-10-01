export default {
  // Test environment
  testEnvironment: 'node',

  // Transform files
  transform: {
    '^.+\\.js$': 'babel-jest',
  },

  // Test file patterns
  testMatch: ['**/__tests__/**/*.js', '**/?(*.)+(spec|test).js'],

  // Coverage configuration
  collectCoverage: false,
  collectCoverageFrom: [
    'src/**/*.js',
    '!src/**/*.test.js',
    '!src/**/*.spec.js',
  ],
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html'],

  // Setup files
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],

  // Clear mocks between tests
  clearMocks: true,
  restoreMocks: true,
};
