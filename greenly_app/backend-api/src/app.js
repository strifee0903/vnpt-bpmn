const express = require("express");
const cors = require("cors");
const app = express();
const bodyParser = require('body-parser');

// Thiết lập view engine 
const path = require('path');
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Check connection
require('./database/dbHealthCheck')();
const JSend = require("./jsend");
const {
    resourceNotFound,
    handleError,
} = require("./controllers/errors.controller");

app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true })); 
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}));

app.get("/", (req, res) => {
    return res.json(JSend.success());
});
const { specs, swaggerUi } = require("./docs/swagger");

app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(specs));
app.use("/public", express.static("public"));

// Routes
const usersRouter = require('./routes/user.router')
const bpmnRouter = require("./routes/bpmn.router");
const webRouter = require('./routes/verification.router')

usersRouter.setup(app);
bpmnRouter.setup(app);
webRouter.setup(app);

// Handle 404 response
app.use(resourceNotFound);

app.use(handleError);
module.exports = app;
