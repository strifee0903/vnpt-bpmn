const e = require("express");
const knex = require("../database/knex");
const JSend = require("../jsend");
const { updateProcessID } = require("./library.service");
const { XMLParser, XMLBuilder } = require("fast-xml-parser");
require("dotenv").config();

const createBpmn = async (process) => {
  const { process_id, name, xml_content, type } = process;

  const parser = new XMLParser({
    ignoreAttributes: false,
    attributeNamePrefix: "",
  });
  const json = parser.parse(xml_content);
  console.log(json);

  const definitions = json["bpmn:definitions"];
  const proc = definitions["bpmn:process"];
  if (!proc) throw new Error("Invalid BPMN XML: missing process");

  const stepTypes = [
    "bpmn:startEvent",
    "bpmn:endEvent",
    "bpmn:task",
    "bpmn:userTask",
    "bpmn:subProcess",
    "bpmn:callActivity",
  ];
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

  const flowList = Array.isArray(proc["bpmn:sequenceFlow"])
    ? proc["bpmn:sequenceFlow"]
    : [proc["bpmn:sequenceFlow"]];
  const flows = flowList.map((flow) => ({
    flow_id: flow.id,
    process_id,
    source_ref: flow.sourceRef,
    target_ref: flow.targetRef,
    type: "sequenceFlow",
  }));

  const processData = {
    process_id,
    name,
    xml_content,
    type: type === "dynamic" ? "dynamic" : undefined, // undefined => dùng default trong DB
  };

  // Transaction
  return await knex.transaction(async (trx) => {
    await trx("processes").insert(processData);
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

const getAllProcessesWithDetails = async (type = "static") => {
  const processes = await knex("processes").where({ type });
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
  return process;
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

const getAllProcessesXml = async (type = "static") => {
  const all = await knex("processes").where({ type });

  return all.map((row) => ({
    process_id: row.process_id,
    name: row.name,
    xml_content: row.xml_content,
  }));
};

const updateProcess = async (process_id, name, xml_content, type) => {
  try {
    const process = await knex("processes").where({ process_id }).first();

    if (process) {
      await knex.transaction(async (trx) => {
        // Step 1: Delete flows that reference steps with the given process_id
        await trx("flows")
          .whereIn(
            "source_ref",
            trx("steps").select("step_id").where({ process_id })
          )
          .orWhereIn(
            "target_ref",
            trx("steps").select("step_id").where({ process_id })
          )
          .delete();

        // // Step 2: Delete flows with the given process_id (for completeness)
        // await trx("flows").where({ process_id }).delete();

        // Step 3: Delete steps with the given process_id
        await trx("steps").where({ process_id }).delete();

        // Step 4: Delete the process
        await trx("processes").where({ process_id }).delete();
      });
      // Step 5: Recreate the process with createBpmn
      console.log(`Recreating process ${process_id}...`);
      const oldProcessId = process_id;
      const { process_id: newProcessId } = await createBpmn({
        process_id: oldProcessId,
        name,
        xml_content,
        type,
      });
      await updateProcessID(oldProcessId, newProcessId);
      console.log(`Process ${process_id} updated successfully.`);
    } else {
      await createBpmn({ process_id, name, xml_content, type });

      console.log(`Process ${process_id} created successfully.`);
    }
  } catch (error) {
    console.error(`Error processing process ${process_id}:`, error.message);
    if (error.sqlMessage) {
      console.error("SQL Error:", error.sqlMessage);
    }
    throw error; // Re-throw to let the caller handle it
  }
};

const getProcessDetails = async (process_id) => {
  try {
    const process = await knex("processes").where({ process_id }).first();
    if (!process) throw new Error("Process not found");
    else console.log(`Process ${process_id} found.`);

    const steps = await knex("steps").where({ process_id });
    if (!steps || steps.length === 0) {
      console.warn(`No steps found for process ${process_id}`);
    } else {
      console.log(`Found ${steps.length} steps for process ${process_id}`);
    }

    const flows = await knex("flows").where({ process_id });
    if (!flows || flows.length === 0) {
      console.warn(`No flows found for process ${process_id}`);
    } else {
      console.log(`Found ${flows.length} flows for process ${process_id}`);
    }

    return {
      process_id: process.process_id,
      name: process.name,
      steps: steps || [],
      flows: flows || [],
    };
  } catch (error) {
    console.error(`Error fetching process details for ${process_id}:`, error);
    throw error;
  }
};

module.exports = {
  createBpmn: createBpmn,
  // buildAllProcessesXml: buildAllProcessesXml,
  // buildProcessXml: buildProcessXml,
  getProcessXml: getProcessXml,
  getAllProcessesXml: getAllProcessesXml,

  updateProcess: updateProcess,

  getAllProcessesWithDetails: getAllProcessesWithDetails,
  getProcessDetails: getProcessDetails,
};
