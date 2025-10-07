import { TotemInvalidOrNotFound } from './Exception.js';

export const handler = async (event) => {
  try {
    const key = event.headers?.authorization;

    validateToken(key, process.env.AUTHORIZER_KEY);

    return {
      isAuthorized: true,
      context: {},
    };
  } catch (error) {
    if (error instanceof TotemInvalidOrNotFound) {
      return {
        isAuthorized: false,
        context: {
          reason: error.message,
        },
      };
    }

    console.error('Unexpected error during authorization:', error);
    return {
      isAuthorized: false,
      context: {
        reason: 'Internal server error',
      },
    };
  }
};

/**
 * Validates the token format
 * @param {string} token
 * @param {string} validToken
 * @returns {void}
 */
function validateToken(token, validToken) {
  console.log('Validating token format');

  if (!token) {
    console.warn('No token provided');
    throw new TotemInvalidOrNotFound();
  }

  if (typeof token !== 'string') {
    console.warn('Token is not a string');
    throw new TotemInvalidOrNotFound();
  }

  if (token.length === 0) {
    console.warn('Token is an empty string');
    throw new TotemInvalidOrNotFound();
  }

  if (token !== validToken) {
    console.warn('Token is not valid');
    throw new TotemInvalidOrNotFound();
  }

  console.log('Token format is valid');
}
