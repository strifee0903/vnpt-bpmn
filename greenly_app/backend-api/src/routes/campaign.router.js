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
     *         multipart/form-data:
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

    /**
     * @swagger
     * /api/campaign/all:
     *   get:
     *     summary: Get all campaigns
     *     parameters:
     *       - $ref: '#/components/parameters/limitParam'
     *       - $ref: '#/components/parameters/pageParam'
     *     tags: [campaign]
     *     responses:
     *       200:
     *         description: Successfully retrieved campaigns
     *         metadata:
     *           $ref: '#/components/schemas/PaginationMetadata'
     *       400:
     *         description: Invalid request, missing or invalid fields
     *       404:
     *         description: Not Found
     *       500:
     *         description: Internal server error
     */
    router.get('/all', campaignController.getAllCampaigns);

    /**
     * @swagger
     * /api/campaign/{campaign_id}:
     *   get:
     *     summary: Get campaign by ID
     *     tags: [campaign]
     *     parameters:
     *       - in: path
     *         name: campaign_id
     *         required: true
     *         schema:
     *           type: integer
     *         description: ID of the campaign to retrieve
     *     responses:
     *       200:
     *         description: Campaign detail
     *       404:
     *         description: Campaign not found
     *       500:
     *         description: Server error
     */
    router.get('/:campaign_id', campaignController.getCampaignById);

    /**
     * @swagger
     * /api/campaign/{campaign_id}/join:
     *   post:
     *     summary: Join a campaign
     *     tags: [campaign-participation]
     *     parameters:
     *       - in: path
     *         name: campaign_id
     *         required: true
     *         schema: { type: integer }
     *     responses:
     *       200: { description: Joined successfully }
     *       401: { description: Unauthorized }
     */
    router.post('/:campaign_id/join', campaignController.joinCampaign);

    /**
     * @swagger
     * /api/campaign/{campaign_id}/leave:
     *   post:
     *     summary: Leave a campaign
     *     tags: [campaign-participation]
     *     parameters:
     *       - in: path
     *         name: campaign_id
     *         required: true
     *         schema: { type: integer }
     *     responses:
     *       200: { description: Left campaign }
     *       401: { description: Unauthorized }
     */
    router.post('/:campaign_id/leave', campaignController.leaveCampaign);

    /**
     * @swagger
     * /api/campaign/{campaign_id}/participants:
     *   get:
     *     summary: Get participants of a campaign with pagination
     *     tags: [campaign-participation]
     *     parameters:
     *       - in: path
     *         name: campaign_id
     *         required: true
     *         schema: { type: integer }
     *       - $ref: '#/components/parameters/limitParam'
     *       - $ref: '#/components/parameters/pageParam'
     *     responses:
     *       200:
     *         description: List of participants with pagination metadata
     *         content:
     *           application/json:
     *             schema:
     *               type: object
     *               properties:
     *                 participants:
     *                   type: array
     *                   items:
     *                     $ref: '#/components/schemas/User'
     *                 metadata:
     *                   $ref: '#/components/schemas/PaginationMetadata'
     *       404:
     *         description: Campaign not found
     *       500:
     *         description: Server error
     */
    router.get('/:campaign_id/participants', campaignController.getParticipants);

    router.all('/:id', methodNotAllowed);

    router.all('/', methodNotAllowed);
};