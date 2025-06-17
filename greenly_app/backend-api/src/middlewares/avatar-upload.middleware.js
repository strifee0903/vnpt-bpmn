const multer = require('multer');
const path = require('path');
const ApiError = require('../api-error');

// Cấu hình lưu file nếu có
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, './public/uploads');
    },
    filename: function (req, file, cb) {
        const uniquePrefix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, uniquePrefix + path.extname(file.originalname));
    }
});

// Lọc định dạng file hình ảnh
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

// Middleware "thông minh" → dùng .single nếu có file, .none nếu không có
function avatarUpload(req, res, next) {
    const contentType = req.headers['content-type'] || '';

    // Nếu là multipart/form-data và có file u_avt thì dùng .single
    if (contentType.includes('multipart/form-data')) {
        const hasFile =
            req.method === 'POST' &&
            req.headers['content-type']?.includes('multipart/form-data');

        const upload = multer({
            storage,
            fileFilter,
        }).single('u_avtFile');

        upload(req, res, function (err) {
            if (err instanceof multer.MulterError) {
                return next(new ApiError(400, 'Upload error'));
            } else if (err) {
                return next(err); // có thể là lỗi do fileFilter
            }
            next();
        });
    } else {
        next();
    }
}


module.exports = avatarUpload;
