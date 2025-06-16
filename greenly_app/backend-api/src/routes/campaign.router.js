const express = require('express');
const router = express.Router();
const campaignController = require('../controllers/campaign.controller');
const multer = require('multer');
const { methodNotAllowed } = require('../controllers/errors.controller');
// Multer middleware for handling multipart/form-data
const upload = multer();

module.exports.setup = (app) => {
    app.use('/api/campaign', router);

/**
 * @swagger
 * /api/campaign/create:
 *   post:
 *     summary: Create a campaign and a moment
 *     tags: [campaign]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - title
 *               - description
 *               - start_date
 *               - end_date
 *             properties:
 *               title:
 *                 type: string
 *               description:
 *                 type: string
 *               location:
 *                 type: string
 *               start_date:
 *                 type: string
 *                 format: date
 *               end_date:
 *                 type: string
 *                 format: date
 *               category_id:
 *                 type: integer
 *                 nullable: true
 *     responses:
 *       201:
 *         description: Campaign and moment created
 *       400:
 *         description: Missing required fields
 *       401:
 *         description: Unauthorized
 *       500:
 *         description: Server error
 */
    router.post('/create', upload.none(), campaignController.createCampaign);

    router.all('/:id', methodNotAllowed);

    router.all('/', methodNotAllowed);
};