const express = require("express");

const app = express();

// Middleware
app.use(express.json());

// Test Route
app.get("/", (req, res) => {
    res.send("Welcome to the Care Flow Backend API!");
});

module.exports = app;