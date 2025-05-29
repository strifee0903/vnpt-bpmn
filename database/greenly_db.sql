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
    u_name VARCHAR(100) not null,
    u_birthday DATE,
    u_address VARCHAR(255) not null,
    u_email VARCHAR(255) not null unique,
    u_pass text not null,
    is_verified int(11) not null,
    u_avt varchar(500),
    last_login timestamp,
    created_at timestamp,
    updated_at timestamp,
    FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

-- ========================================
-- BẢNG accounts: Thông tin đăng nhập tài khoản
-- ========================================
-- CREATE TABLE accounts (
--     acc_id INT PRIMARY KEY AUTO_INCREMENT,
--     u_id INT,
--     acc_name VARCHAR(100) UNIQUE,
--     acc_pass VARCHAR(255),
--     FOREIGN KEY (u_id) REFERENCES users(u_id)
-- );

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
    u_id INT, -- tài khoản đăng bài
    moment_content TEXT, -- nội dung chia sẻ hành động
    moment_img VARCHAR(255), -- ảnh đại diện chính của bài (tuỳ chọn)
    moment_address VARCHAR(255), -- địa điểm thực hiện hành động
    category_id INT, -- loại hành động (vd: nhặt rác, trồng cây, v.v.)
    FOREIGN KEY (u_id) REFERENCES users(u_id),
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
    moment_id INT,
    vote_state BOOLEAN, -- true: like, false: dislike
    u_id INT,
    FOREIGN KEY (moment_id) REFERENCES moment(moment_id),
     FOREIGN KEY (u_id) REFERENCES users(u_id),
    primary key(moment_id, u_id)
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
    u_id INT,
    eco_point INT,
    FOREIGN KEY (time_id) REFERENCES times(time_id),
	FOREIGN KEY (u_id) REFERENCES users(u_id)
);

-- ========================================
-- BẢNG diary: Nhật ký hoạt động phân loại rác / hành động vì môi trường
-- ========================================
CREATE TABLE diary (
    diary_id INT PRIMARY KEY AUTO_INCREMENT,
    u_id INT,
    diary_category VARCHAR(100), -- ví dụ: "phân loại rác", "không dùng nhựa"
    state ENUM('not started', 'in progress', 'completed'), 
	FOREIGN KEY (u_id) REFERENCES users(u_id)
);

-- ========================================
-- BẢNG campaign: Quản lý chiến dịch môi trường lớn
-- ========================================
CREATE TABLE campaign (
    campaign_id INT PRIMARY KEY AUTO_INCREMENT,
    u_id INT, -- người khởi tạo chiến dịch
    title VARCHAR(255),
    description TEXT,
    location VARCHAR(255),
    start_date DATE,
    end_date DATE,
    status ENUM('not started', 'in progress', 'completed'), 
	FOREIGN KEY (u_id) REFERENCES users(u_id)
);

