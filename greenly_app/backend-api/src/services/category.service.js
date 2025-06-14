const knex = require('../database/knex');
const Paginator = require('./paginator');


function categoryRepository() {
    return knex('category');
};

function readCategory(payload) {
    const category = {
        category_id: payload.category_id,
        category_name: payload.category_name,
        category_image: payload.category_image,
    };
    Object.keys(category).forEach(key => {
        if (category[key] === undefined || category[key] === null) {
            delete category[key];
        }
    });
    return category;
};

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

async function getCategoryById(category_id) {
    return categoryRepository().where('category_id', category_id).select('*').first();
};

async function getCategoryByName(category_name) {
    return categoryRepository().where('category_name', category_name).select('*').first();
};

async function getAllCategories(query) {
    const { category_name, page = 1, limit = 5 } = query;
    const paginator = new Paginator(page, limit);

    let results = await categoryRepository()
        .where((builder) => {
            if (category_name) {
                builder.where('category_name', 'like', `%${category_name}%`);
            }
        })
        .select(
            knex.raw('count(category_id) OVER() AS recordCount'),
            'category_id',
            'category_name',
            'category_image'
        )
        .limit(paginator.limit)
        .offset(paginator.offset);

    let totalRecords = 0;
    results = results.map((result) => {
        totalRecords = result.recordCount;
        delete result.recordCount;
        return result;
    });

    return {
        metadata: paginator.getMetadata(totalRecords),
        categories: results,
    };
};

async function updateCategory(category_id, payload) {
    const old = await categoryRepository()
        .where('category_id', category_id)
        .select("*")
        .first();
    if (!old) {
        return null;
    }

    const newCategory = {
        category_name: payload.category_name,
        category_image: payload.category_image,
    };

    if (!newCategory.category_image){
        delete newCategory.category_image; // Ensure category_image is not updated if it was not provided
    }

    // Add this debug log:
    console.log('Updating category:', { category_id, old, newCategory });

    await categoryRepository()
        .where({category_id: category_id})
        .update(newCategory);

    if(
        payload.category_image &&
        old.category_image &&
        payload.category_image !== old.category_image &&
        old.category_image.startsWith('/public/uploads/categories')
    ){
        unlink(`.${old.category_image}`, (err) => { });
    }

    const updatedCategory = await categoryRepository()
        .where('category_id', category_id)
        .select('*')
        .first();

    // return { ...old, ...newCategory };
    return updatedCategory;
};

module.exports = {
    createCategory,
    deleteCategory,
    getAllCategories,
    getCategoryById,
    getCategoryByName,
    updateCategory
};
