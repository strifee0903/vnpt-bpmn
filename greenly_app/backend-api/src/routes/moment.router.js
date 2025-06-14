const express = require("express");
const router = express.Router();
const momentController = require('../controllers/moment.controller');
const { methodNotAllowed } = require('../controllers/errors.controller');
const { momentUpload } = require('../middlewares/img-upload.middleware'); 

module.exports.setup = (app) => {
    app.use('/api/moment', router);
/**
 * @swagger
 * /api/moment/new:
 *   post:
 *     summary: Create a new moment (post)
 *     description: Logged-in users can create moments with optional media files (images/videos).
 *     tags:
 *       - moment
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - category_id
 *               - moment_content
 *             properties:
 *               category_id:
 *                 type: integer
 *                 example: 1
 *               moment_content:
 *                 type: string
 *                 example: "This is my travel moment!"
 *               moment_address:
 *                 type: string
 *                 example: "Hanoi, Vietnam"
 *               latitude:
 *                 type: number
 *                 example: 21.0285
 *               longitude:
 *                 type: number
 *                 example: 105.8542
 *               moment_type:
 *                 type: string
 *                 enum: [diary, event, report]
 *                 example: "diary"
 *               is_public:
 *                 type: boolean
 *                 example: true
 *               images:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *                 description: Upload multiple image files
 *     responses:
 *       201:
 *         description: Moment created successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: success
 *                 data:
 *                   type: object
 *                   properties:
 *                     moment:
 *                       type: object
 *                       properties:
 *                         moment_id:
 *                           type: integer
 *                         moment_content:
 *                           type: string
 *                         media:
 *                           type: array
 *                           items:
 *                             type: string
 *                             example: /public/uploads/moments/example.jpg
 *       401:
 *         description: Unauthorized - User not logged in
 *       500:
 *         description: Internal Server Error
 */
    router.post('/new', momentUpload, momentController.createMoment);

};
