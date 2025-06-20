drop database greenly_db;
CREATE DATABASE greenly_db;
USE greenly_db;

-- ========================================
-- XÓA CÁC BẢNG NẾU ĐÃ TỒN TẠI
-- ========================================
DROP TABLE IF EXISTS moment;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS category;
DROP TABLE IF EXISTS moment;
DROP TABLE IF EXISTS media;

-- ========================================
-- BẢNG roles: Lưu vai trò người dùng (admin, user, moderator)
-- ========================================
CREATE TABLE roles (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    role_name ENUM('admin', 'user', 'moderator') NOT NULL
);
INSERT INTO roles (role_name) VALUES 
('admin'), ('user'), ('moderator');
select * from roles;

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
    is_verified TINYINT(1) not null,
    token text,
    u_avt varchar(500),
    last_login TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(role_id) on delete cascade
);
CREATE INDEX idx_users_email ON users(u_email);
select * from users;
update users set role_id=1 where u_email = 'ntthanhtamforwork@gmail.com';

-- ========================================
-- BẢNG category: Phân loại các hành động vì môi trường
-- ========================================
CREATE TABLE category (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) unique,
    category_image VARCHAR(255)
);
select * from category;


-- ========================================
-- BẢNG moment: Bài đăng hành động vì môi trường của người dùng
-- Một moment là một bài đăng có thể đính kèm nhiều ảnh hoặc video.
-- Mỗi moment liên kết đến 1 tài khoản và 1 loại hành động (category).
-- moment không chứa media_id vì một moment có thể có nhiều media (1-n)
-- ========================================
CREATE TABLE moment (
    moment_id INT PRIMARY KEY AUTO_INCREMENT,
    u_id INT,
    moment_content TEXT,
    moment_address VARCHAR(255) DEFAULT NULL, -- địa điểm theo tên (optional)
    latitude DOUBLE DEFAULT NULL,   -- tọa độ vĩ độ
    longitude DOUBLE DEFAULT NULL,  -- tọa độ kinh độ
	moment_type ENUM('diary', 'event', 'report') DEFAULT 'diary',
    is_public BOOLEAN DEFAULT TRUE, -- true: công khai; false: riêng tư
    category_id INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (u_id) REFERENCES users(u_id) on delete cascade,
    FOREIGN KEY (category_id) REFERENCES category(category_id) on delete cascade
);
select * from moment;
create view view_moments as 
	select 
		u.u_name, 
		m.moment_id, 
		m.moment_content,
        m.moment_address,
        m.latitude,
        m.longitude, 
		m.moment_type,
        m.is_public,
        m.created_at,
        m.updated_at,
        media.media_url
	from moment as m 
	join category as c on m.category_id = c.category_id
    join users as u on m.u_id = u.u_id
    join media on m.moment_id = media.moment_id;
    
select * from view_moments;
-- Truy vấn moment theo user
CREATE INDEX idx_moment_uid ON moment(u_id);

-- Truy vấn moment theo category (đếm, lọc)
CREATE INDEX idx_moment_category ON moment(category_id);

-- Tìm theo vị trí địa lý (latitude/longitude)
CREATE INDEX idx_moment_location ON moment(latitude, longitude);

-- Truy vấn nhanh bài công khai
CREATE INDEX idx_moment_public ON moment(is_public);

-- Truy vấn moment theo thời gian
CREATE INDEX idx_moment_created ON moment(created_at);


-- ========================================
-- BẢNG media: Ảnh hoặc video đính kèm bài đăng moment
-- Mỗi media thuộc về một moment (1-n).
-- media chứa moment_id để biết nó thuộc bài đăng nào.
-- ========================================
CREATE TABLE media (
    media_id INT PRIMARY KEY AUTO_INCREMENT,
    moment_id INT, -- bài đăng mà media này thuộc về
    media_url VARCHAR(255), -- đường dẫn tới file ảnh/video
    FOREIGN KEY (moment_id) REFERENCES moment(moment_id) on delete cascade
);
select * from media;
-- ========================================
-- BẢNG vote: Lượt đánh giá (like/dislike) cho moment
-- ========================================
CREATE TABLE vote (
    moment_id INT,
    vote_state BOOLEAN, -- true: like, false: dislike
    u_id INT,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (moment_id) REFERENCES moment(moment_id) on delete cascade,
	FOREIGN KEY (u_id) REFERENCES users(u_id) on delete cascade,
    primary key(moment_id, u_id)
);

select * from vote;
-- Đếm/truy vấn vote theo moment
CREATE INDEX idx_vote_moment ON vote(moment_id);

-- Đếm vote của user (nếu cần)
CREATE INDEX idx_vote_uid ON vote(u_id);

-- ========================================
-- BẢNG comment: Bình luận cho moment
-- ========================================
CREATE TABLE comment (
    comment_id INT PRIMARY KEY AUTO_INCREMENT,
    moment_id INT,
    u_id INT,
    content TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (moment_id) REFERENCES moment(moment_id) on delete cascade,
    FOREIGN KEY (u_id) REFERENCES users(u_id) on delete cascade
);

-- Tăng tốc truy vấn comment theo moment
CREATE INDEX idx_comment_moment ON comment(moment_id);

-- Tăng tốc truy vấn comment theo user (nếu cần)
CREATE INDEX idx_comment_uid ON comment(u_id);

