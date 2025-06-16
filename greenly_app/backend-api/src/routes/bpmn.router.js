const express = require("express");
const bpmnController = require("../controllers/bpmn.controller");
const router = express.Router();

module.exports.setup = (app) => {
  app.use("/api/v1/bpmn", router);
  /**
 * @swagger
 * /api/v1/bpmn/process: 
 *  post:
 *    summary: Save a BPMN process
 *    description: Save a new BPMN process with the provided ID, name, and XML content.
 *    requestBody:
 *     required: true
 *     content:
 *       application/json:
 *         schema:
 *          type: object
 *          properties:
 *            process_id:
 *              type: string
 *            name:
 *              type: string
 *            xml_content:
 *              type: string
 *    tags: 
 *      - bpmn
 *    responses: 
 *      '200':
 *        description: Successfully save BPMN process
 *        content: 
 *          application/json:
 *            schema:
 *              type: object
 *              properties:
 *                status:
 *                  type: string
 *                  description: Status of the response
 *                  enum: [success]
 *                data:
 *                  type: object
 *                  properties:
 *                    process:
 *                      type: object  
 *                      properties:  
 *                        process_id:
 *                          type: string
 *                        name:
 *                          type: string
 *                        xml_content:
 *                          type: string
 *      '400':
 *        description: Bad request, missing required fields
 *      '500':
 *        description: Internal server error, failed to create BPMN process
 * 
 */
  router.post("/process", bpmnController.postProcess);
  router.get("/allxml", bpmnController.getAllProcessesXml);
  router.get("/all", bpmnController.getAllProcessesWithDetails);
  router.get("/:process_id", bpmnController.getProcessXml);
 /**
 * @swagger
 * /api/v1/bpmn/{process_id}:
 *   put:
 *     summary: Update a BPMN process
 *     description: Update an existing BPMN process with the provided ID, name, and XML content.
 *     parameters:
 *       - name: process_id
 *         in: path
 *         required: true
 *         description: The ID of the BPMN process to update
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               xml_content:
 *                 type: string
 *     tags: 
 *       - bpmn
 *     responses: 
 *       '200':
 *         description: Successfully save BPMN process
 *         content: 
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   description: Status of the response
 *                   enum: [success]
 *                 data:
 *                   type: object
 *                   properties:
 *                     process:
 *                       type: object  
 *                       properties:  
 *                         process_id:
 *                           type: string
 *                         name:
 *                           type: string
 *                         xml_content:
 *                           type: string
 *       '400':
 *         description: Bad request, missing required fields
 *       '500':
 *         description: Internal server error, failed to create BPMN process 
 */  
  router.put("/:process_id", bpmnController.updateBpmn);

  router.get("/details/:process_id", bpmnController.getProcessDetails);
};
