const app = require("./app");
const pool = require("./config/db");

const PORT = process.env.PORT || 5000;

// Test database connection
pool.connect()
  .then((client) => {
    console.log("✅ Connected to PostgreSQL database!");

    client.release();

    app.listen(PORT, () => {
      console.log(`🚀 Care Flow Backend Server is running on port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error("❌ Database connection failed:");
    console.error(err.message);
  });