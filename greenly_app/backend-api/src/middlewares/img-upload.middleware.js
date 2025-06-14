const multer = require('multer');
const path = require('path');
const ApiError = require('../api-error');

// Common storage configuration
const getStorage = (destination) => multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, `./public/uploads/${destination}`);
    },
    filename: function (req, file, cb) {
        const uniquePrefix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, uniquePrefix + path.extname(file.originalname));
    }
});

// File filter for images (avatars and categories)
const imageFileFilter = (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);

    if (extname && mimetype) {
        cb(null, true);
    } else {
        cb(new ApiError(400, 'Only image files (jpeg, jpg, png, gif) are allowed!'), false);
    }
};

// File filter for moments (images and videos)
const momentFileFilter = (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif|mp4|avi|mov|webm/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);

    if (extname && mimetype) {
        cb(null, true);
    } else {
        cb(new ApiError(400, 'Only image and video files are allowed!'), false);
    }
};

// Unified upload middleware
function fileUpload(uploadType = 'avatar') {
    return (req, res, next) => {
        let config;
        switch (uploadType) {
            case 'avatar':
                config = {
                    storage: getStorage('avatars'),
                    fileFilter: imageFileFilter,
                    fieldName: 'u_avtFile',
                    isSingle: true
                };
                break;
            case 'category':
                config = {
                    storage: getStorage('categories'),
                    fileFilter: imageFileFilter,
                    fieldName: 'categoryImage',
                    isSingle: true
                };
                break;
            case 'moment':
                config = {
                    storage: getStorage('moments'),
                    fileFilter: momentFileFilter,
                    fieldName: 'images',
                    isSingle: false,
                    limits: { fileSize: 10 * 1024 * 1024, files: 5 }
                };
                break;
            default:
                return next(new ApiError(400, 'Invalid upload type'));
        }

        const contentType = req.headers['content-type'] || '';

        // Skip upload middleware if not multipart/form-data
        if (!contentType.includes('multipart/form-data')) {
            return next();
        }

        const upload = multer({
            storage: config.storage,
            fileFilter: config.fileFilter,
            limits: config.limits
        })[config.isSingle ? 'single' : 'array'](
            config.fieldName,
            config.isSingle ? undefined : 5
        );

        upload(req, res, function (err) {
            if (err instanceof multer.MulterError) {
                if (err.code === 'LIMIT_FILE_SIZE') {
                    return next(new ApiError(400, 'File size too large. Maximum 10MB per file.'));
                } else if (err.code === 'LIMIT_FILE_COUNT') {
                    return next(new ApiError(400, 'Too many files. Maximum 5 files allowed.'));
                } else if (err.code === 'LIMIT_UNEXPECTED_FILE') {
                    return next(new ApiError(400, `Unexpected field name. Use "${config.fieldName}" field for file uploads.`));
                }
                return next(new ApiError(400, 'Upload error'));
            } else if (err) {
                return next(err);
            }

            console.log(`${uploadType.charAt(0).toUpperCase() + uploadType.slice(1)} file(s) uploaded successfully:`, req.files || req.file);
            next();
        });
    };
}

// Export specific middleware for each use case
module.exports = {
    avatarUpload: fileUpload('avatar'),
    momentUpload: fileUpload('moment'),
    categoryUpload: fileUpload('category')
};