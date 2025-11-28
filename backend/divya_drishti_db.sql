-- Create Database
CREATE DATABASE IF NOT EXISTS divya_drishti_db;
USE divya_drishti_db;

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    phone VARCHAR(15) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    dob DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    address TEXT NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- OTP Table for phone verification
CREATE TABLE IF NOT EXISTS otps (
    id INT AUTO_INCREMENT PRIMARY KEY,
    phone VARCHAR(15) NOT NULL,
    otp_code VARCHAR(6) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_otps_phone ON otps(phone);
CREATE INDEX idx_otps_expires ON otps(expires_at);
CREATE INDEX idx_otps_used ON otps(used);

-- Insert sample user data for testing (optional)
-- Password: 123456 (hashed)
INSERT INTO users (phone, name, dob, gender, address, password) VALUES 
('9876543210', 'Rahul Sharma', '1990-05-15', 'Male', '123 Main Street, Mumbai, Maharashtra', '$2b$12$LQv3c1yqBWVHxkd0g8f7QuYlY4tC9tR8cY9jHkLmNpQrS7tVwXyZa'),
('8765432109', 'Priya Patel', '1992-08-22', 'Female', '456 Oak Avenue, Delhi, Delhi', '$2b$12$LQv3c1yqBWVHxkd0g8f7QuYlY4tC9tR8cY9jHkLmNpQrS7tVwXyZa'),
('7654321098', 'Amit Kumar', '1988-12-10', 'Male', '789 Pine Road, Bangalore, Karnataka', '$2b$12$LQv3c1yqBWVHxkd0g8f7QuYlY4tC9tR8cY9jHkLmNpQrS7tVwXyZa');

-- Display table structure
DESCRIBE users;
DESCRIBE otps;

-- Show sample data
SELECT * FROM users;
SELECT * FROM otps;