CREATE DATABASE greenly_db;
USE greenly_db;

-- ========================================
-- XÓA CÁC BẢNG NẾU ĐÃ TỒN TẠI
-- ========================================
-- DROP TABLE IF EXISTS notification;
-- DROP TABLE IF EXISTS participation;
-- DROP TABLE IF EXISTS campaign;
-- DROP TABLE IF EXISTS diary;
-- DROP TABLE IF EXISTS contribution;
-- DROP TABLE IF EXISTS times;
-- DROP TABLE IF EXISTS vote;
-- DROP TABLE IF EXISTS media;
-- DROP TABLE IF EXISTS moment;
-- DROP TABLE IF EXISTS accounts;
-- DROP TABLE IF EXISTS users;
-- DROP TABLE IF EXISTS roles;
-- DROP TABLE IF EXISTS category;

-- ========================================
-- BẢNG roles: Lưu vai trò người dùng (admin, user, moderator)
-- ========================================
CREATE TABLE roles (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    role_name ENUM('admin', 'user', 'moderator') NOT NULL
);

-- ========================================
-- BẢNG users: Thông tin cá nhân người dùng
-- ========================================
CREATE TABLE users (
    u_id INT PRIMARY KEY AUTO_INCREMENT,
    role_id INT,
    u_name VARCHAR(100),
    u_birthday DATE,
    u_address VARCHAR(255),
    FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

-- ========================================
-- BẢNG accounts: Thông tin đăng nhập tài khoản
-- ========================================
CREATE TABLE accounts (
    acc_id INT PRIMARY KEY AUTO_INCREMENT,
    u_id INT,
    acc_name VARCHAR(100) UNIQUE,
    acc_pass VARCHAR(255),
    FOREIGN KEY (u_id) REFERENCES users(u_id)
);

-- ========================================
-- BẢNG category: Phân loại các hành động vì môi trường
-- ========================================
CREATE TABLE category (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100)
);

-- ========================================
-- BẢNG moment: Bài đăng hành động vì môi trường của người dùng
-- Một moment là một bài đăng có thể đính kèm nhiều ảnh hoặc video.
-- Mỗi moment liên kết đến 1 tài khoản và 1 loại hành động (category).
-- moment không chứa media_id vì một moment có thể có nhiều media (1-n)
-- ========================================
CREATE TABLE moment (
    moment_id INT PRIMARY KEY AUTO_INCREMENT,
    acc_id INT, -- tài khoản đăng bài
    moment_content TEXT, -- nội dung chia sẻ hành động
    moment_img VARCHAR(255), -- ảnh đại diện chính của bài (tuỳ chọn)
    moment_address VARCHAR(255), -- địa điểm thực hiện hành động
    category_id INT, -- loại hành động (vd: nhặt rác, trồng cây, v.v.)
    FOREIGN KEY (acc_id) REFERENCES accounts(acc_id),
    FOREIGN KEY (category_id) REFERENCES category(category_id)
);

-- ========================================
-- BẢNG media: Ảnh hoặc video đính kèm bài đăng moment
-- Mỗi media thuộc về một moment (1-n).
-- media chứa moment_id để biết nó thuộc bài đăng nào.
-- ========================================
CREATE TABLE media (
    media_id INT PRIMARY KEY AUTO_INCREMENT,
    moment_id INT, -- bài đăng mà media này thuộc về
    media_url VARCHAR(255), -- đường dẫn tới file ảnh/video
    FOREIGN KEY (moment_id) REFERENCES moment(moment_id)
);

-- ========================================
-- BẢNG vote: Lượt đánh giá (like/dislike) cho moment
-- ========================================
CREATE TABLE vote (
    vote_id INT PRIMARY KEY AUTO_INCREMENT,
    moment_id INT,
    vote_state BOOLEAN, -- true: like, false: dislike
    acc_id INT,
    FOREIGN KEY (moment_id) REFERENCES moment(moment_id),
    FOREIGN KEY (acc_id) REFERENCES accounts(acc_id)
);

-- ========================================
-- BẢNG times: Quản lý thời gian đóng góp để chấm điểm
-- ========================================
CREATE TABLE times (
    time_id INT PRIMARY KEY AUTO_INCREMENT,
    date DATE
);

-- ========================================
-- BẢNG contribution: Ghi nhận điểm đóng góp người dùng theo ngày
-- ========================================
CREATE TABLE contribution (
    contr_id INT PRIMARY KEY AUTO_INCREMENT,
    time_id INT,
    acc_id INT,
    eco_point INT,
    FOREIGN KEY (time_id) REFERENCES times(time_id),
    FOREIGN KEY (acc_id) REFERENCES accounts(acc_id)
);

-- ========================================
-- BẢNG diary: Nhật ký hoạt động phân loại rác / hành động vì môi trường
-- ========================================
CREATE TABLE diary (
    diary_id INT PRIMARY KEY AUTO_INCREMENT,
    acc_id INT,
    diary_category VARCHAR(100), -- ví dụ: "phân loại rác", "không dùng nhựa"
    state ENUM('not started', 'in progress', 'completed'), 
    FOREIGN KEY (acc_id) REFERENCES accounts(acc_id)
);

-- ========================================
-- BẢNG campaign: Quản lý chiến dịch môi trường lớn
-- ========================================
CREATE TABLE campaign (
    campaign_id INT PRIMARY KEY AUTO_INCREMENT,
    acc_id INT, -- người khởi tạo chiến dịch
    title VARCHAR(255),
    description TEXT,
    location VARCHAR(255),
    start_date DATE,
    end_date DATE,
    status ENUM('not started', 'in progress', 'completed'), 
    FOREIGN KEY (acc_id) REFERENCES accounts(acc_id)
);

-- ========================================
-- BẢNG participation: Theo dõi người dùng tham gia chiến dịch
-- ========================================
CREATE TABLE participation (
    participation_id INT PRIMARY KEY AUTO_INCREMENT,
    campaign_id INT,       -- ID chiến dịch
    acc_id INT,            -- ID tài khoản người tham gia
    joined_at DATETIME,    -- Thời điểm tham gia
    FOREIGN KEY (campaign_id) REFERENCES campaign(campaign_id),
    FOREIGN KEY (acc_id) REFERENCES accounts(acc_id)
);

-- ========================================
-- BẢNG notification: Gửi thông báo cho người dùng (ví dụ: được cộng điểm, nhắc nhở tham gia chiến dịch)
-- ========================================
-- CREATE TABLE notification (
--     notification_id INT PRIMARY KEY AUTO_INCREMENT,
--     acc_id INT,
--     content TEXT,
--     created_at DATETIME,
--     FOREIGN KEY (acc_id) REFERENCES accounts(acc_id)
-- );
