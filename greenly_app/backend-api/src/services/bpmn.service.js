const knex = require("../database/knex");
const JSend = require("../jsend");
const { XMLParser, XMLBuilder } = require("fast-xml-parser");
require("dotenv").config();

const createBpmn = async (process) => {
  const { process_id, name, xml_content } = process;

  const parser = new XMLParser({ ignoreAttributes: false, attributeNamePrefix: "" });
  const json = parser.parse(xml_content);

  const definitions = json["bpmn:definitions"];
  const proc = definitions["bpmn:process"];
  if (!proc) throw new Error("Invalid BPMN XML: missing process");

  const stepTypes = ["bpmn:startEvent", "bpmn:endEvent", "bpmn:task", "bpmn:exclusiveGateway"];
  const steps = [];

  for (const type of stepTypes) {
    const items = proc[type];
    if (!items) continue;

    const list = Array.isArray(items) ? items : [items];
    for (const el of list) {
      steps.push({
        step_id: el.id,
        process_id,
        name: el.name || null,
        type: type.replace("bpmn:", ""),
      });
    }
  }

  const flowList = Array.isArray(proc["bpmn:sequenceFlow"]) ? proc["bpmn:sequenceFlow"] : [proc["bpmn:sequenceFlow"]];
  const flows = flowList.map(flow => ({
    flow_id: flow.id,
    process_id,
    source_ref: flow.sourceRef,
    target_ref: flow.targetRef,
    type: "sequenceFlow",
  }));

  // Transaction
  return await knex.transaction(async trx => {
    await trx("processes").insert({ process_id, name, xml_content });
    if (steps.length > 0) await trx("steps").insert(steps);
    if (flows.length > 0) await trx("flows").insert(flows);

    return {
      process_id,
      steps_count: steps.length,
      flows_count: flows.length,
    };
  });
};

// const buildAllProcessesXml = async () => {
//   const processes = await knex("processes");

//   const result = [];
//   for (const proc of processes) {
//     const steps = await knex("steps").where({ process_id: proc.process_id });
//     const flows = await knex("flows").where({ process_id: proc.process_id });

//     const xml = buildXmlFromParts(proc, steps, flows);
//     result.push({
//       process_id: proc.process_id,
//       name: proc.name,
//       xml,
//     });
//   }

//   return result;
// };

// const buildXmlFromParts = (process, steps, flows) => {
//   const bpmnProcess = {
//     "@_id": process.process_id,
//     "@_isExecutable": "true",
//     ...buildStepElements(steps),
//     "bpmn:sequenceFlow": flows.map(flow => ({
//       "@_id": flow.flow_id,
//       "@_sourceRef": flow.source_ref,
//       "@_targetRef": flow.target_ref,
//     })),
//   };

//   const json = {
//     "bpmn:definitions": {
//       "@_xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
//       "@_xmlns:bpmn": "http://www.omg.org/spec/BPMN/20100524/MODEL",
//       "@_xmlns:bpmndi": "http://www.omg.org/spec/BPMN/20100524/DI",
//       "@_xmlns:dc": "http://www.omg.org/spec/DD/20100524/DC",
//       "@_xmlns:di": "http://www.omg.org/spec/DD/20100524/DI",
//       "@_targetNamespace": "http://bpmn.io/schema/bpmn",
//       "bpmn:process": bpmnProcess,
//     },
//   };

//   const builder = new XMLBuilder({
//     ignoreAttributes: false,
//     format: true,
//     suppressEmptyNode: true,
//     attributeNamePrefix: "@_",
//   });

//   return builder.build(json);
// };
// const buildProcessXml = async (process_id) => {
//   const process = await knex("processes").where({ process_id }).first();
//   if (!process) throw new Error("Process not found");

//   // const steps = await knex("steps").where({ process_id });
//   // const flows = await knex("flows").where({ process_id });

//   // const bpmnProcess = {
//   //   "@_id": process.process_id,
//   //   "@_isExecutable": "true",
//   //   ...buildStepElements(steps),
//   //   "bpmn:sequenceFlow": flows.map(flow => ({
//   //     "@_id": flow.flow_id,
//   //     "@_sourceRef": flow.source_ref,
//   //     "@_targetRef": flow.target_ref,
//   //   })),
//   // };

//   // const json = {
//   //   "bpmn:definitions": {
//   //     "@_xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
//   //     "@_xmlns:bpmn": "http://www.omg.org/spec/BPMN/20100524/MODEL",
//   //     "@_xmlns:bpmndi": "http://www.omg.org/spec/BPMN/20100524/DI",
//   //     "@_xmlns:dc": "http://www.omg.org/spec/DD/20100524/DC",
//   //     "@_xmlns:di": "http://www.omg.org/spec/DD/20100524/DI",
//   //     "@_targetNamespace": "http://bpmn.io/schema/bpmn",
//   //     "bpmn:process": bpmnProcess,
//   //   },
//   // };

//   // const builder = new XMLBuilder({
//   //   ignoreAttributes: false,
//   //   format: true,
//   //   suppressEmptyNode: true,
//   //   attributeNamePrefix: "@_",
//   // });

//   return process.build(json);
// };

const getAllProcessesWithDetails = async () => {
  const processes = await knex("processes");
  const result = [];

  for (const proc of processes) {
    const [steps, flows] = await Promise.all([
      knex("steps").where({ process_id: proc.process_id }),
      knex("flows").where({ process_id: proc.process_id }),
    ]);

    result.push({
      process_id: proc.process_id,
      name: proc.name,
      steps,
      flows,
    });
  }

  return result;
};


const getProcessXml = async (process_id) => {
  const process = await knex("processes").where({ process_id }).first();
  if (!process) throw new Error("Process not found");
  return process
};


// const buildStepElements = (steps) => {
//   const elements = {};
//   for (const step of steps) {
//     const tag = `bpmn:${step.type}`;
//     if (!elements[tag]) elements[tag] = [];

//     elements[tag].push({
//       "@_id": step.step_id,
//       ...(step.name ? { "@_name": step.name } : {}),
//     });
//   }
//   return elements;
// };

const getAllProcessesXml = async (req, res) => {
  const all = await knex("processes");
  // const allXml = all.map(row => row.xml_content).join("\n");

  return all.map(row => {
    return {
      process_id: row.process_id,
      name: row.name,
      xml_content: row.xml_content,
    };
  });
};

module.exports = {
  createBpmn: createBpmn,
  // buildAllProcessesXml: buildAllProcessesXml,
  // buildProcessXml: buildProcessXml,
  getProcessXml: getProcessXml,
  getAllProcessesXml: getAllProcessesXml,
  getAllProcessesWithDetails: getAllProcessesWithDetails,
};
