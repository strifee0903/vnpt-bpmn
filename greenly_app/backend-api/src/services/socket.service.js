const knex = require("../database/knex"); // giả sử là instance knex

// Lấy tất cả message của campaign
exports.getMessagesByCampaign = async (campaignId) => {
  const rows = await knex("messages as m")
    .join("users as u", "m.sender_id", "u.u_id")
    .select(
      "m.message_id",
      "m.campaign_id",
      "m.sender_id",
      "m.content",
      "m.created_at"
    )
    .where("m.campaign_id", campaignId)
    .orderBy("m.created_at", "asc");

  return rows;
};

// Lưu 1 message mới
exports.saveMessage = async ({ campaign_id, sender_id, content }) => {
  const [message_id] = await knex("messages").insert(
    {
      campaign_id,
      sender_id,
      content,
    },
    ["message_id"]
  );

  return {
    message_id:
      typeof message_id === "object" ? message_id.message_id : message_id,
    campaign_id,
    sender_id,
    content,
    created_at: new Date().toISOString(), // hoặc lấy từ DB nếu cần
  };
};
