const express = require("express");
const cors = require("cors");
const app = express();
const bodyParser = require('body-parser');
// Check connection
require('./database/dbHealthCheck')();
const JSend = require("./jsend");

// Routes
const usersRouter = require('./routes/user.router')

const {
    resourceNotFound,
    handleError,
} = require('./controllers/errors.controller');

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}));

app.get("/", (req, res) => {
    return res.json(JSend.success());
});
const {specs, swaggerUi} = require('./docs/swagger');

app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs)); 
app.use('/public', express.static('public'));

usersRouter.setup(app);

// Handle 404 response
app.use(resourceNotFound);

app.use(handleError);
module.exports = app;
