const knex = require("../database/knex");
const JSend = require("../jsend");
require("dotenv").config();


const createBpmn = async (process) => {
    const treatment = await knex("Cach_Dieu_Tri")
        .select("CDT_ID", "CDT_ChiTiet", "Benh_ID", "CT_ID", "Thuoc_ID")
        .where(type === "benh" ? "Benh_ID" : "CT_ID", id);

}