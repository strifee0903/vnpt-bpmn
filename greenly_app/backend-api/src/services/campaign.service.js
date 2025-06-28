const knex = require('../database/knex');
const Paginator = require('./paginator');

function campaignRepository() {
    return knex('campaign');
};

function participationRepository() {
    return knex('participation');
};

function messageRepository(){
    return knex('messages');
};

async function createCampaign(u_id, data) {
    return await knex.transaction(async trx => {
        const now = new Date();

        // 1. Tạo chiến dịch
        const campaign = {
            u_id,
            title: data.title,
            description: data.description,
            location: data.location,
            start_date: data.start_date,
            end_date: data.end_date,
            status: 'not started',
            category_id: data.category_id || null
        };

        const [campaign_id] = await trx('campaign').insert(campaign);

        // 2. Tạo moment tương ứng
        const moment = {
            u_id,
            moment_content: `${data.title}\n\n${data.description}`,
            moment_address: data.location,
            moment_type: 'event',
            is_public: true,
            category_id: data.category_id || null,
        };

        const [moment_id] = await trx('moment').insert(moment);

        // 3. Tự động join participation table (creator là host)
        await trx('participation').insert({
            u_id,
            campaign_id,
            status: 1,
            joined_at: now,
        });

        // 4. Tạo welcome message trong group chat
        const welcomeMessage = {
            campaign_id,
            sender_id: u_id,
            content: `Welcome to the campaign "${data.title}"! As the host, I've created this group chat for all participants to communicate and coordinate activities.`,
            created_at: now
        };

        await trx('messages').insert(welcomeMessage);

        return {
            campaign_id,
            moment_id,
            joined: true,
            message: 'Campaign created successfully! You are now the host and have joined the group chat.'
        };
    });
};

async function getAllCampaigns(query) {
    try {
        console.log('Getting all campaigns with query:', query);

        const { page = 1, limit = 5 } = query;
        const paginator = new Paginator(page, limit);

        console.log('Paginator settings:', { page: paginator.page, limit: paginator.limit, offset: paginator.offset });

        // First, let's test if the basic query works
        const testQuery = await knex('campaign').select('*').limit(1);
        console.log('Test query result:', testQuery);

        // Check if tables exist and can be joined
        const baseQuery = campaignRepository()
            .join('users', 'campaign.u_id', 'users.u_id')
            .select(
                'campaign.*',
                'users.u_name',
                'users.u_avt'
            )
            .orderBy('campaign.created_at', 'desc');

        console.log('Base query SQL:', baseQuery.toString());

        // Get total count first
        const totalRecordsQuery = knex('campaign')
            .join('users', 'campaign.u_id', 'users.u_id')
            .count('campaign.campaign_id as count')
            .first();

        console.log('Count query SQL:', totalRecordsQuery.toString());

        // Execute queries
        const totalRecordsResult = await totalRecordsQuery;
        console.log('Total records result:', totalRecordsResult);

        const totalRecords = parseInt(totalRecordsResult?.count || 0);
        console.log('Total records parsed:', totalRecords);

        const results = await baseQuery
            .offset(paginator.offset)
            .limit(paginator.limit);

        console.log('Results:', results);

        return {
            metadata: paginator.getMetadata(totalRecords),
            campaigns: results,
        };

    } catch (error) {
        console.error('Error in getAllCampaigns:', error);
        throw error;
    }
};

async function getCampaignById(campaign_id) {
    const campaign = await campaignRepository()
        .where({ campaign_id })
        .join('users', 'campaign.u_id', 'users.u_id')
        .select(
            'campaign.*',
            'users.u_name',
            'users.u_avt'
        )
        .first();

    return campaign || null;
};

