const multer = require('multer');
const path = require('path');
const ApiError = require('../api-error');

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, './public/uploads/moments'); // Store uploads in the public/uploads directory
    },
    filename: function (req, file, cb) {
        const uniquePrefix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, uniquePrefix + path.extname(file.originalname)); // Generate a unique filename
    },
});

// Configure multer for multiple file uploads
const upload = multer({
    storage: storage,
    limits: {
        fileSize: 10 * 1024 * 1024, // 10MB limit per file
        files: 5 // Maximum 5 files
    },
    fileFilter: function (req, file, cb) {
        // Accept only image and video files
        const allowedTypes = /jpeg|jpg|png|gif|mp4|avi|mov|webm/;
        const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
        const mimetype = allowedTypes.test(file.mimetype);

        if (mimetype && extname) {
            return cb(null, true);
        } else {
            cb(new Error('Only image and video files are allowed'));
        }
    }
});

function imgUpload(req, res, next) {
    // Use .array() for multiple files with field name 'images'
    const uploadFiles = upload.array('images', 5); // Accept up to 5 files

    uploadFiles(req, res, function (err) {
        if (err instanceof multer.MulterError) {
            console.error('Multer Error:', err);

            if (err.code === 'LIMIT_FILE_SIZE') {
                return next(new ApiError(400, 'File size too large. Maximum 10MB per file.'));
            } else if (err.code === 'LIMIT_FILE_COUNT') {
                return next(new ApiError(400, 'Too many files. Maximum 5 files allowed.'));
            } else if (err.code === 'LIMIT_UNEXPECTED_FILE') {
                return next(new ApiError(400, 'Unexpected field name. Use "images" field for file uploads.'));
            } else {
                return next(new ApiError(400, 'An error occurred while uploading the image'));
            }
        } else if (err) {
            console.error('Upload Error:', err);
            return next(new ApiError(500, 'An unknown error occurred while uploading the image'));
        }

        console.log('Files uploaded successfully:', req.files);
        next();
    });
}

module.exports = imgUpload;