const knex = require("../database/knex");
const JSend = require("../jsend");
const { XMLParser } = require("fast-xml-parser");
const service = require("../services/bpmn.service");

const postProcess = async (req, res, next) => {
    const { process_id, name, xml_content } = req.body;
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
        };
        const result = await service.createBpmn(process);
        return res.json(JSend.success(result));
    } catch (error) {
        console.error("Failed to create BPMN process", error);
        return res.status(500).json(JSend.error("Internal Server Error"));
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
        const result = await service.getAllProcessesXml();
        // res.json(result); // hoặc res.send(result) nếu muốn raw XML
        res.json(JSend.success(result));
    } catch (error) {
        console.error("Error fetching all process XML:", error);
        res.status(500).json({ error: "Failed to fetch all process XML" });
    }
};


module.exports = {
    postProcess: postProcess,
    getProcessXml: getProcessXml,
    getAllProcessesXml: getAllProcessesXml,
};
