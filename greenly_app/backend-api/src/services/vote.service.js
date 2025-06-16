const knex = require('../database/knex');
function voteRepository() {
    return knex('vote');
};

async function voteMoment(moment_id, u_id, vote_state) {
    const existing = await voteRepository()
        .where({ moment_id, u_id })
        .first();

    if (!existing) {
        // Chưa vote → tạo mới
        await voteRepository().insert({ moment_id, u_id, vote_state });
    } else if (existing.vote_state === vote_state) {
        // Bấm lại cùng trạng thái (like hoặc unlike) → bỏ vote
        await voteRepository()
            .where({ moment_id, u_id })
            .del();
    } else {
        // Đổi trạng thái (like <-> unlike)
        await voteRepository()
            .where({ moment_id, u_id })
            .update({ vote_state });
    }

    // Trả tổng số like & unlike hiện tại
    const [likeCount] = await voteRepository()
        .where({ moment_id, vote_state: true })
        .count('* as likes');

    const [unlikeCount] = await voteRepository()
        .where({ moment_id, vote_state: false })
        .count('* as unlikes');

    return {
        likes: likeCount.likes,
        unlikes: unlikeCount.unlikes
    };
}

module.exports = {
    voteMoment
}