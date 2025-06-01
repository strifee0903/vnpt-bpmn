const express = require("express");
const router = express.Router();
const { signUpValidation, logInValidation } = require('../middlewares/validation');
const userController = require('../controllers/user.controller');
const avatarUpload = require('../middlewares/avatar-upload.middleware')
const { methodNotAllowed } = require('../controllers/errors.controller');
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
     *               u_avt:
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
    // router.post('/registration/', upload.single('u_avt'), signUpValidation, userController.register);
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
    router.post('/login/', avatarUpload, logInValidation, userController.login);

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
    router.all('/', methodNotAllowed);
};