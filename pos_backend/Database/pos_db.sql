CREATE DATABASE IF NOT EXISTS pos_db;
USE pos_db;


-- CATEGORIES TABLE

CREATE TABLE categories (
    id       INT AUTO_INCREMENT PRIMARY KEY,
    category_name     VARCHAR(100) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- USERS TABLE

CREATE TABLE users (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    user_name       VARCHAR(100) NOT NULL,
    password   VARCHAR(255) NOT NULL, -- Store normally passwords
    role       ENUM('admin', 'sale') NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- PRODUCTS TABLE

CREATE TABLE products (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    product_name        VARCHAR(150) NOT NULL,
    price       DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    stock    INT NOT NULL DEFAULT 0,  
    category_id INT NOT NULL,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
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
    id         INT AUTO_INCREMENT PRIMARY KEY,
    order_id   INT NOT NULL,
    product_id INT NOT NULL,
    quantity   INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal   DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id)   REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- SEED DATA

-- Categories
INSERT INTO categories (category_name) VALUES ('Electronics'), ('Food'), ('Clothing');

-- Users (plaintext passwords for dev only; change to hashed passwords in production)
INSERT INTO users (user_name, password, role) VALUES
('Admin User','123', 'admin'),
('Sale User','123', 'sale'),
('Lyhak Try','123', 'sale');




-- Products
INSERT INTO products (product_name, price, stock, category_id) VALUES
('USB-C Hub', 25.99, 50, 1),
('Wireless Mouse', 15.49, 80, 2),
('Coffee Beans', 9.99, 200, 2),
('Plain T-Shirt', 7.99, 150, 3);

SELECT * FROM categories;
SELECT * FROM products;
SELECT * FROM users;
SELECT * FROM orders;
SELECT * FROM order_items;

DROP TABLE categories;
DROP TABLE products;
DROP TABLE users;
DROP TABLE orders;
DROP TABLE order_items;