const usersService = require('../services/user.service');
const ApiError = require('../api-error');
const JSend = require('../jsend');
const { validationResult } = require('express-validator');
const sendMail = require('../middlewares/sendMail');

const jwt = require('jsonwebtoken');
const { JWT_SECRET } = process.env;

async function register(req, res, next) {
    console.log('Request Body:', req.body); // Log form data (excluding file)
    console.log('Uploaded File (Controller):', req.file); // Log file details in controller
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
            u_avt: req.file ? `/public/uploads/${req.file.filename}` : '/public/images/blank_avt.jpg',
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

async function verifyMail(req, res) {
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

async function login(req, res, next) {
    const { u_email, u_pass } = req.body;
    try {
        // Check if session middleware is available
        if (!req.session) {
            return next(new ApiError(500, 'Session middleware is not configured properly.'));
        }

        // Check if user is already logged in
        if (req.session.user && req.session.user.u_id) {
            return res.json(JSend.success({ message: 'Already logged in!', data: req.session.user }));
        }

        // Attempt login
        const user = await usersService.login(u_email, u_pass);
        req.session.user = {
            u_id: user.u_id,
            u_email: user.u_email,
            role_id: user.role_id,
            u_avt: user.u_avt
        };
        console.log('Session User:', req.session.user.u_id, req.session.user.u_avt);

        // Save session and respond
        req.session.save(err => {
            if (err) {
                return next(new ApiError(500, 'Failed to save session.'));
            }
            return res.status(200).json(JSend.success({
                message: 'Log in successfully!',
                user: req.session.user,
            }));
            
        },
            console.log('Log in successfully!')
        );
    } catch (error) {
        console.error('Login error:', error);
        return next(new ApiError(500, error.message));
    }
};

async function logout(req, res, next) {
    if (!req.session.user) {
        return res.json(JSend.success('You are not logged in!'));
    }
    req.session.destroy((err) => {
        if (err) {
            return next(new ApiError(500, 'Error logging out, please try again.'));
        }
        res.clearCookie('connect.sid');

        return res.status(200).json(JSend.success({ message: 'Sign out successfully!' }));
    });
};

async function checkAdminSession(req, res, next) {
    try {
        await usersService.checkAdminSessionTimeout(req.session);
        return res.status(200).json(JSend.success({ message: 'Admin session is valid.' }));
    } catch (error) {
        console.error('Admin session check failed:', error.message);

        if (error.status === 440) {
            req.session.destroy(() => {
                res.clearCookie('connect.sid');
                return res.status(440).json(JSend.fail({ message: error.message }));
            });
        } else {
            return next(error);
        }
    }
};

async function getUser(req, res, next) {
    if (!req.session.user) {
        return next(new ApiError(401, 'Please log in to see your information!'));
    }
    const id = req.session.user.u_id;
    console.log(id);
    if (!id) {
        return next(new ApiError(401, 'You need to log in to view user information.'));
    }
    const user = await usersService.getUserById(id);
    if (!user) {
        return next(new ApiError(404, 'User not found.'));
    }
    return res.json(JSend.success({ message: 'User data', data: user }));
}

function safeStringify(obj) {
    const seen = new WeakSet();
    return JSON.stringify(obj, (key, value) => {
        if (typeof value === 'object' && value !== null) {
            if (seen.has(value)) {
                return '[Circular]';
            }
            seen.add(value);
        }
        return value;
    });
}


async function updateUser(req, res, next) {
    if (Object.keys(req.body).length === 0 && !req.file) {
        return next(new ApiError(400, 'Invalid update information.'));
    }
    if (!req.session.user) {
        return res.json(JSend.success('Please log in to perform this task!'));
    }
    const id = req.session.user.u_id;
    try {
        const updated = await usersService.updateUser(id, {
            ...req.body,
            u_avt: req.file ? `/public/uploads/${req.file.filename}` : null,
        });

        if (!updated) {
            return next(new ApiError(400, `Unable to update the information of the user with the code ${id}`));
        }
        // return res.json(JSend.success({ message: 'Updated successfully!', data: updated }));
        const { u_id, u_name, u_email, u_address, u_birthday, u_avt } = updated; // ví dụ
        return res.json(JSend.success({
            message: 'Updated successfully!',
            data: { u_id, u_name, u_email, u_address, u_birthday, u_avt }
        }));
        
    } catch (error) {
        console.log(error);
        return next(new ApiError(500, 'System error, please try again later.'));
    }
}

async function deleteUser(req, res, next) {
    if (!req.session.user) {
        return next(new ApiError(401, 'Please log in to perform this task!'));
    }
    try {
        const id = req.session.user.u_id;
        const deleted = await usersService.deleteUser(id);
        if (!deleted) {
            return next(new ApiError(404, 'Cannot delete user.'));
        }
        return res.json(JSend.success(`Successfully deleted user ${id}`));
    } catch (error) {
        return next(new ApiError(500, 'System error, please try again later.'));
    }
}

module.exports = {
    register,
    verifyMail,
    login,
    logout,
    checkAdminSession,
    getUser,
    safeStringify,
    updateUser,
    deleteUser,
};