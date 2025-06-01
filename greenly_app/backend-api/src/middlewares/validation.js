const { check, validationResult } = require('express-validator');
const { checkExistEmail } = require('../services/user.service');

async function signUpValidation (req, res, next) {
    // Define validation checks
    const validations = [
        check('u_name')
            .not().isEmpty().withMessage('Name is required')
            .isLength({ min: 4 }).withMessage('Name must be more than 3 characters long'),
        check('u_address')
            .not().isEmpty().withMessage('Address is required')
            .isString().withMessage('Address must be a string'),
        check('u_email')
            .isEmail().withMessage('Please enter a valid email')
            .normalizeEmail({ gmail_remove_dots: true })
            .custom(async (value) => {
                const existingUser = await checkExistEmail(value);
                if (existingUser) {
                    throw new Error('This email has been registered with us!');
                }
                return true;
            }),
        check('u_pass')
            .isLength({ min: 8 }).withMessage('Password must be at least 8 characters long'),
        check('u_birthday')
            .not().isEmpty().withMessage('Birthday is required')
            .isDate().withMessage('Birthday must be a valid date')
            .custom(async (value) => {
                const birthday = new Date(value);
                const currentDate = new Date();
                if (birthday >= currentDate) {
                    throw new Error('Birthday must be before the current date');
                }
                return true;
            }),
        check('u_avt')
            .optional() // Make the field optional
            .custom(async (value, { req }) => {
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

    // Run validations
    try {
        await Promise.all(validations.map(validation => validation.run(req)));
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({
                status: 'error',
                message: 'Validation failed',
                errors: errors.array()
            });
        }
        next();
    } catch (error) {
        console.error('Validation error:', error);
        return res.status(500).json({
            status: 'error',
            message: 'System error during validation, please try again later.'
        });
    }
};

module.exports = { signUpValidation };