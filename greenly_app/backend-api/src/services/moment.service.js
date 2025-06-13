const knex = require('../database/knex');
const Paginator = require('./paginator');

function momentRepository() {
    return knex('moment');
}

function readMoment(payload) {
    const moment = {
        moment_id: payload.moment_id,
        u_id: payload.u_id,
        category_id: payload.category_id,
        moment_content: payload.moment_content,
        moment_address: payload.moment_address,
        latitude: payload.latitude,
        longitude: payload.longitude,
        moment_type: payload.moment_type,
        is_public: payload.is_public,
        created_at: payload.created_at,
        updated_at: payload.updated_at,
    };

    // Remove undefined/null values
    Object.keys(moment).forEach(key => {
        if (moment[key] === undefined || moment[key] === null) {
            delete moment[key];
        }
    });

    return moment;
}

async function createMoment(payload, files = []) {
    const moment = readMoment(payload);

    return await knex.transaction(async trx => {
        try {
            // 1. Create moment
            const [moment_id] = await trx('moment').insert(moment);

            // 2. If there are uploaded files, insert them into media table
            let mediaUrls = [];
            if (files && files.length > 0) {
                const mediaRecords = files.map(file => ({
                    moment_id: moment_id,
                    media_url: `/public/uploads/moments/${file.filename}`
                }));

                await trx('media').insert(mediaRecords);
                mediaUrls = mediaRecords.map(record => record.media_url);
            }

            // 3. Return success response with moment data and media URLs
            return {
                message: 'The moment created successfully!',
                data: {
                    moment_id,
                    ...moment,
                    media_urls: mediaUrls
                }
            };
        } catch (error) {
            console.error('Transaction error:', error);
            throw error; // Re-throw to trigger transaction rollback
        }
    });
}

async function getMomentById(momentId) {
    try {
        const moment = await knex('moment')
            .where('moment_id', momentId)
            .first();

        if (!moment) {
            return null;
        }

        // Get associated media
        const media = await knex('media')
            .where('moment_id', momentId)
            .select('media_url');

        return {
            ...moment,
            media_urls: media.map(m => m.media_url)
        };
    } catch (error) {
        console.error('Get moment error:', error);
        throw error;
    }
}

module.exports = {
    createMoment,
    getMomentById,
    momentRepository
};