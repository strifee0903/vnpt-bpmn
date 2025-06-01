const express = require("express");
const router = express.Router();
const userController = require('../controllers/user.controller');
const path = require('path');

module.exports.setup = (app) => {
    app.use(express.static('public'));
    app.use('/', router);
    router.get('/mail-verification', userController.verifyMail);
};
