const express = require('express');
const libraryController = require('../controllers/library.controller');
const router = express.Router();
const fileUpload = require('../middlewares/file-upload.middleware');

module.exports.setup = (app) => {
    app.use('/api/v1/library', router);

    router.post('/content', fileUpload, libraryController.postContent);

    router.get('/content/all_content', libraryController.getAllContent);

    router.get('/content/:id', libraryController.getContentById);

    router.put('/content/:id', fileUpload, libraryController.updateContent);

    router.delete('/content/:id', libraryController.deleteContent);
};
