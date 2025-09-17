const handler = async (event) => {
    try {
        console.log("Authorizer event:", JSON.stringify(event, null, 2));

        const token = event.headers?.authorization;

        console.log("Extracted token:", token);

        if (!token) {
            return {
                isAuthorized: false,
                context: {
                    reason: "No authorization header",
                },
            };
        }

        const userInfo = extractUserInfo(token);

        return {
            isAuthorized: true,
            context: {
                userId: userInfo.sub,
                email: userInfo.email || "",
                roles: JSON.stringify(userInfo.roles || ["user"]),
            },
        };
    } catch (error) {
        console.error("Authorizer error:", error);
        return {
            isAuthorized: false,
            context: {
                reason: "Internal server error",
            },
        };
    }
};

function extractUserInfo(token) {
    try {
        return {
            sub: "user-123",
            email: "user@example.com",
            roles: ["user", "admin"],
        };
    } catch (error) {
        return { sub: "anonymous" };
    }
}

module.exports = { handler };
