const express = require("express");
const bpmnController = require("../controllers/bpmn.controller");
const router = express.Router();

module.exports.setup = (app) => {
  app.use("/api/v1/bpmn", router);
  router.post("/", bpmnController.postProcess);
};
