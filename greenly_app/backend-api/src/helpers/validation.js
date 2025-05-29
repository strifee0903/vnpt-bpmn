const { check } = require('express-validator');
const { checkExistEmail } = require('../services/user.service');

exports.signUpValidation = [
    check('u_name', 'Name is required').not().isEmpty(),
    check('u_address', 'Address is required').not().isEmpty(),
    check('u_email')
        .isEmail()
        .withMessage('Please enter a valid email')
        .normalizeEmail({ gmail_remove_dots: true })
        .custom(async (value) => {
            const existingUser = await checkExistEmail(value);
            if (existingUser) {
                throw new Error('This email has been registered with us!');
            }
            return true;
        }),
    check('u_pass', 'Password must be at least 8 characters long').isLength({ min: 8 }),
    check('u_avt')
        .optional() // Make the field optional
        .custom((value, { req }) => {
            // If no file is uploaded, skip validation
            if (!req.file) return true;

            // Check file type if a file is uploaded
            const allowedTypes = ['image/png', 'image/jpeg', 'image/jpg'];
            if (!allowedTypes.includes(req.file.mimetype)) {
                throw new Error('Please upload an image type PNG, JPG');
            }
            return true;
        }),
];