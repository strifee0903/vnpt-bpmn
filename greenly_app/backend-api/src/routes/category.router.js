const express = require("express");
const router = express.Router();
const categoryController = require('../controllers/category.controller');
const { methodNotAllowed } = require('../controllers/errors.controller');
const { categoryUpload } = require('../middlewares/img-upload.middleware'); 

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
      *             type: object
     *             properties:
     *               category_id:
     *                 type: integer
     *                 readOnly: true
     *                 description: name
     *               category_name:
     *                 type: string
     *                 description: name of the category
     *               category_image:
     *                 type: string
     *                 readOnly: true
     *                 description: image of the category
     *               categoryImage:
     *                 type: string
     *                 format: binary
     *                 writeOnly: true
     *                 description: The image file for the category (optional)
     * 
     *     tags:
     *       - category
     *     responses:
     *       201:
     *         description: A new category has been created successfully
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
    router.post('/createCategory', categoryUpload, categoryController.createCategory);

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

    /**
     * @swagger
     * /api/category/all:
     *   get:
     *     summary: Get all
     *     description: Retrieve all categories with optional filters
     *     parameters:
     *       - in: query
     *         name: category_name
     *         required: false
     *         schema:
     *           type: string
     *         description: Filter by category name
     *       - $ref: '#/components/parameters/limitParam'
     *       - $ref: '#/components/parameters/pageParam'
     *     tags:
     *       - category
     *     responses:
     *       200:
     *         description: Successfully retrieved categories
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
     *                     categories:
     *                       type: array
     *                       items:
     *                         type: object
     *                         properties:
     *                           category_id:
     *                             type: integer
     *                             readOnly: true
     *                           category_name:
     *                             type: string
     *                             description: Name of the category
     *                           category_image:
     *                             type: string
     *                             readOnly: true
     *                             description: image of the category
     *                     metadata:
     *                       $ref: '#/components/schemas/PaginationMetadata'
     *       400:
     *         description: Invalid request, missing or invalid fields
     *       404:
     *         description: Not Found
     *       500:
     *         description: Internal server error
     */

    router.get('/all', categoryController.getAllCategories)

    /**
     * @swagger
     * /api/category/get/{category_id}:
     *   get:
     *     summary: get category by id
     *     description: Retrieve a category by its ID
     *     parameters:
     *       - in: path
     *         name: category_id
     *         required: true
     *         schema:
     *           type: integer
     *         description: The ID of the category to retrieve
     *     tags:
     *       - category
     *     responses:
     *       200:
     *         description: Successfully retrieved category
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
     *                     categories:
     *                       type: array
     *                       items:
     *                         type: object
     *                         properties:
     *                           category_id:
     *                             type: integer
     *                             readOnly: true
     *                           category_name:
     *                             type: string
     *                             description: Name of the category
     *                           category_image:
     *                             type: string
     *                             readOnly: true
     *                             description: image of the category
     *       400:
     *         description: Invalid request, missing or invalid fields
     *       404:
     *         description: Not Found
     *       500:
     *         description: Internal server error
     */
    router.get('/get/:category_id', categoryController.getCategoryById);

    /**
     * @swagger
     * /api/category/update/{category_id}:
     *   patch:
     *     tags:
     *       - category
     *     summary: Update category by ID
     *     description: Update the name of a category using its ID. Only admin users are allowed to perform this operation.
     *     parameters:
     *       - in: path
     *         name: category_id
     *         required: true
     *         schema:
     *           type: integer
     *         description: The ID of the category to retrieve
     *     requestBody:
     *       required: true
     *       content:
     *         multipart/form-data:
     *           schema:
     *             type: object
     *             properties:
     *               category_name:
     *                 type: string
     *                 description: The new name for the category 
     *               category_image:
     *                 type: string
     *                 readOnly: true
     *                 description: image of the category
     *               categoryImage:
     *                 type: string
     *                 format: binary
     *                 writeOnly: true
     *                 description: The new image for the category (optional)
     *     responses:
     *       200:
     *         description: Category updated successfully
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
     *                     categories:
     *                       type: array
     *                       items:
     *                         type: object
     *                         properties:
     *                           category_id:
     *                             type: integer
     *                             readOnly: true
     *                           category_image:
     *                             type: string
     *                             readOnly: true
     *                             description: image of the category
     *                           categoryImage:
     *                             type: string
     *                             format: binary
     *                             writeOnly: true
     *                             description: The image file for the category (optional)
     *       400:
     *         description: Bad request - Missing or invalid data / Duplicate category name
     *       401:
     *         description: Unauthorized - Please log in
     *       403:
     *         description: Forbidden - Only admins can update categories
     *       404:
     *         description: Category not found
     *       500:
     *         description: Internal server error
     */
    router.patch('/update/:category_id', categoryUpload ,categoryController.updateCategory);


    router.all('/:id', methodNotAllowed);
    router.all('/', methodNotAllowed);
};