-- ========================================
-- BẢNG contribution: Ghi nhận điểm đóng góp người dùng theo ngày
-- ========================================
CREATE TABLE contribution (
    contr_id INT PRIMARY KEY AUTO_INCREMENT,
    u_id INT,
    eco_point INT,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (time_id) REFERENCES times(time_id) on delete cascade,
	FOREIGN KEY (u_id) REFERENCES users(u_id) on delete cascade
);
-- ======= TABLE: contribution =======
-- Tìm contribution theo user hoặc ngày
CREATE INDEX idx_contribution_uid ON contribution(u_id);
CREATE INDEX idx_contribution_time ON contribution(time_id);

-- ======= TABLE: campaign =======
-- Tìm campaign theo user
CREATE INDEX idx_campaign_uid ON campaign(u_id);

-- ======= TABLE: participation =======
-- Tìm người tham gia theo campaign hoặc user
CREATE INDEX idx_participation_campaign ON participation(campaign_id);
CREATE INDEX idx_participation_uid ON participation(u_id);
-- ========================================
-- BẢNG diary: Nhật ký hoạt động phân loại rác / hành động vì môi trường
-- ========================================
-- CREATE TABLE diary (
--     diary_id INT PRIMARY KEY AUTO_INCREMENT,
--     u_id INT,
--     category_id INT, 
--     state ENUM('not started', 'in progress', 'completed'), 
-- 	FOREIGN KEY (u_id) REFERENCES users(u_id),
--     FOREIGN KEY (category_id) REFERENCES category(category_id)
-- );

-- ========================================
-- BẢNG campaign: Quản lý chiến dịch môi trường lớn
-- ========================================
CREATE TABLE campaign (
    campaign_id INT PRIMARY KEY AUTO_INCREMENT,
    category_id INT,
    u_id INT, -- người khởi tạo chiến dịch
    title VARCHAR(255),
    description TEXT,
    location VARCHAR(255),
    start_date DATE,
    end_date DATE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('not started', 'in progress', 'completed') default null, 
	FOREIGN KEY (u_id) REFERENCES users(u_id) on delete cascade,
    FOREIGN KEY (category_id) REFERENCES category(category_id) on delete cascade
);
select * from campaign;
-- ========================================
-- BẢNG participation: Theo dõi người dùng tham gia chiến dịch
-- ========================================
CREATE TABLE participation (
    participation_id INT PRIMARY KEY AUTO_INCREMENT,
    campaign_id INT,       -- ID chiến dịch
    u_id INT,            -- ID tài khoản người tham gia
    joined_at DATETIME,    -- Thời điểm tham gia
    status BOOLEAN DEFAULT 0,
    FOREIGN KEY (campaign_id) REFERENCES campaign(campaign_id),
	FOREIGN KEY (u_id) REFERENCES users(u_id)
);
select * from participation;

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
    step_id VARCHAR(100),
    process_id VARCHAR(100),
    name VARCHAR(255),
    type VARCHAR(50), -- e.g., startEvent, task, endEvent, exclusiveGateway
    FOREIGN KEY (process_id) REFERENCES processes(process_id),
    PRIMARY KEY (step_id, process_id)
);

-- Table for flows (sequence flows, message flows, etc.)
CREATE TABLE flows (
    flow_id VARCHAR(100),
    process_id VARCHAR(100),
    source_ref VARCHAR(100),
    target_ref VARCHAR(100),
    type VARCHAR(50), -- e.g., sequenceFlow, messageFlow
    FOREIGN KEY (process_id) REFERENCES processes(process_id),
    FOREIGN KEY (source_ref) REFERENCES steps(step_id),
    FOREIGN KEY (target_ref) REFERENCES steps(step_id),
    PRIMARY KEY (flow_id, process_id)
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

INSERT INTO moment (
    u_id,
    moment_content,
    moment_address,
    latitude,
    longitude,
    moment_type,
    is_public,
    category_id
) VALUES
-- Bài viết 1
(1, 'Hôm nay trời Cần Thơ thật đẹp!', 'Bến Ninh Kiều, Cần Thơ', 10.0340, 105.7882, 'diary', TRUE, 9),

-- Bài viết 2
(1, 'Tham gia sự kiện xanh tại công viên Lưu Hữu Phước.', 'Công viên Lưu Hữu Phước, Cần Thơ', 10.0355, 105.7800, 'event', TRUE, 4),

-- Bài viết 3
(1, 'Báo cáo tình trạng rác thải tại phường An Cư.', 'Phường An Cư, Ninh Kiều, Cần Thơ', 10.0400, 105.7850, 'report', FALSE, 3),

-- Bài viết 4
(1, 'Dạo chơi buổi sáng ở hồ Xáng Thổi.', 'Hồ Xáng Thổi, Cần Thơ', 10.0325, 105.7820, 'diary', TRUE, 2),

-- Bài viết 5
(1, 'Tham quan chợ nổi Cái Răng vào lúc bình minh.', 'Chợ nổi Cái Răng, Cần Thơ', 10.0100, 105.7650, 'event', TRUE,1);
INSERT INTO media (moment_id, media_url) VALUES
-- Media cho moment_id 1 (1 media)
(10, 'public/images/default_category_img.jpg'),

-- Media cho moment_id 2 (2 media)
(11, 'public/images/default_category_img_3.jpg'),
(11, 'public/images/default_category_img_2.jpg'),

-- Media cho moment_id 3 (1 media)
(12, 'public/images/default_category_img_2.jpg'),

-- Media cho moment_id 4 (2 media)
(13, 'public/images/default_category_img_3.jpg'),
(13, 'public/images/default_category_img_2.jpg'),

-- Media cho moment_id 5 (1 media)
(14, 'public/images/default_category_img_2.jpg');
