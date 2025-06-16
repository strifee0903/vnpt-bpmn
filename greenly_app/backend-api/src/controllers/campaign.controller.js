const campaignService = require('../services/campaign.service');
const ApiError = require('../api-error');
const JSend = require('../jsend');

async function createCampaign(req, res, next) {
    if (!req.session.user) {
        return next(new ApiError(401, 'Please log in to create a campaign.'));
    }

    const u_id = req.session.user.u_id;
    const { title, description, location, start_date, end_date, category_id } = req.body;

    if (!title || !description || !start_date || !end_date) {
        return next(new ApiError(400, 'Missing required fields.'));
    }

    try {
        const result = await campaignService.createCampaign(u_id, {
            title,
            description,
            location,
            start_date,
            end_date,
            category_id
        });

        return res.status(201).json(
            JSend.success({
                message: 'Campaign created successfully!',
                campaign_id: result.campaign_id,
                moment_id: result.moment_id
            })
        );
    } catch (error) {
        console.error('Create campaign error:', error);
        return next(new ApiError(500, 'Failed to create campaign.'));
    }
}
module.exports={
    createCampaign
}