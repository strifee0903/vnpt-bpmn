require("dotenv").config();
const server = require("./src/socket");

const PORT = process.env.PORT || 3000;
server.listen(PORT, "0.0.0.0", () => {
  // ← Change from app.listen(PORT) to this
  console.log(`Server running on http://0.0.0.0:${PORT}`);
});
