CREATE DATABASE IF NOT EXISTS pos_db;
USE pos_db;

-- ==========================================
-- 1. CLEANUP (Drop existing tables in correct order)
-- ==========================================
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS categories;

-- ==========================================
-- 2. TABLE CREATION
-- ==========================================

-- CATEGORIES TABLE
CREATE TABLE categories (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- USERS TABLE
CREATE TABLE users (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    user_name  VARCHAR(100) NOT NULL,
    password   VARCHAR(255) NOT NULL, -- Plaintext for dev; hash this in production!
    role       ENUM('admin', 'sale') NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- PRODUCTS TABLE
CREATE TABLE products (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    price        DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    stock        INT NOT NULL DEFAULT 0,  
    category_id  INT NOT NULL,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- ORDERS TABLE
CREATE TABLE orders (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT NOT NULL,
    total      DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    status     ENUM('pending', 'completed') DEFAULT 'completed',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- ORDER ITEMS TABLE
CREATE TABLE order_items (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    order_id     INT NOT NULL,
    product_id   INT NULL,              -- Set to NULL if product is deleted from catalog
    product_name VARCHAR(150) NOT NULL, -- <--- FIXED: Saves the name forever for receipts!
    quantity     INT NOT NULL DEFAULT 1,
    unit_price   DECIMAL(10, 2) NOT NULL,
    subtotal     DECIMAL(10, 2) NOT NULL, 
    FOREIGN KEY (order_id)   REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL 
);

-- ==========================================
-- 3. SEED INITIAL DATA
-- ==========================================

INSERT INTO categories (id, category_name) VALUES 
(1, 'Electronics'), (2, 'Food'), (3, 'Clothing'), (4, 'Drink');

INSERT INTO users (user_name, password, role) VALUES
('Hak Zin2', '123', 'admin'),
('Tha Bczin', '123', 'sale'),
('Vid Smos',  '123', 'sale'),
('Heang Sava','123', 'sale');

INSERT INTO products (id, product_name, price, stock, category_id) VALUES
(1, 'USB-C Hub', 25.99, 50, 1),
(2, 'Wireless Mouse', 15.49, 80, 1),
(3, 'Coffee Beans', 9.99, 200, 4),
(4, 'Plain T-Shirt', 7.99, 150, 3);

SELECT * FROM categories;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM users;
