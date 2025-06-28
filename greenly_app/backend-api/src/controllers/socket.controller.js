// const socketService = require("../services/socket.service");
// const knex = require("../database/knex");

// exports.initSocket = (io) => {
//   io.on("connection", (socket) => {
//     console.log("📡 Socket connected:", socket.id);
//     // 🟢 Join room
//     socket.on("join_room", (campaign_id) => {
//       console.log(`🔗 ${socket.id} joined room_${campaign_id}`);
//       socket.join(`room_${campaign_id}`);
//     });
//     socket.on("leave_room", (campaign_id) => {
//       console.log(`🚪 ${socket.id} left room ${campaign_id}`);
//       socket.leave(campaign_id.toString());
//     });
//     // // 📩 Gửi tin nhắn
//     // socket.on("send_message", async (data) => {
//     //   const {
//     //     campaign_id,
//     //     sender_id,
//     //     content,
//     //     type = "text",
//     //     moment,
//     //     username,
//     //   } = data;
//     //   if (!campaign_id || !sender_id || (type === "text" && !content)) return;

//     //   const newMessage = await socketService.saveMessage({
//     //     campaign_id,
//     //     sender_id,
//     //     content,
//     //     type,
//     //     moment,
//     //     username,
//     //   });

//     //   io.to(`room_${campaign_id}`).emit("new_message", newMessage);
//     // });

//     socket.on("send_message", async (data) => {
//       const {
//         campaign_id,
//         sender_id,
//         content,
//         type = "text",
//         moment,
//         username,
//         shared_by,
//         shared_by_name,
//         original_author_id,
//         original_author_name,
//       } = data;
//       if (!campaign_id || !sender_id || (type === "text" && !content)) return;

//       try {
//         const newMessage = await socketService.saveMessage({
//           campaign_id,
//           sender_id,
//           content,
//           type,
//           moment,
//           username,
//           shared_by,
//           shared_by_name,
//           original_author_id,
//           original_author_name,
//         });
//         io.to(`room_${campaign_id}`).emit("new_message", newMessage);
//       } catch (error) {
//         socket.emit("error_message", { error: "Failed to save message: " + error.message });
//       }
//     });

//     // 📜 Load lịch sử tin nhắn
//     socket.on("load_messages", async (data) => {
//       const { campaign_id, user_id } = data;
//       if (!campaign_id || !user_id) return;

//       //   const exists = await knex("participation")
//       //     .where({ campaign_id, u_id: user_id })
//       //     .first();

//       //   if (!exists) {
//       //     return socket.emit("error_message", {
//       //       error: "Bạn không có quyền xem tin nhắn của chiến dịch này.",
//       //     });
//       //   }

//       const messages = await socketService.getMessagesByCampaign(campaign_id);
//       console.log(`${messages} messages loaded for campaign ${campaign_id}`);
//       socket.emit("load_messages_success", messages);
//     });

//     socket.on("disconnect", () => {
//       console.log("❌ Socket disconnected:", socket.id);
//     });
//   });
// };

const socketService = require("../services/socket.service");
const knex = require("../database/knex");

exports.initSocket = (io) => {
  io.on("connection", (socket) => {
    console.log("📡 Socket connected:", socket.id);

    // Join room
    socket.on("join_room", (campaign_id) => {
      console.log(`🔗 ${socket.id} joined room_${campaign_id}`);
      socket.join(`room_${campaign_id}`);
    });

    socket.on("leave_room", (campaign_id) => {
      console.log(`🚪 ${socket.id} left room ${campaign_id}`);
      socket.leave(`room_${campaign_id}`);
    });

    // Send message
    socket.on("send_message", async (data) => {
      console.log("📨 Received send_message:", data);

      const {
        campaign_id,
        sender_id,
        content,
        type = "text",
        moment,
        username,
        shared_by,
        shared_by_name,
        original_author_id,
        original_author_name,
      } = data;

      // Validation
      if (!campaign_id || !sender_id) {
        console.log("❌ Missing required fields: campaign_id or sender_id");
        return socket.emit("error_message", {
          error: "Missing required fields: campaign_id or sender_id"
        });
      }

      if (type === "text" && !content) {
        console.log("❌ Missing content for text message");
        return socket.emit("error_message", {
          error: "Content is required for text messages"
        });
      }

      if ((type === "moment" || type === "moment") && !moment) {
        console.log("❌ Missing moment data for moment message");
        return socket.emit("error_message", {
          error: "Moment data is required for moment messages"
        });
      }

      try {
        console.log("💾 Attempting to save message...");

        const newMessage = await socketService.saveMessage({
          campaign_id,
          sender_id,
          content,
          type,
          moment,
          username,
          shared_by,
          shared_by_name,
          original_author_id,
          original_author_name,
        });

        console.log("✅ Message saved successfully, broadcasting to room:", `room_${campaign_id}`);

        // Broadcast to all users in the room
        io.to(`room_${campaign_id}`).emit("new_message", newMessage);

        console.log("📡 Message broadcasted successfully");

      } catch (error) {
        console.error("❌ Error in send_message:", error);
        socket.emit("error_message", {
          error: "Failed to save message: " + error.message
        });
      }
    });

    // Load message history
    socket.on("load_messages", async (data) => {
      console.log("📜 Loading messages for:", data);

      const { campaign_id, user_id } = data;
      if (!campaign_id || !user_id) {
        return socket.emit("error_message", {
          error: "Missing campaign_id or user_id"
        });
      }

      try {
        const messages = await socketService.getMessagesByCampaign(campaign_id);
        console.log(`📨 Loaded ${messages.length} messages for campaign ${campaign_id}`);
        socket.emit("load_messages_success", messages);
      } catch (error) {
        console.error("❌ Error loading messages:", error);
        socket.emit("error_message", {
          error: "Failed to load messages: " + error.message
        });
      }
    });

    socket.on("disconnect", () => {
      console.log("❌ Socket disconnected:", socket.id);
    });
  });
};    