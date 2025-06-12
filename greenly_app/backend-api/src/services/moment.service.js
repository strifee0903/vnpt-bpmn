const knex = require('../database/knex');
const ApiError = require('../api-error');

// Repository function to abstract the table
function momentRepository() {
    return knex('moment');
}

function categoryRepository() {
    return knex('category');
}

function readMoment(payload) {
    const moment =  {
        moment_id: payload.moment_id,
        u_id: payload.u_id,
        moment_content: payload.moment_content,
        moment_img: payload.moment_img,
        moment_address: payload.moment_address,
        category_id: payload.category_id,
    };
    // Remove undefined/null values
    Object.keys(moment).forEach(key => {
        if (moment[key] === undefined || moment[key] === null) {
            delete moment[key];
        }
    });
    return moment;
}