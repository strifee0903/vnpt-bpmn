const knex = require("../database/knex");
const JSend = require("../jsend");
const { createBpmn } = require("../services/bpmn.service");

const postProcess = async (req, res, next) => {
  const { process_id, name, xml_content } = req.body;
  try {
    if (!process_id || !name || !xml_content) {
      return res
        .status(400)
        .json(JSend.error("Missing required fields: id, name, xml"));
    }
    // Assuming 'processes' is the table where BPMN processes are stored
    const process = {
      process_id,
      name,
      xml_content,
    };
    const result = await createBpmn(process);
    return res.json(JSend.success(result));
  } catch (error) {
    console.error("Failed to create BPMN process", error);
    return res.status(500).json(JSend.error("Internal Server Error"));
  }
};

module.exports = {
  postProcess: postProcess,
};
