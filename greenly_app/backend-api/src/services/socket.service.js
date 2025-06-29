const knex = require("../database/knex");

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
      "m.moment_json",
      "m.shared_by",
      "m.shared_by_name",
      "m.original_author_id",
      "m.original_author_name",
      "u.u_name as username"
    )
    .where("m.campaign_id", campaignId)
    .orderBy("m.created_at", "asc");

  return rows.map((row) => {
    const result = { ...row }; // Create a copy to avoid mutating the original
    if (row.type === "moment" && row.moment_json) {
      // No need to parse since it's already an object from JSON column
      result.moment = row.moment_json;
    }
    console.log("❌ result: ", row.message_id, ":");
    return result;
  });
};

exports.saveMessage = async ({
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
}) => {
  try {
    if (moment && typeof moment !== 'string') {
      moment = JSON.stringify(moment);
    }

    // Validate moment data
    if (type === "moment" && moment) {
      if (moment.media && !Array.isArray(moment.media)) {
        console.error("❌ Invalid media format in moment:", moment.media);
        throw new Error("Media must be an array");
      }
      if (moment.media) {
        for (const media of moment.media) {
          if (!media.media_url || typeof media.media_url !== "string" || !media.media_url.trim()) {
            console.error("❌ Invalid media_url in moment:", media);
            throw new Error("Invalid or missing media_url");
          }
        }
      }
    }
    
    console.log("💾 Saving message with data:", moment)

    const insertData = {
      campaign_id,
      sender_id,
      type: moment ? 'moment' : type,
      created_at: new Date(),
    };

    if (type === "text") {
      insertData.content = content;
    } else if (type === "moment" ) {
      // insertData.content = null;
      // Đảm bảo moment_json là chuỗi JSON hợp lệ
      if (moment) {
        if (typeof moment !== 'string') {
          momentJson = JSON.stringify(moment);
        } else {
          momentJson = moment;
        }
        try {
          JSON.parse(momentJson); // Validate JSON
        } catch (e) {
          console.error("❌ Invalid JSON for moment:", moment, "Error:", e);
          throw new Error("Invalid moment data format");
        }
        insertData.moment_json = momentJson;
      } else {
        insertData.moment_json = null;
      }

      if (type === "moment" || (type === "moment" && shared_by)) {
        insertData.shared_by = shared_by;
        insertData.shared_by_name = shared_by_name;
        insertData.original_author_id = original_author_id;
        insertData.original_author_name = original_author_name;
      }


    }

    console.log("📝 Insert data:", insertData);

    const [insertResult] = await knex("messages").insert(insertData, ["message_id"]);

    const message_id = typeof insertResult === "object"
      ? (insertResult.message_id || insertResult)
      : insertResult;

    console.log("✅ Message saved with ID:", message_id);

    const returnMessage = {
      message_id,
      campaign_id,
      sender_id,
      type,
      content: type === "text" ? content : "[Moment được chia sẻ]",
      moment: moment || null,
      username: username || null,
      shared_by: shared_by || null,
      shared_by_name: shared_by_name || null,
      original_author_id: original_author_id || null,
      original_author_name: original_author_name || null,
      created_at: new Date().toISOString(),
    };

    console.log("📤 Returning message:", returnMessage);
    return returnMessage;
  } catch (error) {
    console.error("❌ Error saving message:", error);
    throw error;
  }
};