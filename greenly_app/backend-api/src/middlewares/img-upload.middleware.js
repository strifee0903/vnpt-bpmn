const multer = require('multer');
const path = require('path');
const ApiError = require('../api-error');

// === COMMON STORAGE: Lưu vào ./public/uploads ===
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, './public/uploads');
    },
    filename: (req, file, cb) => {
        const uniqueName = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, uniqueName + path.extname(file.originalname));
    }
});

// === FILE FILTERS ===
const imageFileFilter = (req, file, cb) => {
    // const allowed = /jpeg|jpg|png|gif|heic/;
    const allowedExtensions = /\.(jpeg|jpg|png|gif|heic)$/i;
    const allowedMimeTypes = /^image\/(jpeg|png|gif|heic)$/i;
    const isValidExtension = allowedExtensions.test(path.extname(file.originalname).toLowerCase());
    const isValidMimeType = allowedMimeTypes.test(file.mimetype.toLowerCase());
    // const isValid = allowed.test(path.extname(file.originalname).toLowerCase()) && allowed.test(file.mimetype);
    // cb(isValid ? null : new ApiError(400, 'Only image files are allowed!'), isValid);
    const isValid = isValidExtension && isValidMimeType;
    cb(isValid ? null : new ApiError(400, 'Only image files are allowed!'), isValid);
};

const momentFileFilter = (req, file, cb) => {
    // const allowed = /jpeg|jpg|png|gif|mp4|avi|mov|webm/;
    // const isValid = allowed.test(path.extname(file.originalname).toLowerCase()) && allowed.test(file.mimetype);
    // cb(isValid ? null : new ApiError(400, 'Only image and video files are allowed!'), isValid);
    const allowedExtensions = /\.(jpeg|jpg|png|gif|heic|mp4|avi|mov|webm)$/i;
    const allowedMimeTypes = /^(image\/(jpeg|png|gif|heic)|video\/(mp4|avi|quicktime|webm))$/i;

    const isValidExtension = allowedExtensions.test(path.extname(file.originalname).toLowerCase());
    const isValidMimeType = allowedMimeTypes.test(file.mimetype.toLowerCase());

    const isValid = isValidExtension && isValidMimeType;
    cb(isValid ? null : new ApiError(400, 'Only image and video files are allowed!'), isValid);
};

// === MIDDLEWARE FACTORY ===
function fileUpload(uploadType = 'avatar') {
    return (req, res, next) => {
        let config;

        switch (uploadType) {
            case 'avatar':
                config = {
                    fileFilter: imageFileFilter,
                    fieldName: 'u_avtFile',
                    isSingle: true
                };
                break;
            case 'category':
                config = {
                    fileFilter: imageFileFilter,
                    fieldName: 'categoryImage',
                    isSingle: true
                };
                break;
            case 'moment':
                config = {
                    fileFilter: momentFileFilter,
                    fieldName: 'images',
                    isSingle: false,
                    limits: { fileSize: 10 * 1024 * 1024, files: 5 }
                };
                break;
            default:
                return next(new ApiError(400, 'Invalid upload type.'));
        }

        const contentType = req.headers['content-type'] || '';
        if (!contentType.includes('multipart/form-data')) return next();

        const upload = multer({
            storage,
            fileFilter: config.fileFilter,
            limits: config.limits
        })[config.isSingle ? 'single' : 'array'](config.fieldName, config.isSingle ? undefined : 5);

        upload(req, res, err => {
            if (err instanceof multer.MulterError) {
                if (err.code === 'LIMIT_FILE_SIZE') {
                    return next(new ApiError(400, 'File too large. Max 10MB.'));
                }
                if (err.code === 'LIMIT_FILE_COUNT') {
                    return next(new ApiError(400, 'Too many files. Max 5.'));
                }
                if (err.code === 'LIMIT_UNEXPECTED_FILE') {
                    return next(new ApiError(400, `Unexpected field name. Use "${config.fieldName}".`));
                }
                return next(new ApiError(400, 'Upload error.'));
            } else if (err) {
                return next(err);
            }

            console.log(`${uploadType} file(s) uploaded:`, req.files || req.file);
            next();
        });
    };
}

// === EXPORT ===
module.exports = {
    avatarUpload: fileUpload('avatar'),
    categoryUpload: fileUpload('category'),
    momentUpload: fileUpload('moment')
};
