const knex = require('../database/knex');
const ApiError = require('../api-error');

function categoryRepository() {
    return knex('category');
}

function readCategory(payload) {
    const category = {
        category_id: payload.category_id,
        category_name: payload.category_name,
    };
    Object.keys(category).forEach(key => {
        if (category[key] === undefined || category[key] === null) {
            delete category[key];
        }
    });
    return category;
}

async function createCategory(payload) {
    const category = readCategory(payload);
    return await knex.transaction(async trx => {
        const existingName = await trx('category')
            .where('category_name', category.category_name)
            .first();
        if (existingName) {
            return {
                message: 'This category existed!'
            };
        }
        const [category_id] = await trx('category').insert(category);
        return {
            message: 'The category created successfully!',
            data: { category_id, ...category }
        };
    });
};

async function deleteCategory(id) {
    const deleteCategory = await categoryRepository().where({ category_id: id }).first();
    if (!deleteCategory) {
        return null;
    }

    await categoryRepository().where({ category_id: id }).del();
    return deleteCategory;
};

module.exports = {
    createCategory,
    deleteCategory,
};
