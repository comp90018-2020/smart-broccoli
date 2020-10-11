module.exports = {
    env: {
        browser: true,
        es6: true,
        node: true,
    },
    parser: "@typescript-eslint/parser",
    parserOptions: {
        sourceType: "module",
    },
    plugins: ["@typescript-eslint"],
    rules: {
        "@typescript-eslint/member-delimiter-style": [
            "error",
            {
                multiline: {
                    delimiter: "semi",
                    requireLast: true,
                },
                singleline: {
                    delimiter: "semi",
                    requireLast: false,
                },
            },
        ],
        "@typescript-eslint/prefer-namespace-keyword": "error",
        "@typescript-eslint/quotes": [
            "error",
            "double",
            {
                avoidEscape: true,
            },
        ],
        semi: ["error", "always"],
        "@typescript-eslint/type-annotation-spacing": "error",
        "brace-style": ["error", "1tbs"],
        "no-trailing-spaces": "error",
        "no-var": "error",
        "prefer-const": "error",
        "spaced-comment": [
            "error",
            "always",
            {
                markers: ["/"],
            },
        ],
    },
};
