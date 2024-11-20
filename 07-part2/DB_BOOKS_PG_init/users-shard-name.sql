CREATE DATABASE IF NOT EXISTS users_db;
USE users_db;





CREATE TABLE users_names (
    user_id uuid SMALLINT not null PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
);
CREATE TABLE user_authorization (
    user_id SMALLINT PRIMARY KEY,
    passwd VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
CREATE TABLE user_location (
    user_id SMALLINT PRIMARY KEY,
    str_address VARCHAR(200),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Процедура для проверки диапазона id при вставке
DELIMITER //
CREATE PROCEDURE insert_user(
    IN p_user_id INT,
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_password VARCHAR(20)
)
BEGIN
    IF p_user_id BETWEEN 1 AND 100 THEN
        START TRANSACTION;
        INSERT INTO users VALUES (p_user_id, p_name, p_password, p_registration_date);
        INSERT INTO user_security VALUES (p_user_id, p_password_hash, NOW());
        COMMIT;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User ID out of range for this shard';
    END IF;
END //
DELIMITER ;