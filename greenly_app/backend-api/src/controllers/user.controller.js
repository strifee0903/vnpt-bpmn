const usersService = require('../services/user.service');
const ApiError = require('../api-error');
const JSend = require('../jsend');
const { validationResult } = require('express-validator');
const sendMail = require('../helpers/sendMail');

async function register(req, res, next) {
    console.log('Request Body:', req.body); // Log form data (excluding file)
    console.log('Uploaded File (Controller):', req.file); // Log file details in controller
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return next(new ApiError(400, 'Validation failed', { errors: errors.array() }));
    }

    try {
        const userData = {
            u_name: req.body.u_name,
            u_birthday: req.body.u_birthday,
            u_address: req.body.u_address,
            u_email: req.body.u_email,
            u_pass: req.body.u_pass,
            u_avt: req.file ? `/public/uploads/${req.file.filename}` : '/public/images/blank_avt.jpg',
        };
        console.log('Constructed User Data:', userData); // Log the final user data
        const result = await usersService.registerUser({
            ...req.body,
            u_avt: req.file ? `/public/uploads/${req.file.filename}` : null,
        });

        // Send verification email
        const mailSubject = 'Mail Verification';
        const content = `<p>Hi ${req.body.u_name}, \nPlease <a href="http://127.0.0.1:3000/mail-verification?token=${result.token}">Verify</a> your email.</p>`;
        await sendMail(req.body.u_email, mailSubject, content);

        return res
            .status(201)
            .set({ Location: `${req.baseUrl}/${result.user.u_id}` })
            .json(JSend.success({ message: 'The user has been registered! Please verify your email.', user: result.user }));
    } catch (error) {
        console.error('Registration error:', error);
        if (error.message === 'This email has been registered with us!') {
            return next(new ApiError(409, error.message));
        }
        if (error.message.includes('Failed to send email')) {
            return next(new ApiError(500, 'User registered, but failed to send verification email. Please try again later.'));
        }
        return next(new ApiError(500, 'System error, please try again later.'));
    }
}

async function verifyMail (req, res) {
    try {
        const token = req.query.token;
        const result = await usersService.verifyUserEmail(token);
        return res.render('mail-verification', { message: result.message });
    } catch (error) {
        console.error('Email verification failed:', error.message);
        if (error.message === 'No verification token provided' || error.message === 'Invalid or expired token') {
            return res.render('404');
        }
        return res.render('mail-verification', { message: 'Verification failed. Please try again later.' });
    }
};

module.exports = { 
    register, 
    verifyMail 
};