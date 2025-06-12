const express = require("express");
const router = express.Router();
const categoryController = require('../controllers/category.controller');
const { methodNotAllowed } = require('../controllers/errors.controller');
const multer = require('multer');
const imgUpload = require('../middlewares/img-upload.middleware');

module.exports.setup = (app) => {
    app.use('/api/category', router);

    /**
     * @swagger
     * /api/category/createCategory:
     *   post:
     *     summary: Create a category
     *     requestBody:
     *       required: true
     *       content:
     *         multipart/form-data:
     *           schema:
     *             $ref: '#/components/schemas/category'
     *     tags:
     *       - category
     *     responses:
     *       201:
     *         description: A new table
     *         content:
     *           application/json:
     *             schema:
     *               type: object
     *               properties:
     *                 status:
     *                   type: string
     *                   description: The response status
     *                   enum: [success]
     *                 data:
     *                   type: object
     *                   properties:
     *                     category:
     *                         $ref: '#/components/schemas/category'
     *       409:
     *         description: Conflict - Category already exists
     *       500:
     *         description: Internal Server Error
     */
    router.post('/createCategory', imgUpload, categoryController.createCategory);

    /**
     * @swagger
     * /api/category/deleteCategory/{id}:
     *   delete:
     *     summary: Delete category by ID
     *     parameters:
     *       - in: path
     *         name: id
     *         required: true
     *         schema:
     *           type: integer
     *           description: Delete a category
     *     tags:
     *       - category
     *     responses:
     *       200:
     *         description: Category deleted
     *       401:
     *         description: Unauthorized
     *       404:
     *         description: Not Found
     *       500:
     *         description: Internal Server Error
     */
    router.delete('/deleteCategory/:id', categoryController.deleteCategory);

    router.all('/:id', methodNotAllowed);
    router.all('/', methodNotAllowed);
};