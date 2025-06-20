const knex = require('../database/knex');
const Paginator = require('./paginator');

function momentRepository() {
    return knex('moment');
};

function mediaRepository() {
    return knex('media');
};

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
};

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
                    media_url: `/public/uploads/${file.filename}`
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
};

/**hàm để khi vào trang cá nhân của người khác thì có thể xem hết tất cả bài viết ở trạng thái public của người đó.*/
async function getPublicMomentsByUserId(u_id) {
    try {
        // 1. Lấy tất cả moments công khai của người dùng
        const moments = await momentRepository()
            .where({ u_id, is_public: true })
            .orderBy('created_at', 'desc'); // optional: sắp xếp mới nhất trước

        // 2. Với mỗi moment, lấy media tương ứng
        const result = await Promise.all(moments.map(async (moment) => {
            const media = await mediaRepository()
                .where('moment_id', moment.moment_id)
                .select('media_url');

            return {
                ...moment,
                media_urls: media.map(m => m.media_url),
            };
        }));

        return result;
    } catch (error) {
        console.error('Error fetching public moments:', error);
        throw error;
    }
};

// async function getAllPublicMoments(query) {
//     const { page = 1, limit = 5 } = query;
//     const paginator = new Paginator(page, limit);

//     try {
//         const moments = await momentRepository()
//             .where('is_public', true)
//             .orderBy('created_at', 'desc')
//             .limit(paginator.limit)
//             .offset(paginator.offset);

//         const totalRecords = (await momentRepository()
//             .where('is_public', true)
//             .count('moment_id as count')
//             .first())?.count || 0;

//         const result = await Promise.all(moments.map(async (moment) => {
//             const media = await mediaRepository()
//                 .where('moment_id', moment.moment_id)
//                 .select('media_url');

//             const category = await knex('category')
//                 .where('category_id', moment.category_id)
//                 .select('category_id', 'category_name')
//                 .first();

//             const user = await knex('users')
//                 .where('u_id', moment.u_id)
//                 .select('u_id', 'u_name', 'u_avt')
//                 .first();

//             return {
//                 moment_id: moment.moment_id,
//                 moment_content: moment.moment_content,
//                 moment_address: moment.moment_address,
//                 latitude: moment.latitude,
//                 longitude: moment.longitude,
//                 created_at: moment.created_at,
//                 moment_type: moment.moment_type,
//                 category: category || null,
//                 user: user || null,
//                 media: media
//             };
//         }));

//         return {
//             metadata: paginator.getMetadata(totalRecords),
//             moments: result
//         };
//     } catch (error) {
//         console.error('Error fetching public moments:', error);
//         throw error;
//     }
// }

async function getAllPublicMoments(query) {
    const { page = 1, limit = 5, moment_type } = query;
    const paginator = new Paginator(page, limit);

    try {
        // Base query
        let baseQuery = momentRepository().where('is_public', true);

        // Optional: filter by moment_type
        if (moment_type && moment_type !== 'all') {
            baseQuery = baseQuery.where('moment_type', moment_type);
        }

        const moments = await baseQuery
            .orderBy('created_at', 'desc')
            .limit(paginator.limit)
            .offset(paginator.offset);

        // Count total (with same filter)
        let countQuery = momentRepository().where('is_public', true);
        if (moment_type && moment_type !== 'all') {
            countQuery = countQuery.where('moment_type', moment_type);
        }

        const totalRecords = (await countQuery.count('moment_id as count').first())?.count || 0;

        const result = await Promise.all(moments.map(async (moment) => {
            const media = await mediaRepository()
                .where('moment_id', moment.moment_id)
                .select('media_url');

            const category = await knex('category')
                .where('category_id', moment.category_id)
                .select('category_id', 'category_name')
                .first();

            const user = await knex('users')
                .where('u_id', moment.u_id)
                .select('u_id', 'u_name', 'u_avt')
                .first();

            return {
                moment_id: moment.moment_id,
                moment_content: moment.moment_content,
                moment_address: moment.moment_address,
                latitude: moment.latitude,
                longitude: moment.longitude,
                created_at: moment.created_at,
                moment_type: moment.moment_type,
                category: category || null,
                user: user || null,
                media: media
            };
        }));

        return {
            metadata: paginator.getMetadata(totalRecords),
            moments: result
        };
    } catch (error) {
        console.error('Error fetching public moments:', error);
        throw error;
    }
}



