import pg from "pg";

export class DatabaseClient {
    #client;

    /**
     * Private constructor to prevent direct instantiation
     * @param {pg.Client} client
     * @throws {Error} if not called from initDbClient method
     * @private
     */
    constructor(client) {
        if (new.target === DatabaseClient) {
            const stack = new Error().stack;
            if (!stack.includes("initDbClient")) {
                throw new Error(
                    "DatabaseClient constructor can only be called from initDbClient method",
                );
            }
        }

        this.#client = client;
    }

    /**
     * Initializes and returns a PostgreSQL client
     * @param {Object} config
     * @param {string} config.host
     * @param {number} config.port
     * @param {string} config.user
     * @param {string} config.password
     * @param {string} config.database
     * @returns {Promise<DatabaseClient>}
     */
    static async initDbClient(config) {
        try {
            const client = new pg.Client({
                host: config.host,
                port: config.port,
                user: config.user,
                password: config.password,
                database: config.database,
            });
            await client.connect();

            return new DatabaseClient(client);
        } catch (error) {
            console.error("Error initializing DB client:", error);
            throw new Error("DB client initialization failed");
        }
    }

    /**
     * Executes a query on the database
     * @param {string} text
     * @param {Array} params
     * @returns {Promise<pg.QueryResult>}
     */
    async query(text, params) {
        return this.#client.query(text, params);
    }
}
