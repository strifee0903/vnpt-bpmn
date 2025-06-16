const knex = require('../database/knex');
const campaignRepository = () => knex('campaign');
const momentRepository = () => knex('moment');

async function createCampaign(u_id, data) {
    return await knex.transaction(async trx => {
        // 1. Tạo chiến dịch
        const campaign = {
            u_id,
            title: data.title,
            description: data.description,
            location: data.location,
            start_date: data.start_date,
            end_date: data.end_date,
            status: 'not started',
        };

        const [campaign_id] = await trx('campaign').insert(campaign);

        // 2. Tạo moment tương ứng
        const moment = {
            u_id,
            moment_content: `${data.title}\n\n${data.description}`,
            moment_address: data.location,
            moment_type: 'event', // giả sử
            is_public: true,
            category_id: data.category_id || null, // nếu có
        };

        const [moment_id] = await trx('moment').insert(moment);

        return { campaign_id, moment_id };
    });
}
module.exports={
    createCampaign,
}