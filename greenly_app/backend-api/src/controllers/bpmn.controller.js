const knex = require("../database/knex");
const JSend = require("../jsend");
const { XMLParser } = require("fast-xml-parser");
const service = require("../services/bpmn.service");

const postProcess = async (req, res, next) => {
  const { process_id, name, xml_content, type } = req.body;
  try {
    if (!process_id || !name || !xml_content) {
      return res
        .status(400)
        .json(JSend.error("Missing required fields: id, name, xml"));
    }

    const process = {
      process_id,
      name,
      xml_content,
      type: type === "dynamic" ? "dynamic" : undefined, // undefined => dùng default trong DB
    };
    const result = await service.createBpmn(process);
    return res.json(JSend.success(result));
  } catch (error) {
    console.error("Failed to create BPMN process", error);
    return res.status(500).json(JSend.error("Internal Server Error"));
  }
};

const getAllProcessesWithDetails = async (req, res) => {
  try {
    const type = req.query.type || "static"; // lấy type từ query
    const processes = await service.getAllProcessesWithDetails(type);
    res.json(JSend.success(processes));
  } catch (error) {
    console.error("Error fetching all processes with details:", error);
    res.status(500).json(JSend.error("Failed to fetch all processes"));
  }
};

const getProcessXml = async (req, res) => {
  const { process_id } = req.params;
  try {
    const process = await service.getProcessXml(process_id);
    // res.type("application/xml").send(xml);
    res.json(JSend.success(process));
  } catch (error) {
    console.error("Error generating BPMN XML:", error);
    res.status(500).json({ error: "Failed to build BPMN XML" });
  }
};
const getAllProcessesXml = async (req, res) => {
  try {
    const type = req.query.type || "static"; // lấy type từ query
    const result = await service.getAllProcessesXml(type); // 👈 truyền type vào

    res.json(JSend.success(result));
  } catch (error) {
    console.error("Error fetching all process XML:", error);
    res.status(500).json(JSend.error("Failed to fetch all process XML"));
  }
};

const updateBpmn = async (req, res) => {
  console.log("Updating BPMN process");
  const { process_id } = req.params;
  const { name, xml_content, type } = req.body;
  try {
    if (!process_id || !name || !xml_content) {
      return res
        .status(400)
        .json(JSend.error("Missing required fields: id, name, xml"));
    }

    const result = await service.updateProcess(
      process_id,
      name,
      xml_content,
      type === "dynamic" ? "dynamic" : undefined
    );
    return res.json(JSend.success(result));
  } catch (error) {
    console.error("Failed to update BPMN process", error);
    return res.status(500).json(JSend.error("Internal Server Error"));
  }
};

const getProcessDetails = async (req, res) => {
  const process_id = req.params.process_id;
  try {
    const process = await service.getProcessDetails(process_id);
    if (!process) {
      return res.status(404).json({ error: "Process not found" }); // Assuming JSend.error is { error: message }
    }
    return res.status(200).json({ data: process }); // Send the process data
  } catch (error) {
    console.error("Error fetching process details:", error);
    return res.status(500).json({ error: "Failed to fetch process details" });
  }
};
module.exports = {
  postProcess: postProcess,
  getProcessXml: getProcessXml,
  getAllProcessesXml: getAllProcessesXml,

  updateBpmn: updateBpmn,

  getAllProcessesWithDetails: getAllProcessesWithDetails,
  getProcessDetails: getProcessDetails,
};
