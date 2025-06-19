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
        const result = await categoriesService.createCategory({
            ...req.body,
            category_image: req.file ? `/public/uploads/categories/${req.file.filename}` : '/public/images/default_category_img.jpg',
        });
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
};

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
};

async function getCategoryById(req, res, next) {

    const category_id = req.params.category_id; 
    if (!category_id) {
        return next(new ApiError(400, 'Category id is required'));
    }
    try {
        const category = await categoriesService.getCategoryById(category_id);
        if (!category) {
            return next(new ApiError(404, 'No category found!'));
        }
        return res.json(JSend.success({ category_info: category }));
    } catch (error) {
        console.error(error);
        return next(new ApiError(500, 'System error, please try again later.'));
    }
};

async function getAllCategories(req, res, next) {

    let result = {
        categories: [],
        metadata: {
            totalRecords: 0,
            firstPage: 1,
            lastPage: 1,
            page: 1,
            limit: 5,
        }
    };

    try {
        result = await categoriesService.getAllCategories(req.query);
    } catch (error) {
        console.error(error);
        return next(new ApiError(500, 'System error, please try again later.'));
    }

    return res.json(
        JSend.success({
            categories: result.categories,
            metadata: result.metadata,
        })
    );
};

async function updateCategory(req, res, next) {
    if (!req.session.user) {
        return next(new ApiError(401, 'Please log in to perform this task!'));
    }

    const userId = req.session.user.u_id;
    const userRole = await userService.checkRole(userId);

    if (userRole !== 1) {
        return next(new ApiError(403, 'Forbidden: You do not have permission to edit this information!'));
    }

    try {
        // Better check for req.body existence
        if (!req.body || Object.keys(req.body).length === 0) {
            return next(new ApiError(400, 'Data to update cannot be empty'));
        }

        const category_id = req.params.category_id;
        if (!category_id) {
            return next(new ApiError(400, 'Category ID is required'));
        }

        // Debug logs
        console.log('Request body:', req.body);
        console.log('Category ID to update:', category_id);

        const currentCategory = await categoriesService.getCategoryById(category_id);
        if (!currentCategory) {
            return next(new ApiError(404, 'Category not found'));
        }

        // Check if category_name exists in body and is different
        if (req.body.category_name && req.body.category_name !== currentCategory.category_name) {
            const existingCategory = await categoriesService.getCategoryByName(req.body.category_name);
            if (existingCategory) {
                return next(new ApiError(400, 'Category name already exists'));
            }
        }

        const updatedCategory = await categoriesService.updateCategory(category_id, {
            ...req.body,
            category_image: req.file ? `/public/uploads/categories/${req.file.filename}` : currentCategory.category_image,
        });
        if (!updatedCategory) {
            return next(new ApiError(404, 'Category not found'));
        }

        return res.json(JSend.success({ category: updatedCategory }));
    } catch (error) {
        console.error('Update category error:', error);
        return next(new ApiError(500, 'Error updating category'));
    }
}

module.exports = {
    createCategory,
    deleteCategory,
    getCategoryById,
    getAllCategories,
    updateCategory
};
