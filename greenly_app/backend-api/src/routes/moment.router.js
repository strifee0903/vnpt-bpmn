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
 *                             example: /public/uploads/example.jpg
 *       401:
 *         description: Unauthorized - User not logged in
 *       500:
 *         description: Internal Server Error
 */
    router.post('/new', momentUpload, momentController.createMoment);

    /**
     * @swagger
     * /api/moment/public/user/{u_id}:
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
     *                             example: /public/uploads/example.jpg
     *       401:
     *         description: Unauthorized - User not logged in
     *       500:
     *         description: Internal Server Error
     */
    router.get('/public/user/:u_id', momentController.getPublicMomentsOfUser);

    /**
     * @swagger
     * /api/moment/public/feed:
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
     *       - in: query
     *         name: moment_type
     *         schema:
     *           type: string
     *           enum: [diary, event, report]
     *         required: false
     *         description: Filter by moment type
     *     responses:
     *       200:
     *         description: Public moments retrieved
     *       500:
     *         description: Internal server error
     */
    router.get('/public/feed', momentController.getNewsFeed);

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
     *       - in: query
     *         name: is_public
     *         schema:
     *           type: boolean
     *         required: false
     *         description: Filter by visibility. true = public, false = private. If omitted, returns all.
     *     responses:
     *       200:
     *         description: User's moments retrieved
     *       401:
     *         description: Unauthorized - user not logged in
     *       500:
     *         description: Server error
     */
    router.get('/me', momentController.getMyMoments);

    /**
     * @swagger
     * /api/moment/public/{moment_id}:
     *   get:
     *     summary: Get detail of a specific moment
     *     description: View full detail of a moment, including media, author and category.
     *     tags:
     *       - moment
     *     parameters:
     *       - in: path
     *         name: moment_id
     *         schema:
     *           type: integer
     *         required: true
     *         description: ID of the moment to retrieve
     *     responses:
     *       200:
     *         description: Moment detail retrieved
     *       403:
     *         description: Access denied to private moment
     *       404:
     *         description: Moment not found
     *       500:
     *         description: Server error
     */
    router.get('/public/:moment_id', momentController.getMomentDetailById);

    /**
     * @swagger
     * /api/moment/me/update/{moment_id}:
     *   patch:
     *     summary: Update a moment (owner only)
     *     description: Only the owner can update their moment post. Use GET /api/moment/public/{moment_id} to pre-fill the edit form.
     *     tags:
     *       - moment
     *     parameters:
     *       - in: path
     *         name: moment_id
     *         required: true
     *         schema:
     *           type: integer
     *     requestBody:
     *       content:
     *         multipart/form-data:
     *           schema:
     *             type: object
     *             properties:
     *               moment_content:
     *                 type: string
     *                 example: "Updated moment content"
     *               moment_type:
     *                 type: string
     *                 enum: [diary, event, report]
     *                 example: "diary"
     *               is_public:
     *                 type: boolean
     *                 example: true
     *               category_id:
     *                 type: integer
     *                 example: 1
     *               moment_address:
     *                 type: string
     *                 example: "New address"
     *               latitude:
     *                 type: number
     *                 example: 21.0285
     *               longitude:
     *                 type: number
     *                 example: 105.8542
     *               media_ids_to_delete:
     *                 type: array
     *                 items:
     *                   type: integer
     *                 example: [1, 2, 3]
     *                 description: Array of media_id values to delete from this moment
     *               images:
     *                 type: array
     *                 items:
     *                   type: string
     *                   format: binary
     *                 description: New images to upload
     *     responses:
     *       200:
     *         description: Moment updated successfully
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
     *                     message:
     *                       type: string
     *                       example: "Moment updated successfully!"
     *                     moment:
     *                       type: object
     *                       properties:
     *                         moment_id:
     *                           type: string
     *                         moment_content:
     *                           type: string
     *                         media_urls:
     *                           type: array
     *                           items:
     *                             type: string
     *                           description: Array of media URLs (for backward compatibility)
     *                         media:
     *                           type: array
     *                           items:
     *                             type: object
     *                             properties:
     *                               media_id:
     *                                 type: integer
     *                               media_url:
     *                                 type: string
     *                           description: Array of media objects with both ID and URL
     *       401:
     *         description: Unauthorized
     *       403:
     *         description: Forbidden - not owner
     *       404:
     *         description: Moment not found
     */
    router.patch('/me/update/:moment_id', momentUpload, momentController.updateMoment);
/**
 * @swagger
 * /api/moment/me/delete/{moment_id}:
 *   delete:
 *     summary: Delete a moment (owner only)
 *     description: Only the owner can delete their moment post.
 *     tags:
 *       - moment
 *     parameters:
 *       - in: path
 *         name: moment_id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Moment deleted successfully
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - not owner
 *       404:
 *         description: Moment not found
 */
    router.delete('/me/delete/:moment_id', momentController.deleteMoment);

    // Handle unsupported methods
    router.all('/', methodNotAllowed);
};