async function joinCampaign(u_id, campaign_id) {
    // 1. Kiểm tra campaign có tồn tại không
    const campaign = await knex('campaign').where({ campaign_id }).first();
    if (!campaign) {
        throw new Error('Campaign not found');
    }

    // 2. Kiểm tra nếu user là host
    if (campaign.u_id === u_id) {
        throw new Error('Host cannot join their own campaign');
    }

    // 3. Kiểm tra trạng thái hiện tại
    const existing = await participationRepository().where({ u_id, campaign_id }).first();
    const now = new Date();

    if (!existing) {
        // Chưa từng tham gia -> join mới
        await participationRepository().insert({
            u_id,
            campaign_id,
            status: 1,
            joined_at: now,
        });
        return { joined: true, message: 'Joined campaign successfully' };
    } else if (existing.status === 0) {
        // Đã từng left -> join lại
        await participationRepository()
            .where({ u_id, campaign_id })
            .update({ status: 1, joined_at: now });
        return { joined: true, message: 'Rejoined campaign successfully' };
    } else {
        // Đã join rồi -> báo lỗi
        throw new Error('Already joined this campaign');
    }
};

async function leaveCampaign(u_id, campaign_id) {
    // 1. Kiểm tra campaign có tồn tại không
    const campaign = await knex('campaign').where({ campaign_id }).first();
    if (!campaign) {
        throw new Error('Campaign not found');
    }

    // 2. Kiểm tra nếu user là host
    if (campaign.u_id === u_id) {
        throw new Error('Host cannot leave their own campaign');
    }

    // 3. Kiểm tra trạng thái hiện tại
    const existing = await participationRepository().where({ u_id, campaign_id }).first();

    if (!existing) {
        throw new Error('Cannot leave - not joined yet');
    } else if (existing.status === 0) {
        throw new Error('Already left this campaign');
    } else {
        // Đang join -> thực hiện left
        const updated = await participationRepository()
            .where({ u_id, campaign_id })
            .update({ status: 0 });
        return { left: updated > 0, message: 'Left campaign successfully' };
    }
};

// async function getParticipants(campaign_id, query = {}) {
//     // Kiểm tra campaign có tồn tại không
//     const campaignExists = await knex('campaign').where({ campaign_id }).first();
//     if (!campaignExists) {
//         throw new Error('Campaign not found');
//     }

//     const { page = 1, limit = 10 } = query;
//     const paginator = new Paginator(page, limit);

//     // Lấy tổng số người tham gia
//     const totalRecordsQuery = await participationRepository()
//         .where({ campaign_id, status: 1 })
//         .count('participation_id as count')
//         .first();

//     const totalRecords = parseInt(totalRecordsQuery?.count || 0);

//     // Lấy danh sách người tham gia với phân trang
//     const participants = await participationRepository()
//         .where({ campaign_id, status: 1 })
//         .join('users', 'users.u_id', 'participation.u_id')
//         .select('users.u_id', 'users.u_name', 'users.u_avt', 'participation.joined_at')
//         .offset(paginator.offset)
//         .limit(paginator.limit);

//     return {
//         metadata: paginator.getMetadata(totalRecords),
//         participants
//     };
// };
async function getParticipants(campaign_id, query = {}) {
    // Kiểm tra campaign có tồn tại không
    const campaignExists = await knex('campaign').where({ campaign_id }).first();
    if (!campaignExists) {
        throw new Error('Campaign not found');
    }

    const { page = 1, limit = 10 } = query;
    const paginator = new Paginator(page, limit);

    // Lấy tổng số người tham gia
    const totalRecordsQuery = await participationRepository()
        .where({ campaign_id, status: 1 })
        .count('participation_id as count')
        .first();

    const totalRecords = parseInt(totalRecordsQuery?.count || 0);

    // Lấy danh sách người tham gia với phân trang
    const participants = await participationRepository()
        .where({ campaign_id, status: 1 })
        .join('users', 'users.u_id', 'participation.u_id')
        .select('users.u_id', 'users.u_name', 'users.u_avt', 'participation.joined_at', 'participation.status') // Thêm status
        .offset(paginator.offset)
        .limit(paginator.limit);

    console.log('Participants:', participants); // Log để kiểm tra dữ liệu trả về

    return {
        metadata: paginator.getMetadata(totalRecords),
        participants
    };
  }

module.exports={
    createCampaign,
    getAllCampaigns,
    getCampaignById,
    joinCampaign,
    leaveCampaign,
    getParticipants
}