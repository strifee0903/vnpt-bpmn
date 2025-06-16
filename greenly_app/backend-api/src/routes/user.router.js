const express = require("express");
const router = express.Router();
const { signUpValidation, logInValidation } = require('../middlewares/validation');
const userController = require('../controllers/user.controller');
const { avatarUpload } = require('../middlewares/img-upload.middleware'); 
const { methodNotAllowed } = require('../controllers/errors.controller');
const multer = require('multer');
const upload = multer();

module.exports.setup = (app) => {
    app.use('/api/users', router);

    /**
     * @swagger
     * /api/users/registration/:
     *   post:
     *     summary: Create a new user
     *     description: Create a new user
     *     requestBody:
     *       required: true
     *       content:
     *         multipart/form-data:
     *           schema:
     *             type: object
     *             properties:
     *               u_name:
     *                 type: string
     *                 description: Name of the user
     *               u_birthday:
     *                 type: string
     *                 format: date
     *                 description: Birthday of the user
     *               u_address:
     *                 type: string
     *                 description: Address of the user
     *               u_email:
     *                 type: string
     *                 format: email
     *                 description: Email of the user
     *               u_pass:
     *                 type: string
     *                 format: password
     *                 description: Password of the user
     *               u_avtFile:
     *                 type: string
     *                 format: binary
     *                 description: User avatar file
     *     tags:
     *       - users
     *     responses:
     *       201:
     *         description: A new user
     *         content:
     *           application/json:
     *             schema:
     *               type: object
     *               properties:
     *                 status:
     *                   type: string
     *                   enum: [success]
     *                 data:
     *                   type: object
     *                   properties:
     *                     user:
     *                       type: object
     *                       properties:
     *                         u_id:
     *                           type: integer
     *                         u_name:
     *                           type: string
     *                         u_email:
     *                           type: string
     *       400:
     *         description: Bad Request - Invalid input
     *       409:
     *         description: Conflict - Email already exists
     *       500:
     *         description: Internal Server Error
     */
    router.post('/registration/', avatarUpload, signUpValidation, userController.register);

    /**
     * @swagger
     * /api/users/login/:
     *   post:
     *     summary: Login
     *     description: Login into app
     *     requestBody:
     *       required: true
     *       content:
     *         multipart/form-data:
     *           schema:
     *             type: object
     *             properties:
     *               u_email:
     *                 type: string
     *                 format: email
     *                 description: Email of the user
     *               u_pass:
     *                 type: string
     *                 format: password
     *                 description: Password of the user
     *     tags:
     *       - users
     *     responses:
     *       200:
     *         description: Login success
     *         content:
     *           application/json:
     *             schema:
     *               type: object
     *               properties:
     *                 status:
     *                   type: string
     *                   description: The response status
     *                   enum: [success]
     *       500:
     *         description: Internal Server Error - Unexpected error on the server
     *         $ref: '#/components/responses/500'
     *       400:
     *         description: Bad Request - Invalid input or missing parameters
     *         $ref: '#/components/responses/400' 
     */
    router.post('/login/', upload.none(), logInValidation, userController.login);

    /**
     * @swagger
     * /api/users/logout/:
     *   post:
     *     summary: Logout
     *     description: Logout into System
     *     tags:
     *       - users
     *     responses:
     *       200:
     *         description: Logout success
     *         content:
     *           application/json:
     *             schema:
     *               type: object
     *               properties:
     *                 status:
     *                   type: string
     *                   description: The response status
     *                   enum: [success]
     *       500:
     *         description: Internal Server Error - Unexpected error on the server
     *         $ref: '#/components/responses/500'
     *       400:
     *         description: Bad Request - Invalid input or missing parameters
     *         $ref: '#/components/responses/400' 
     */
    router.post('/logout/', userController.logout);
    router.get('/admin-check-session/', userController.checkAdminSession);

    /** 
     * @swagger
     * /api/users/myInfo/:
     *   get:
     *     summary: Returns your user profile
     *     description: Returns your user profile
     *     tags:
     *       - users
     *     responses:
     *       200:
     *         description: A user
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
     *                     contact:
     *                       $ref: '#/components/schemas/Users'
     *       404:
     *         description: Not Found - Resource not found
     *         $ref: '#/components/responses/404'
     *       500:
     *         description: Internal Server Error - Unexpected error on the server
     *         $ref: '#/components/responses/500'
     */
    router.get('/myInfo/', userController.getUser);

    /** 
     * @swagger
     * /api/users/info/{u_id}:
     *   get:
     *     summary: Get user profile by ID
     *     description: Get user profile by ID
     *     tags:
     *       - users
     *     parameters:
     *       - in: path
     *         name: u_id
     *         schema:
     *           type: integer
     *         required: true
     *         description: User ID
     *     responses:
     *       200:
     *         description: A user
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
     *                     contact:
     *                       $ref: '#/components/schemas/Users'
     *       404:
     *         description: Not Found - Resource not found
     *         $ref: '#/components/responses/404'
     *       500:
     *         description: Internal Server Error - Unexpected error on the server
     *         $ref: '#/components/responses/500'
     */
    router.get('/info/:u_id', userController.getUser);

    /**
     * @swagger
     * /api/users/updateProfile/:
     *   patch:
     *     summary: Update user by ID 
     *     description: Update user by ID
     *     requestBody:
     *       required: true
     *       content:
     *         multipart/form-data:
     *           schema:
     *             type: object
     *             properties:
     *               u_name:
     *                 type: string
     *                 description: name
     *               u_birthday:
     *                 type: integer
     *                 format: date
     *                 description: birthday
     *               u_address:
     *                 type: string
     *                 description: address
     *               u_avt:
     *                 type: string
     *                 readOnly: true
     *                 description: avatar
     *               u_avtFile:
     *                 type: string
     *                 format: binary
     *                 writeOnly: true
     *                 description: new avatar
     *     tags:
     *       - users
     *     responses:
     *       200:
     *         description: An updated user
     *         content:
     *           application/json:
     *             schema:
     *               type: object
     *               properties:
     *                 status:
     *                   type: string
     *                   description: The response status
     *                   enum:
     *                     - success
     *                 data:
     *                   type: object
     *                   properties:
     *                     contact:
     *                       $ref: '#/components/schemas/User'
     *         $ref: '#/components/responses/200NoData'
     *       400:
     *         description: Bad Request - Invalid input or missing parameters
     *         $ref: '#/components/responses/400'
     *       404:
     *         description: Not Found - Resource not found
     *         $ref: '#/components/responses/404'
     *       500:
     *         description: Internal Server Error - Unexpected error on the server
     *         $ref: '#/components/responses/500'
     */
    router.patch('/updateProfile/', avatarUpload, userController.updateUser);

    /**
     * @swagger
     * /api/users/deleteAccount/:
     *   delete:
     *     summary: Delete user by ID
     *     description: Delete user by ID
     *     tags:
     *       - users
     *     responses:
     *       200:
     *         description: User deleted
     *         $ref: '#/components/responses/200NoData'
     *       401:
     *         description: Unauthorized - User not logged in
     *         $ref: '#/components/responses/401'
     *       404:
     *         description: Not Found - Resource not found
     *         $ref: '#/components/responses/404'
     *       500:
     *         description: Internal Server Error - Unexpected error on the server
     *         $ref: '#/components/responses/500'
     */
    router.delete('/deleteAccount/', userController.deleteUser);
    router.all('/:id', methodNotAllowed);

    router.all('/', methodNotAllowed);
};