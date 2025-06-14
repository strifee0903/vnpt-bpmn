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

    /**
     * @swagger
     * /api/moment/user/{u_id}/public:
     *   get:
     *     summary: Get public moments of a user
     *     description: Retrieve all public moments created by a specific user.
     *     tags:
     *       - moment
     *     parameters:
     *       - in: path
     *         name: u_id
     *         required: true
     *         schema:
     *           type: integer
     *           description: User ID to fetch public moments for
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
    router.get('/user/:u_id/public', momentController.getPublicMomentsOfUser);

    /**
     * @swagger
     * /api/moment/feed:
     *   get:
     *     summary: Get public moments for news feed
     *     description: Returns all public moments (with pagination) to display on the news feed.
     *     tags:
     *       - moment
     *     parameters:
     *       - in: query
     *         name: page
     *         schema:
     *           type: integer
     *         required: false
     *         description: Page number (default = 1)
     *       - in: query
     *         name: limit
     *         schema:
     *           type: integer
     *         required: false
     *         description: Number of items per page (default = 10)
     *     responses:
     *       200:
     *         description: Public moments retrieved
     *       500:
     *         description: Internal server error
     */
    router.get('/feed', momentController.getNewsFeed);

    /**
     * @swagger
     * /api/moment/me:
     *   get:
     *     summary: Get all moments of the logged-in user
     *     description: Returns all moments (public + private) created by the currently logged-in user.
     *     tags:
     *       - moment
     *     parameters:
     *       - in: query
     *         name: page
     *         schema:
     *           type: integer
     *         required: false
     *         description: Page number (default = 1)
     *       - in: query
     *         name: limit
     *         schema:
     *           type: integer
     *         required: false
     *         description: Items per page (default = 10)
     *     responses:
     *       200:
     *         description: User's moments retrieved
     *       401:
     *         description: Unauthorized - user not logged in
     *       500:
     *         description: Server error
     */
    router.get('/me', momentController.getMyMoments);

};