async function getAllMyMoments(u_id, query) {
    const { page = 1, limit = 5, is_public } = query;
    const paginator = new Paginator(page, limit);

    try {
        // 1. Build query
        const baseQuery = momentRepository().where('u_id', u_id);

        // Nếu có lọc is_public thì thêm điều kiện
        if (is_public !== undefined) {
            baseQuery.andWhere('is_public', is_public === 'true' || is_public === true);
        }

        const moments = await baseQuery
            .clone()
            .limit(paginator.limit)
            .offset(paginator.offset);

        const totalRecordsQuery = baseQuery.clone().count('moment_id as count').first();
        let totalRecords = await totalRecordsQuery;
        totalRecords = totalRecords?.count || 0;

        // 2. Gắn ảnh và thông tin user, category cho mỗi moment
        const result = await Promise.all(
            moments.map(async (moment) => {
                const media = await mediaRepository()
                    .where('moment_id', moment.moment_id)
                    .select('media_id', 'media_url');

                const category = await knex('category')
                    .where('category_id', moment.category_id)
                    .select('category_id', 'category_name')
                    .first();

                const user = await knex('users')
                    .where('u_id', moment.u_id)
                    .select('u_id', 'u_name', 'u_avt')
                    .first();

                return {
                    moment_id: moment.moment_id,
                    moment_content: moment.moment_content,
                    moment_address: moment.moment_address,
                    latitude: moment.latitude,
                    longitude: moment.longitude,
                    created_at: moment.created_at,
                    moment_type: moment.moment_type,
                    is_public: moment.is_public,
                    category: category || null,
                    user: user || null,
                    media: media
                };
            })
        );

        return {
            metadata: paginator.getMetadata(totalRecords),
            moments: result
        };
    } catch (error) {
        console.error('Error fetching personal moments:', error);
        throw error;
    }
};

async function getMomentDetailById(moment_id) {
    try {
        const moment = await momentRepository()
            .where('moment_id', moment_id)
            .first();

        if (!moment) return null;

        const media = await mediaRepository()
            .where('moment_id', moment_id)
            .select('media_id','media_url');

        const user = await knex('users')
            .where('u_id', moment.u_id)
            .select('u_id', 'u_name', 'u_avt')
            .first();

        const category = await knex('category')
            .where('category_id', moment.category_id)
            .select('category_id', 'category_name')
            .first();

        return {
            ...moment,
            media,
            author: user || null,
            category: category || null
        };
    } catch (error) {
        console.error('Error fetching moment detail:', error);
        throw error;
    }
};

async function updateMoment(moment_id, user_id, data, files = []) {
    return await knex.transaction(async trx => {
        const existing = await trx('moment').where({ moment_id, u_id: user_id }).first();
        if (!existing) return null;

        const updated = {
            moment_content: data.moment_content,
            moment_type: data.moment_type,
            is_public: data.is_public,
            category_id: data.category_id,
            moment_address: data.moment_address,
            latitude: data.latitude,
            longitude: data.longitude,
            updated_at: knex.fn.now(),
        };

        Object.keys(updated).forEach((key) => {
            if (updated[key] === undefined || updated[key] === null) {
                delete updated[key];
            }
        });

        await trx('moment').where({ moment_id }).update(updated);

        // 1. Delete old media by media_id if provided
        const mediaIdsToDelete = data.media_ids_to_delete;
        let normalizedDeleteList = [];

        if (mediaIdsToDelete) {
            if (Array.isArray(mediaIdsToDelete)) {
                normalizedDeleteList = mediaIdsToDelete.map(id => parseInt(id)).filter(id => !isNaN(id));
            } else if (typeof mediaIdsToDelete === 'string') {
                const parsed = parseInt(mediaIdsToDelete);
                if (!isNaN(parsed)) {
                    normalizedDeleteList = [parsed];
                }
            } else if (typeof mediaIdsToDelete === 'number') {
                normalizedDeleteList = [mediaIdsToDelete];
            }
        }

        console.log('Media IDs to delete:', normalizedDeleteList); // Debug log

        if (normalizedDeleteList.length > 0) {
            // First, check what media exists for this moment (for security)
            const existingMedia = await trx('media')
                .where({ moment_id })
                .whereIn('media_id', normalizedDeleteList)
                .select('media_id', 'media_url');

            console.log('Existing media to delete:', existingMedia); // Debug log

            // Delete the media by media_id
            const deleteResult = await trx('media')
                .where({ moment_id }) // Ensure we only delete media from this moment
                .whereIn('media_id', normalizedDeleteList)
                .del();

            console.log('Delete result:', deleteResult, 'rows deleted'); // Debug log
        }

        // 2. Add new images if any
        if (files && files.length > 0) {
            const mediaRecords = files.map(file => ({
                moment_id,
                media_url: `/public/uploads/${file.filename}`,
            }));
            await trx('media').insert(mediaRecords);
        }

        // 3. Return updated data with media_urls and media_ids
        const updatedMedia = await trx('media')
            .where({ moment_id })
            .select('media_id', 'media_url');

        delete updated.updated_at;

        return {
            moment_id,
            ...updated,
            media_urls: updatedMedia.map(m => m.media_url),
            media: updatedMedia // Include both media_id and media_url for frontend
        };
    });
};

async function deleteMoment(moment_id, user_id) {
    const moment = await momentRepository().where({ moment_id, u_id: user_id }).first();

    if (!moment) return null;

    await mediaRepository().where({ moment_id }).del();
    await momentRepository().where({ moment_id }).del();

    return moment;
};

module.exports = {
    createMoment,
    getMomentDetailById,
    getPublicMomentsByUserId,
    getAllPublicMoments,
    getAllMyMoments,
    updateMoment,
    deleteMoment
};