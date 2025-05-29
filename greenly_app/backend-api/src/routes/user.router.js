const express = require("express");
const router = express.Router();
const { signUpValidation } = require('../helpers/validation');
const userController = require('../controllers/user.controller');
const { methodNotAllowed } = require('../controllers/errors.controller');
const path = require('path');
const multer = require('multer');
const storage = multer.diskStorage({
    destination: function (req, file, cb){
        cb(null, path.join(dirname,'../public/uploads'));
    },
    filename: function(req, file, cb){
        const name = Date.now() + '-' + file.originalname;
        cb(null, name);
    }
});

const filefilter = (req, file, cb) => {
    (file.mimetype == 'u_avt/jpeg' || file.mimetype == 'u_avt/png')?cb(null, true):cb(null, false);
}

const upload = multer ({
    storage: storage,
    filefilter: filefilter
});

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
    router.post('/registration/', upload.single('u_avt'), signUpValidation, userController.register);
    router.all('/', methodNotAllowed);
};