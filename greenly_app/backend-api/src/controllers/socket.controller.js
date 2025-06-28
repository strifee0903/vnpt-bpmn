const socketService = require("../services/socket.service");
const knex = require("../database/knex");

exports.initSocket = (io) => {
  io.on("connection", (socket) => {
    console.log("📡 Socket connected:", socket.id);
    // 🟢 Join room
    socket.on("join_room", (campaign_id) => {
      console.log(`🔗 ${socket.id} joined room_${campaign_id}`);
      socket.join(`room_${campaign_id}`);
    });

    // 📩 Gửi tin nhắn
    // socket.on("send_message", async (data) => {
    //   const { campaign_id, sender_id, content } = data;
    //   if (!campaign_id || !sender_id || !content) return;

    //   //   const exists = await knex("participation")
    //   //     .where({ campaign_id, u_id: sender_id })
    //   //     .first();

    //   //   if (!exists) {
    //   //     return socket.emit("error_message", {
    //   //       error: "Bạn không có quyền gửi tin nhắn vào chiến dịch này.",
    //   //     });
    //   //   }

    //   const newMessage = await socketService.saveMessage({
    //     campaign_id,
    //     sender_id,
    //     content,
    //   });

    //   io.to(`room_${campaign_id}`).emit("new_message", newMessage);
    // });

    socket.on("send_message", async (data) => {
      const {
        campaign_id,
        sender_id,
        content,
        type = "text",
        moment,
        username,
      } = data;
      if (!campaign_id || !sender_id || (type === "text" && !content)) return;

      const newMessage = await socketService.saveMessage({
        campaign_id,
        sender_id,
        content,
        type,
        moment,
        username,
      });

      io.to(`room_${campaign_id}`).emit("new_message", newMessage);
    });

    // 📜 Load lịch sử tin nhắn
    socket.on("load_messages", async (data) => {
      const { campaign_id, user_id } = data;
      if (!campaign_id || !user_id) return;

      //   const exists = await knex("participation")
      //     .where({ campaign_id, u_id: user_id })
      //     .first();

      //   if (!exists) {
      //     return socket.emit("error_message", {
      //       error: "Bạn không có quyền xem tin nhắn của chiến dịch này.",
      //     });
      //   }

      const messages = await socketService.getMessagesByCampaign(campaign_id);
      console.log(`${messages} messages loaded for campaign ${campaign_id}`);
      socket.emit("load_messages_success", messages);
    });

    socket.on("disconnect", () => {
      console.log("❌ Socket disconnected:", socket.id);
    });
  });
};
