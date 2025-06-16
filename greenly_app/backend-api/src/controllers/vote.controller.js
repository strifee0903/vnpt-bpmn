const voteService = require('../services/vote.service');
const ApiError = require('../api-error');
const JSend = require('../jsend');

async function voteMoment(req, res, next) {
    if (!req.session.user) {
        return next(new ApiError(401, 'Please log in to vote.'));
    }

    const { moment_id } = req.params;

    // Debug: Log the request body and content type
    console.log('Request body:', req.body);
    console.log('Content-Type:', req.get('Content-Type'));

    // More flexible body validation
    if (!req.body) {
        return next(new ApiError(400, 'Request body is required.'));
    }

    const vote_state = req.body.vote_state;

    if (vote_state === undefined || vote_state === null) {
        return next(new ApiError(400, 'Missing "vote_state" field in body.'));
    }

    const u_id = req.session.user.u_id;

    // Handle both boolean and string representations
    let parsedVote;
    if (vote_state === true || vote_state === 'true') {
        parsedVote = true;
    } else if (vote_state === false || vote_state === 'false') {
        parsedVote = false;
    } else {
        return next(new ApiError(400, 'vote_state must be true (like) or false (unlike).'));
    }

    try {
        const result = await voteService.voteMoment(moment_id, u_id, parsedVote);
        return res.json(JSend.success({
            message: 'Vote updated successfully.',
            vote: {
                moment_id,
                vote_state: parsedVote,
                ...result
            }
        }));
    } catch (error) {
        console.error('Vote error:', error);
        return next(new ApiError(500, 'Failed to update vote.'));
    }
}

module.exports = {
    voteMoment
};