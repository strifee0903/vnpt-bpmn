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
};

async function getPublicMomentsOfUser(req, res, next) {
    const { u_id } = req.params;

    try {
        const moments = await momentService.getPublicMomentsByUserId(u_id);

        return res.json(
            JSend.success({
                user_id: u_id,
                public_moments: moments
            })
        );
    } catch (error) {
        return next(new ApiError(500, 'Error fetching public posts of user.'));
    }
};

//hiện tất cả bài viết công khai (public) cho news feed
async function getNewsFeed(req, res, next) {
    try {
        const { page, limit } = req.query;
        const result = await momentService.getAllPublicMoments({ page, limit });

        return res.json(JSend.success({
            moments: result.moments,
            metadata: result.metadata
        }));
    } catch (error) {
        return next(new ApiError(500, 'Error fetching public feed.'));
    }
}


async function getMyMoments(req, res, next) {
    if (!req.session.user) {
        return next(new ApiError(401, 'Please log in to view your posts.'));
    }

    try {
        const u_id = req.session.user.u_id;
        const { page, limit, is_public } = req.query;

        const result = await momentService.getAllMyMoments(u_id, { page, limit, is_public });

        return res.json(JSend.success(result));
    } catch (error) {
        return next(new ApiError(500, 'Error fetching your moments.'));
    }
};

async function getMomentDetailById(req, res, next) {
    try {
        const { moment_id } = req.params;

        const moment = await momentService.getMomentDetailById(moment_id);

        if (!moment) {
            return next(new ApiError(404, 'Moment not found.'));
        }

        // Nếu là bài viết private, chỉ cho xem nếu là chủ sở hữu
        if (!moment.is_public && req.session.user?.u_id !== moment.u_id) {
            return next(new ApiError(403, 'You are not authorized to view this private post.'));
        }

        return res.json(JSend.success({ moment }));
    } catch (error) {
        return next(new ApiError(500, 'Error fetching moment.'));
    }
};

async function updateMoment(req, res, next) {
    if (!req.session.user) {
        return next(new ApiError(401, 'Please log in to edit this post.'));
    }

    const userId = req.session.user.u_id;
    const moment_id = req.params.moment_id;

    try {
        // Handle media_ids_to_delete parsing
        let mediaIdsToDelete = req.body.media_ids_to_delete;

        console.log('Raw media_ids_to_delete:', mediaIdsToDelete); // Debug log

        if (mediaIdsToDelete) {
            if (typeof mediaIdsToDelete === 'string') {
                try {
                    // Try to parse as JSON array first
                    mediaIdsToDelete = JSON.parse(mediaIdsToDelete);
                } catch (err) {
                    // If parsing fails, try to split by comma or treat as single value
                    if (mediaIdsToDelete.includes(',')) {
                        mediaIdsToDelete = mediaIdsToDelete.split(',').map(id => id.trim());
                    } else {
                        mediaIdsToDelete = [mediaIdsToDelete];
                    }
                }
            }
            // Convert all values to integers
            if (Array.isArray(mediaIdsToDelete)) {
                mediaIdsToDelete = mediaIdsToDelete.map(id => parseInt(id)).filter(id => !isNaN(id));
            }
            req.body.media_ids_to_delete = mediaIdsToDelete;
        } else {
            req.body.media_ids_to_delete = [];
        }

        console.log('Processed media_ids_to_delete:', req.body.media_ids_to_delete); // Debug log

        // Validate moment_type if provided
        if (req.body.moment_type) {
            const allowedTypes = ['diary', 'event', 'report'];
            if (!allowedTypes.includes(req.body.moment_type)) {
                return next(new ApiError(400, 'moment_type must be one of: diary, event, report'));
            }
        }

        // Prepare data with boolean is_public
        const data = {
            moment_content: req.body.moment_content,
            moment_type: req.body.moment_type,
            is_public: req.body.is_public === 'true' || req.body.is_public === true,
            category_id: req.body.category_id ? parseInt(req.body.category_id) : undefined,
            moment_address: req.body.moment_address,
            latitude: req.body.latitude ? parseFloat(req.body.latitude) : undefined,
            longitude: req.body.longitude ? parseFloat(req.body.longitude) : undefined,
            media_ids_to_delete: req.body.media_ids_to_delete // Changed from media_to_delete
        };

        // Remove undefined/null values
        Object.keys(data).forEach((key) => {
            if (data[key] === undefined || data[key] === null) {
                delete data[key];
            }
        });

        console.log('Final data to service:', data); // Debug log

        const result = await momentService.updateMoment(moment_id, userId, data, req.files);

        if (!result) {
            return next(new ApiError(403, 'You are not allowed to edit this post.'));
        }

        return res.json(JSend.success({ message: 'Moment updated successfully!', moment: result }));
    } catch (error) {
        console.error('Update moment error:', error);
        return next(new ApiError(500, 'Failed to update moment.'));
    }
};

async function deleteMoment(req, res, next) {
    if (!req.session.user) {
        return next(new ApiError(401, 'Please log in to delete your post.'));
    }

    const userId = req.session.user.u_id;
    const moment_id = req.params.moment_id;

    try {
        const deleted = await momentService.deleteMoment(moment_id, userId);

        if (!deleted) {
            return next(new ApiError(403, 'You are not allowed to delete this post.'));
        }

        return res.json(JSend.success({ message: 'Moment deleted successfully.' }));
    } catch (error) {
        console.error('Delete moment error:', error);
        return next(new ApiError(500, 'Failed to delete moment.'));
    }
};

module.exports = {
    createMoment,
    getPublicMomentsOfUser,
    getNewsFeed,
    getMyMoments,
    getMomentDetailById,
    updateMoment,
    deleteMoment
};