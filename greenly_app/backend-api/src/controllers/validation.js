const {check} = require ('express-validator');

exports.signUpValidation = [
    check ('u_name', 'Name is required').not().isEmpty(),
    check('u_address', 'Address is required').not().isEmpty(),
    check('u_email', 'Please enter a valid email').isEmail().normalizeEmail({gmail_remove_dots: true}),
    check('u_pass', 'Password is required').isLength({min: 6}),
]