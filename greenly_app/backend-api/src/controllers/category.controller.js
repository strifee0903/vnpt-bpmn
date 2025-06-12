const categoriesService = require('../services/category.service');
const userService = require ('../services/user.service');
const ApiError = require('../api-error');
const JSend = require('../jsend');

async function createCategory(req, res, next) {
    if (!req.session.user) {
        return next(new ApiError(401, 'Please log in to perform this task!'));
    }
    const userId = req.session.user.u_id;
    const userRole = await userService.checkRole(userId);

    if (userRole !== 1) { // Assuming role 1 is admin
        console.log("admin id: ", userId)
        return next(new ApiError(403, 'Forbidden:  You do not have permission to edit this information!'));
    }
    try {
        if (!req.body.category_name) {
            return next(new ApiError(400, 'Please fill in all information.'));
        }
        const result = await categoriesService.createCategory(req.body);
        return res
            .status(201)
            .json(JSend.success({ result, message: 'Category created successfully!' }));
    } catch (error) {
        console.error('Category creation error:', error);
        if (error.message === 'This category existed!') {
            return next(new ApiError(409, error.message));
        }
        return next(new ApiError(500, 'System error, please try again later.'));
    }
}

async function deleteCategory(req, res, next) {
    if (!req.session.user) {
        return next(new ApiError(401, 'Please log in to perform this task!'));
    }
    const userId = req.session.user.u_id;
    const userRole = await userService.checkRole(userId);

    if (userRole !== 1) { // Assuming role 1 is admin
        console.log("admin id: ", userId)
        return next(new ApiError(403, 'Forbidden:  You do not have permission to edit this information!'));
    }
    try {
        const id = req.params.id;
        const deleted = await categoriesService.deleteCategory(id);

        if (!deleted) {
            return next(new ApiError(404, `Unable to delete the category with the code ${id}`));
        }

        return res.json(JSend.success({ message: 'Deleted successfully!', data: deleted }));
    } catch (error) {
        console.error('Delete category error:', error);
        return next(new ApiError(500, 'System error, please try again later.'));
    }
}

module.exports = {
    createCategory,
    deleteCategory,
};
