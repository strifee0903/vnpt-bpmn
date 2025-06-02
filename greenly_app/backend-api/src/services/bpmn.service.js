const knex = require("../database/knex");
const JSend = require("../jsend");
const { XMLParser } = require("fast-xml-parser");
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

module.exports = {
  createBpmn: createBpmn,
};
