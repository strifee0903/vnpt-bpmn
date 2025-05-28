const knex = require("../database/knex");
const JSend = require("../jsend");
require("dotenv").config();

const createBpmn = async (process) => {
  try {
    const result = await knex("processes").insert(process);
    return result[0];
  } catch (error) {
    console.error("Error creating BPMN process:", error);
    throw new Error("Failed to create BPMN process");
  }
};

module.exports = {
  createBpmn: createBpmn,
};