-- ========================================
-- BẢNG participation: Theo dõi người dùng tham gia chiến dịch
-- ========================================
CREATE TABLE participation (
    participation_id INT PRIMARY KEY AUTO_INCREMENT,
    campaign_id INT,       -- ID chiến dịch
    u_id INT,            -- ID tài khoản người tham gia
    joined_at DATETIME,    -- Thời điểm tham gia
    FOREIGN KEY (campaign_id) REFERENCES campaign(campaign_id),
	FOREIGN KEY (u_id) REFERENCES users(u_id)
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


-- Table for processes
CREATE TABLE processes (
    process_id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(255),
    xml_content TEXT
);

-- Table for steps (tasks, events, gateways, etc.)
CREATE TABLE steps (
    step_id VARCHAR(100) PRIMARY KEY,
    process_id VARCHAR(100),
    name VARCHAR(255),
    type VARCHAR(50), -- e.g., startEvent, task, endEvent, exclusiveGateway
    FOREIGN KEY (process_id) REFERENCES processes(process_id)
);

-- Table for flows (sequence flows, message flows, etc.)
CREATE TABLE flows (
    flow_id VARCHAR(100) PRIMARY KEY,
    process_id VARCHAR(100),
    source_ref VARCHAR(100),
    target_ref VARCHAR(100),
    type VARCHAR(50), -- e.g., sequenceFlow, messageFlow
    FOREIGN KEY (process_id) REFERENCES processes(process_id),
    FOREIGN KEY (source_ref) REFERENCES steps(step_id),
    FOREIGN KEY (target_ref) REFERENCES steps(step_id)
);

-- Table for custom properties (e.g., magic:spell)
CREATE TABLE custom_properties (
    id INT AUTO_INCREMENT PRIMARY KEY,
    step_id VARCHAR(100),
    property_name VARCHAR(100),
    property_value TEXT,
    FOREIGN KEY (step_id) REFERENCES steps(step_id)
);

/***********************************************************************************************************/
INSERT INTO roles (role_name) VALUES 
('admin'), ('user'), ('moderator');

INSERT INTO users (role_id, u_name, u_birthday, u_address) VALUES
(1, 'Alice Nguyen', '1995-06-15', '123 Green St, Can Tho'),
(2, 'Bob Tran', '1998-03-22', '456 Eco Ave, HCMC'),
(3, 'Charlie Le', '1990-09-01', '789 Recycle Rd, Hanoi'),
(2, 'Duyen Pham', '2000-01-01', '101 River St, Da Nang'),
(1, 'Emily Dao', '1985-12-12', '202 Forest Ln, Hue'),
(3, 'Frank Vu', '1992-07-07', '303 Ocean Dr, Nha Trang'),
(2, 'Giang Ho', '2002-08-08', '404 Bamboo Way, Haiphong'),
(1, 'Helen Bui', '1999-05-05', '505 Lotus St, Dalat'),
(2, 'Ivy Vo', '1993-11-11', '606 Solar Blvd, Vung Tau'),
(3, 'Jacky Ngo', '1997-04-04', '707 Wind Rd, Bien Hoa');

-- INSERT INTO accounts (u_id, acc_name, acc_pass) VALUES
-- (1, 'alice123', 'passAlice'),
-- (2, 'bobtran', 'bobpass'),
-- (3, 'cle1990', 'charliepass'),
-- (4, 'duyen01', 'duyenpass'),
-- (5, 'emilydao', 'emilypass'),
-- (6, 'fvu92', 'frankpass'),
-- (7, 'g_ho', 'giangpass'),
-- (8, 'hbui', 'helenpass'),
-- (9, 'ivyvo', 'ivypass'),
-- (10, 'jackyn', 'jackypass');

INSERT INTO category (category_name) VALUES
('Nhặt rác'),
('Trồng cây'),
('Tái chế'),
('Tiết kiệm điện'),
('Không dùng nhựa'),
('Chia sẻ kiến thức môi trường'),
('Đi xe đạp'),
('Sử dụng năng lượng mặt trời'),
('Sống xanh'),
('Làm sạch bãi biển');

INSERT INTO moment (acc_id, moment_content, moment_img, moment_address, category_id) VALUES
(1, 'Tôi vừa hoàn thành việc nhặt rác tại công viên.', 'img1.jpg', 'Công viên Lê Văn Tám', 1),
(2, 'Chúng tôi đã trồng 5 cây xanh ở sân trường.', 'img2.jpg', 'Trường Đại học Cần Thơ', 2),
(3, 'Tái chế chai nhựa thành chậu cây.', 'img3.jpg', 'Nhà riêng', 3),
(4, 'Hạn chế sử dụng máy lạnh để tiết kiệm điện.', NULL, 'Văn phòng', 4),
(5, 'Sử dụng bình nước cá nhân thay vì chai nhựa.', 'img4.jpg', 'Ký túc xá', 5),
(6, 'Chia sẻ thông tin về phân loại rác.', NULL, 'Online', 6),
(7, 'Đi xe đạp đi làm thay vì dùng xe máy.', 'img5.jpg', 'Đường Nguyễn Văn Cừ', 7),
(8, 'Lắp đặt pin mặt trời trên mái nhà.', 'img6.jpg', 'Thủ Đức', 8),
(9, 'Sống xanh bằng cách trồng rau sạch.', NULL, 'Ban công nhà', 9),
(10, 'Tham gia làm sạch bãi biển cùng nhóm tình nguyện.', 'img7.jpg', 'Bãi biển Cần Giờ', 10);

INSERT INTO vote (moment_id, vote_state, acc_id) VALUES
(1, TRUE, 2),
(1, TRUE, 3),
(2, TRUE, 1),
(2, FALSE, 4),
(3, TRUE, 5),
(3, TRUE, 6),
(4, TRUE, 7),
(5, FALSE, 8),
(6, TRUE, 9),
(7, TRUE, 10);
