const knex = require("../database/knex");
const JSend = require('../jsend');

const postProcess = async (req, res, next) => {
    const { id, name, xml } = req.body;
    try {
        const treatment = await knex("processes")
            .select("CDT_ID", "CDT_ChiTiet", "Benh_ID", "CT_ID", "Thuoc_ID")
            .where(type === "benh" ? "Benh_ID" : "CT_ID", id);

    }
    catch (errors) {

    }
}

module.exports = {

}

