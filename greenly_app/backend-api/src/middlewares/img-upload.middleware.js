const multer = require('multer');
const path = require('path');
const ApiError = require('../api-error');

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, './public/uploads/'); // Store uploads in the public/uploads directory
    },
    filename: function (req, file, cb) {
        const uniquePrefix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, uniquePrefix + path.extname(file.originalname)); // Generate a unique filename
    },
});

function imgUpload(req, res, next) {
    const upload = multer({ storage: storage }).single('img_url_file'); // Expecting a single file for 'img_url_file'

    upload(req, res, function (err) {
        if (err instanceof multer.MulterError) {
            return next(
                new ApiError(400, 'An error occurred while uploading the image')
            );
        } else if (err) {
            return next(
                new ApiError(
                    500,
                    'An unknown error occurred while uploading the image'
                )
            );
        }

        next();
    });
}

module.exports = imgUpload;