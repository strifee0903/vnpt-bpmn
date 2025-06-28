const knex = require("../database/knex"); // giả sử là instance knex

// // Lấy tất cả message của campaign
// exports.getMessagesByCampaign = async (campaignId) => {
//   const rows = await knex("messages as m")
//     .join("users as u", "m.sender_id", "u.u_id")
//     .select(
//       "m.message_id",
//       "m.campaign_id",
//       "m.sender_id",
//       "m.content",
//       "m.created_at"
//     )
//     .where("m.campaign_id", campaignId)
//     .orderBy("m.created_at", "asc");

//   return rows;
// };

exports.getMessagesByCampaign = async (campaignId) => {
  const rows = await knex("messages as m")
    .join("users as u", "m.sender_id", "u.u_id")
    .select(
      "m.message_id",
      "m.campaign_id",
      "m.sender_id",
      "m.content",
      "m.type",
      "m.created_at",
      "u.u_name as username"
    )
    .where("m.campaign_id", campaignId)
    .orderBy("m.created_at", "asc");

  return rows.map((row) => {
    if (row.type === "moment") {
      try {
        row.moment = JSON.parse(row.content); // 👈 content là chuỗi JSON, nên parse
        row.content = "[Moment được chia sẻ]"; // 👈 fallback cho UI
      } catch (err) {
        console.error("❌ JSON parse lỗi:", err);
      }
    }
    return row;
  });
};

// // Lưu 1 message mới
// exports.saveMessage = async ({ campaign_id, sender_id, content }) => {
//   const [message_id] = await knex("messages").insert(
//     {
//       campaign_id,
//       sender_id,
//       content,
//     },
//     ["message_id"]
//   );

//   return {
//     message_id:
//       typeof message_id === "object" ? message_id.message_id : message_id,
//     campaign_id,
//     sender_id,
//     content,
//     created_at: new Date().toISOString(), // hoặc lấy từ DB nếu cần
//   };
// };

exports.saveMessage = async ({
  campaign_id,
  sender_id,
  content,
  type = "text",
  moment,
  username,
}) => {
  const [message_id] = await knex("messages").insert(
    {
      campaign_id,
      sender_id,
      type,
      content: type === "text" ? content : null,
      moment_json: type === "moment" ? JSON.stringify(moment) : null,
    },
    ["message_id"]
  );

  return {
    message_id:
      typeof message_id === "object" ? message_id.message_id : message_id,
    campaign_id,
    sender_id,
    type,
    content,
    moment,
    username: username || null, // nếu có username thì thêm vào
    created_at: new Date().toISOString(),
  };
};
