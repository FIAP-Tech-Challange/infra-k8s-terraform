import { DatabaseClient } from './DatabaseClient.js';
import { TotemInvalidOrNotFound } from './Exception.js';

export const handler = async (event) => {
  try {
    const token = event.headers?.authorization;
    console.log('Extracted token:', token);

    validateToken(token);

    const dbClient = await DatabaseClient.initDbClient({
      database: process.env.DB_NAME,
      host: process.env.DB_HOST,
      password: process.env.DB_PASSWORD,
      port: parseInt(process.env.DB_PORT, 10),
      user: process.env.DB_USER,
    });

    const totemId = await verifyTokenWithStoreTotem(token, dbClient);

    return {
      isAuthorized: true,
      context: {
        totemId: totemId,
      },
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
 * @returns {void}
 */
function validateToken(token) {
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
}

/**
 * Verifies the token with StoreTotem service
 * @param {string} token
 * @param {DatabaseClient} dbClient
 * @returns {Promise<id>} Totem ID if valid
 */
async function verifyTokenWithStoreTotem(token, dbClient) {
  try {
    const res = await dbClient.query(
      'SELECT id, token_access from totems WHERE token_access = ?',
      [token]
    );

    if (res.rows.length === 0) {
      console.warn('Totem not found for token');
      throw new TotemInvalidOrNotFound();
    }

    return res.rows[0].id;
  } catch (error) {
    if (error instanceof TotemInvalidOrNotFound) {
      throw error; // Re-throw validation errors
    }
    console.error('Error verifying token with StoreTotem:', error);
    throw new Error('Database Error');
  }
}
