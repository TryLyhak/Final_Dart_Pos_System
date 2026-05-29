CREATE DATABASE final_pos_system;

-- 1 Create table User
CREATE TABLE users (
  id int AUTO_INCREMENT PRIMARY KEY,
  user_name varchar(100) NOT NULL,
  email varchar(100) UNIQUE NOT NULL,
  password varchar(255) NOT NULL,
  role enum ('admin', 'sale') NOT NULL,
  created_at timestamp DEFAULT CURRENT_TIMESTAMP
);

-- Insert data

INSERT INTO users (user_name, email, password, role)
  VALUES ('Admin User', 'admin@gmail.com', '123456', 'admin'),
  ('Sale User', 'sale@gmail.com', '123456', 'sale');

SELECT * FROM users;
DROP TABLE users;

-- 2 Create table categories
CREATE TABLE categories (
  id int AUTO_INCREMENT PRIMARY KEY,
  category_name varchar(100) NOT NULL
);

-- Insert Data

INSERT INTO categories (category_name)
  VALUES ('Keyboard'),
  ('Mouse'),
  ('Monitor'),
  ('Laptop'),
  ('Accessories');

SELECT * FROM categories;
DROP TABLE categories;

-- 3 Create table products
CREATE TABLE products (
  id int AUTO_INCREMENT PRIMARY KEY,
  product_name varchar(100) NOT NULL,
  description text,
  price decimal(10, 2) NOT NULL,
  stock_quantity int NOT NULL DEFAULT 0,
  category_id int,
  created_at timestamp DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (category_id)
  REFERENCES categories (id)
);

INSERT INTO products (product_name, description, price, stock_quantity, category_id)
  VALUES ('Mechanical Keyboard', 'RGB gaming keyboard', 79.99, 20, 1),

  ('Office Keyboard', 'Standard office keyboard', 25.50, 50, 1),

  ('Gaming Mouse', 'High precision gaming mouse', 45.00, 30, 2),

  ('Wireless Mouse', 'Bluetooth wireless mouse', 20.00, 40, 2),

  ('24 Inch Monitor', 'Full HD IPS Monitor', 180.00, 15, 3),

  ('ASUS ROG Laptop', 'Gaming laptop RTX series', 1500.00, 5, 4),

  ('USB-C Cable', 'Fast charging cable', 10.00, 100, 5);

  SELECT * FROM products;
  DROP TABLE products;

-- 4 Create table order
CREATE TABLE orders (
  id int AUTO_INCREMENT PRIMARY KEY,
  user_id int NOT NULL,

  receipt_number varchar(50),
  total_amount decimal(10, 2) NOT NULL,
  tax_amount decimal(10, 2) DEFAULT 0,
  discount_amount decimal(10, 2) DEFAULT 0,

  payment_method varchar(50),
  status varchar(50) DEFAULT 'completed',

  created_at timestamp DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (user_id)
  REFERENCES users (id)
);

-- INsert Data

INSERT INTO orders
(user_id, receipt_number, total_amount, payment_method)
VALUES
(2, 'RCPT-1001', 124.99, 'Cash');

SELECT * FROM orders;
DROP TABLE orders;

-- 5 Create table order_item
CREATE TABLE order_items (
  id int AUTO_INCREMENT PRIMARY KEY,

  order_id int NOT NULL,
  product_id int NOT NULL,

  quantity int NOT NULL,
  price decimal(10, 2) NOT NULL,
  subtotal decimal(10, 2) NOT NULL,

  FOREIGN KEY (order_id)
  REFERENCES orders (id),

  FOREIGN KEY (product_id)
  REFERENCES products (id)
);

-- Insert Data

INSERT INTO order_items
(order_id, product_id, quantity, price, subtotal)
VALUES
(1, 1, 1, 79.99, 79.99),
(1, 3, 1, 45.00, 45.00);

SELECT * FROM order_items;
DROP TABLE order_items;
