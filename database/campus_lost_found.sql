-- =========================================================
--  Campus Lost-and-Found Management Portal
--  Database creation script (MySQL 8.x)
-- =========================================================
DROP DATABASE IF EXISTS campus_lost_found;
CREATE DATABASE campus_lost_found;
USE campus_lost_found;

-- Table 1: users
CREATE TABLE users (
    user_id    INT AUTO_INCREMENT PRIMARY KEY,
    full_name  VARCHAR(100) NOT NULL,
    email      VARCHAR(100) NOT NULL UNIQUE,
    password   VARCHAR(255) NOT NULL,          -- SHA-256 hash
    mobile     VARCHAR(15),
    user_role  VARCHAR(20)  NOT NULL DEFAULT 'USER'   -- USER or ADMIN
);

-- Table 2: items
CREATE TABLE items (
    item_id      INT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT          NOT NULL,
    item_name    VARCHAR(100) NOT NULL,
    category     VARCHAR(50)  NOT NULL,
    description  TEXT,
    report_type  VARCHAR(10)  NOT NULL,         -- Lost or Found
    location     VARCHAR(150) NOT NULL,
    report_date  DATE         NOT NULL,
    status       VARCHAR(30)  NOT NULL DEFAULT 'Open',  -- Open, Claim Pending, Closed
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Table 3: claims
CREATE TABLE claims (
    claim_id           INT AUTO_INCREMENT PRIMARY KEY,
    item_id            INT  NOT NULL,
    user_id            INT  NOT NULL,
    ownership_details  TEXT NOT NULL,
    claim_date         DATE NOT NULL,
    claim_status       VARCHAR(30) NOT NULL DEFAULT 'Pending', -- Pending, Approved, Rejected
    admin_remarks      TEXT,
    UNIQUE KEY uq_claim_once (item_id, user_id),               -- PRD 6.3: one claim per user per item
    FOREIGN KEY (item_id) REFERENCES items(item_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Stored procedure used by the admin dashboard (CallableStatement demo)
DELIMITER //
CREATE PROCEDURE sp_item_summary(OUT total INT, OUT lost INT, OUT found INT,
                                 OUT closed INT, OUT pending INT)
BEGIN
    SELECT COUNT(*) INTO total  FROM items;
    SELECT COUNT(*) INTO lost   FROM items WHERE report_type = 'Lost';
    SELECT COUNT(*) INTO found  FROM items WHERE report_type = 'Found';
    SELECT COUNT(*) INTO closed FROM items WHERE status = 'Closed';
    SELECT COUNT(*) INTO pending FROM claims WHERE claim_status = 'Pending';
END //
DELIMITER ;

-- Sample data
-- admin@campus.edu / admin123     student@campus.edu / user123
INSERT INTO users (full_name, email, password, mobile, user_role) VALUES
('Portal Admin', 'admin@campus.edu',
 '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', '9000000001', 'ADMIN'),
('Rahul Kumar', 'student@campus.edu',
 'e606e38b0d8c19b24cf0ee3808183162ea7cd63ff7912dbb22b5e803286b4446', '9000000002', 'USER');

INSERT INTO items (user_id, item_name, category, description, report_type, location, report_date, status) VALUES
(2, 'Black HP Laptop Bag', 'Accessories', 'Black bag with HP logo, has a charger inside', 'Lost', 'MCA Lab 2', '2026-11-02', 'Open'),
(2, 'College ID Card', 'Identity Cards', 'ID card found near the canteen counter', 'Found', 'Main Canteen', '2026-11-04', 'Open'),
(2, 'Java Complete Reference Book', 'Books', 'Herbert Schildt, 12th edition, name written inside', 'Lost', 'Central Library', '2026-11-05', 'Open');
