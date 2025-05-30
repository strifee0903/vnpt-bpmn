const multer = require('multer');
const path = require('path');
const ApiError = require('../api-error');

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, './public/uploads/');
    },
    filename: function (req, file, cb) {
        const uniquePrefix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, uniquePrefix + path.extname(file.originalname));
    }
});

// Chỉ cho phép định dạng hình ảnh
const fileFilter = function (req, file, cb) {
    const allowedTypes = /jpeg|jpg|png|gif/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);

    if (extname && mimetype) {
        cb(null, true);
    } else {
        cb(new ApiError(400, 'Only image files (jpeg, jpg, png, gif) are allowed!'), false);
    }
};

function avatarUpload(req, res, next) {
    const upload = multer({
        storage: storage,
        fileFilter: fileFilter,
    }).single('u_avt');

    upload(req, res, function (err) {
        if (err instanceof multer.MulterError) {
            return next(new ApiError(400, 'An error occurred while uploading the avatar'));
        } else if (err) {
            return next(err); // ApiError truyền từ fileFilter
        }
        next();
    });
}

module.exports = avatarUpload;
