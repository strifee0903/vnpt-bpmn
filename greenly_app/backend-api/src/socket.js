const http = require("http");
const socketIO = require("socket.io");
const app = require("./app");
const { initSocket } = require("./controllers/socket.controller");

const server = http.createServer(app);
const io = socketIO(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
  },
});

initSocket(io);

module.exports = server;
