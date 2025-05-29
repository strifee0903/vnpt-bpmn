const ApiError = require('../api-error');
const JSend = require('../jsend');
function methodNotAllowed(req, res, next) {
    if (req.route) {
        // Determine which HTTP methods are supported
        const httpMethods = Object.keys(req.route.methods)
            .filter((method) => method !== '_all')
            .map((method) => method.toUpperCase());
        return next(
            new ApiError(405, 'Method Not Allowed', {
                Allow: httpMethods.join(', '),
            })
        );
    }
    return next();
}
function resourceNotFound(req, res, next) {
    // Handler for unknown URL path.
    // Call next() to pass to the error handling function.
    return next(new ApiError(404, 'Resource not found'));
}
function handleError(error, req, res, next) {
    if (res.headersSent) {
        return next(error);
    }
    const statusCode = error.statusCode || 500;
    const message = error.message || "Internal Server Error";
    const data = error.headers || {}; 
    return res
        .status(statusCode)
        .set(error.headers || {})
        .json(statusCode >= 500 ? JSend.error(message, data) : JSend.fail(message, data));
}

module.exports = {
    methodNotAllowed,
    resourceNotFound,
    handleError,
};