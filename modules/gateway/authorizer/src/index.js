import { TotemInvalidOrNotFound } from "./Exception.js";

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

        console.error("Unexpected error during authorization:", error);
        return {
            isAuthorized: false,
            context: {
                reason: "Internal server error",
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
    console.log("Validating token format");

    if (!token) {
        console.warn("No token provided");
        throw new TotemInvalidOrNotFound();
    }

    if (typeof token !== "string") {
        console.warn("Token is not a string");
        throw new TotemInvalidOrNotFound();
    }

    if (token.length === 0) {
        console.warn("Token is an empty string");
        throw new TotemInvalidOrNotFound();
    }

    if (token !== validToken) {
        console.warn("Token is not valid");
        throw new TotemInvalidOrNotFound();
    }

    console.log("Token format is valid");
}

/**
 * Verifies the token with StoreTotem service
 * @param {string} token
 * @param {DatabaseClient} dbClient
 * @returns {Promise<id>} Totem ID if valid
 */
async function verifyTokenWithStoreTotem(token, dbClient) {
    try {
        console.log("Verifying token with StoreTotem:", token);

        const res = await dbClient.query(
            "SELECT id, token_access from totems WHERE token_access = $1",
            [token],
        );

        if (res.rows.length === 0) {
            console.warn("Totem not found for token");
            throw new TotemInvalidOrNotFound();
        }

        return res.rows[0].id;
    } catch (error) {
        if (error instanceof TotemInvalidOrNotFound) {
            throw error; // Re-throw validation errors
        }
        console.error("Error verifying token with StoreTotem:", error);
        throw new Error("Database Error");
    }
}
