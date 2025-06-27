const express = require("express");
const cors = require("cors");
const app = express();
const bodyParser = require('body-parser');
const crypto = require('crypto');
const session = require('express-session');

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

const secretKey = crypto.randomBytes(32).toString('hex');
app.use(session({
    secret: secretKey,
    resave: false,              // Không lưu session nếu không thay đổi
    saveUninitialized: false,   // Không lưu session nếu chưa khởi tạo
    cookie: {
        maxAge: 1000 * 60 * 60 * 24 // Session tồn tại trong 1 ngày
    }
}));

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
const categoriesRouter = require('./routes/category.router');
const moment = require('./routes/moment.router');
const voteRouter = require('./routes/vote.router');
const campaignRouter = require('./routes/campaign.router');
const libraryRouter = require('./routes/library.router');

usersRouter.setup(app);
bpmnRouter.setup(app);
webRouter.setup(app);
categoriesRouter.setup(app);
moment.setup(app);
voteRouter.setup(app);
campaignRouter.setup(app);
libraryRouter.setup(app);

// Handle 404 response
app.use(resourceNotFound);
app.use(handleError);
module.exports = app;
