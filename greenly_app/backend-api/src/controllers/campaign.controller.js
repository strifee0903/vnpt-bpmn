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
                ...result
            })
        );
    } catch (error) {
        console.error('Create campaign error:', error);
        return next(new ApiError(500, 'Failed to create campaign.'));
    }
};

async function getAllCampaigns(req, res, next) {
    if (!req.session.user) {
        return next(new ApiError(401, 'Please log in to perform this task!'));
    }
    let result = {
        campaigns: [],
        metadata: {
            totalRecords: 0,
            firstPage: 1,
            lastPage: 1,
            page: 1,
            limit: 5,
        }
    };

    try {
        result = await campaignService.getAllCampaigns(req.query);
    } catch (error) {
        console.error('Get all campaigns error:', error);
        return next(new ApiError(500, 'Failed to fetch campaigns.'));
    }

    return res.json(
        JSend.success({
            campaigns: result.campaigns,
            metadata: result.metadata,
        })
    );
};

async function getCampaignById(req, res, next) {
    try {
        const { campaign_id } = req.params;
        const campaign = await campaignService.getCampaignById(campaign_id);
        if (!campaign) return next(new ApiError(404, 'Campaign not found.'));
        return res.json(JSend.success({ campaign }));
    } catch (error) {
        console.error('Get campaign by ID error:', error);
        return next(new ApiError(500, 'Failed to fetch campaign.'));
    }
};

async function joinCampaign(req, res, next) {
    if (!req.session.user) return next(new ApiError(401, 'Please log in.'));
    const { campaign_id } = req.params;
    const u_id = req.session.user.u_id;

    try {
        const result = await campaignService.joinCampaign(u_id, campaign_id);
        return res.json(JSend.success({
            message: result.message,
            ...result
        }));
    } catch (error) {
        if (error.message === 'Campaign not found') {
            return next(new ApiError(404, 'Campaign not found.'));
        }
        if (error.message === 'Host cannot join their own campaign') {
            return next(new ApiError(403, 'You are the host of this campaign.'));
        }
        if (error.message === 'Already joined this campaign') {
            return next(new ApiError(400, 'You have already joined this campaign.'));
        }
        return next(new ApiError(500, 'Error joining campaign.'));
    }
};

async function leaveCampaign(req, res, next) {
    if (!req.session.user) return next(new ApiError(401, 'Please log in.'));
    try {
        const { campaign_id } = req.params;
        const u_id = req.session.user.u_id;
        const result = await campaignService.leaveCampaign(u_id, campaign_id);
        return res.json(JSend.success({
            message: result.message,
            ...result
        }));
    } catch (err) {
        console.error('Leave campaign error:', err); // Log for debugging
        if (err.message === 'Campaign not found') {
            return next(new ApiError(404, 'Campaign not found.'));
        }
        if (err.message === 'Cannot leave - not joined yet') {
            return next(new ApiError(400, 'You have not joined this campaign yet.'));
        }
        if (err.message === 'Already left this campaign') {
            return next(new ApiError(400, 'You have already left this campaign.'));
        }
        if (err.message === 'Host cannot leave their own campaign') {
            return next(new ApiError(403, 'You are the host of this campaign and cannot leave.'));
        }
        return next(new ApiError(500, 'Error leaving campaign.'));
    }
};

async function getParticipants(req, res, next) {
    try {
        const { campaign_id } = req.params;
        const result = await campaignService.getParticipants(campaign_id, req.query);
        return res.json(JSend.success({
            participants: result.participants,
            metadata: result.metadata
        }));
    } catch (err) {
        if (err.message === 'Campaign not found') {
            return next(new ApiError(404, 'Campaign not found.'));
        }
        return next(new ApiError(500, 'Failed to fetch participants.'));
    }
}


module.exports = {
    createCampaign,
    getAllCampaigns,
    getCampaignById,
    joinCampaign,
    leaveCampaign,
    getParticipants
};

