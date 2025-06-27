const e = require("express");
const knex = require("../database/knex");

const createContent = async (content) => {

    const { library_name, description, file } = content;

    return await knex.transaction(async (trx) => {
        await trx("library").insert({
            library_name,
            description,
            file    
        });

        return {
            library_name,
            description,
            file
        };
    
    });
};

const getContentById = async (library_id) => {
    const content = await knex("library").where({ library_id }).first();
    if (!content) {
        throw new Error(`Content with id ${library_id} not found`);
    };
    return content;
}

const getAllContent = async() => {
    const content = await knex("library").select("*");
    return content;
};

const updateContent = async (library_id, content) => {
    const { library_name, description, file } = content;

    return await knex("library")
        .where({ library_id })
        .update({
            library_name,
            description,
            file
        });
};

const deleteDocument = async (library_id) => {
    return await knex("library")
        .where({ library_id })
        .del();
};

module.exports = {
    createContent: createContent, 
    getContentById: getContentById,
    getAllContent: getAllContent,
    updateContent: updateContent,
    deleteDocument: deleteDocument,
}