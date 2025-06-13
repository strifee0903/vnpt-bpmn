const momentService = require('../services/moment.service');
const ApiError = require('../api-error');
const JSend = require('../jsend');

async function createMoment(req, res, next) {
    if (!req.session.user) {
        return next(new ApiError(401, 'Please log in to perform this task!'));
    }

    console.log('Request Body:', req.body);
    console.log('Uploaded Files:', req.files);

    try {
        const userId = req.session.user.u_id;

        // Validate required fields
        if (!req.body.category_id || !req.body.moment_content) {
            return next(new ApiError(400, 'category_id and moment_content are required fields.'));
        }

        // Convert and validate data types
        const momentData = {
            category_id: parseInt(req.body.category_id),
            moment_content: req.body.moment_content.trim(),
            moment_address: req.body.moment_address || null,
            latitude: req.body.latitude ? parseFloat(req.body.latitude) : null,
            longitude: req.body.longitude ? parseFloat(req.body.longitude) : null,
            moment_type: req.body.moment_type || 'diary',
            is_public: req.body.is_public !== undefined ?
                (req.body.is_public === 'true' || req.body.is_public === true) : true,
            u_id: userId,
        };

        // Validate moment_type
        const allowedTypes = ['diary', 'event', 'report'];
        if (!allowedTypes.includes(momentData.moment_type)) {
            return next(new ApiError(400, 'moment_type must be one of: diary, event, report'));
        }

        // Handle uploaded files (req.files is array from multer)
        const files = req.files || [];

        console.log('Constructed Moment Data:', momentData);
        console.log('Files to process:', files);

        const result = await momentService.createMoment(momentData, files);

        return res.status(201).json(
            JSend.success({
                message: result.message,
                moment: result.data,
            })
        );
    } catch (error) {
        console.error('Create moment error:', error);

        // Handle specific database errors
        if (error.code === 'ER_NO_REFERENCED_ROW_2') {
            return next(new ApiError(400, 'Invalid category_id or user reference.'));
        }

        return next(new ApiError(500, 'System error, please try again later.'));
    }
}

module.exports = {
    createMoment,
};