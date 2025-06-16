const express = require('express');
const router = express.Router();
const multer = require('multer');
const voteController = require('../controllers/vote.controller');
const { methodNotAllowed } = require('../controllers/errors.controller');

// Multer middleware for handling multipart/form-data
const upload = multer();

module.exports.setup = (app) => {
    app.use('/api/vote', router);

    /**
     * @swagger
     * /api/vote/moment/{moment_id}:
     *   post:
     *     summary: Like or unlike a moment
     *     description: Toggle like/unlike for a moment. Re-click to remove vote.
     *     tags:
     *       - vote
     *     parameters:
     *       - in: path
     *         name: moment_id
     *         required: true
     *         schema:
     *           type: integer
     *         description: ID of the moment
     *     requestBody:
     *       required: true
     *       content:
     *         multipart/form-data:
     *           schema:
     *             type: object
     *             required:
     *               - vote_state
     *             properties:
     *               vote_state:
     *                 type: boolean
     *                 description: true = like, false = unlike
     *                 example: true
     *     responses:
     *       200:
     *         description: Vote toggled and total vote count returned
     *       400:
     *         description: Invalid input
     *       401:
     *         description: Unauthorized
     *       500:
     *         description: Server error
     */
    // Use multer middleware to handle multipart/form-data
    router.post('/moment/:moment_id', upload.none(), voteController.voteMoment);

    router.all('/:id', methodNotAllowed);

    router.all('/', methodNotAllowed);
};