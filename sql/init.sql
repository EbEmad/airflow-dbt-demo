-- Active: 1755343412388@@127.0.0.1@5433@airflow
-- SQL script to initialize the database schema


CREATE TABLE if not exists customers_raw (
    cst_id      SERIAL PRIMARY KEY,
    cst_nm    VARCHAR(100) NOT NULL,
    emil            VARCHAR(150) UNIQUE NOT NULL,
    ph            VARCHAR(20),
    addr          VARCHAR(255),
    crt_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



INSERT INTO customers_raw (cst_nm, emil, ph, addr, crt_at, upd_at)
VALUES
('Alice Johnson', 'alice@example.com', '123-456-7890', '123 Main St', '2023-01-01', '2023-02-01'),
('Bob Smith', 'bob@example.com', '987-654-3210', '456 Oak St', '2023-02-01', '2023-02-10'),
('Charlie Brown', 'charlie@example.com', '555-666-7777', '789 Pine St', '2023-03-01', '2023-03-15');


CREATE TABLE products (
    product_id   INT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category     VARCHAR(100),
    price        DECIMAL(10,2) NOT NULL,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO products (product_id, product_name, category, price, created_at, updated_at)
VALUES
(1, 'Laptop Pro 15"', 'Electronics', 1200.00, '2023-01-01', '2023-01-05'),
(2, 'Wireless Mouse', 'Electronics', 25.00, '2023-01-02', '2023-01-06'),
(3, 'Office Chair', 'Furniture', 150.00, '2023-01-03', '2023-01-07'),
(4, 'Water Bottle', 'Accessories', 12.00, '2023-01-04', '2023-01-08');




create table if not exists orders_raw (
    o_id INT PRIMARY KEY,
    cust INT,
    prod INT,
    crt TIMESTAMP,
    upd TIMESTAMP,
    status VARCHAR(50),
    total DECIMAL(10, 2),
    addr TEXT,
    load_ts TIMESTAMP,
    src_file VARCHAR(255)
);


INSERT INTO orders_raw (
    o_id, cust, prod, crt, upd,
    status, total, addr, load_ts, src_file
) VALUES
(1, 101, 501, '2025-08-01 10:15:00', '2025-08-01 10:20:00', 'Pending', 120.50, '123 Elm Street, City A', '2025-08-01 10:25:00', 'orders_aug01.csv'),
(2, 102, 502, '2025-08-02 11:00:00', '2025-08-02 11:15:00', 'Shipped', 89.99, '456 Oak Avenue, City B', '2025-08-02 11:18:00', 'orders_aug02.csv'),
(3, 103, 503, '2025-08-03 09:45:00', '2025-08-03 09:50:00', 'Delivered', 45.75, '789 Pine Road, City C', '2025-08-03 09:55:00', 'orders_aug03.csv'),
(4, 104, 504, '2025-08-04 14:30:00', '2025-08-04 14:35:00', 'Cancelled', 200.00, '321 Maple Blvd, City D', '2025-08-04 14:40:00', 'orders_aug04.csv'),
(5, 105, 505, '2025-08-05 16:10:00', '2025-08-05 16:15:00', 'Pending', 300.25, '654 Cedar Lane, City E', '2025-08-05 16:18:00', 'orders_aug05.csv');




CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id      INT NOT NULL,
    product_id    INT NOT NULL,
    quantity      INT NOT NULL CHECK (quantity > 0),
    unit_price    DECIMAL(10,2) NOT NULL,
    total_price   DECIMAL(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED, -- PostgreSQL
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders_raw(o_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);


INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price, created_at)
VALUES
(1001, 1, 1, 1, 1200.00, '2023-02-01 00:00:00'),   -- Alice bought a Laptop
(1002, 1, 2, 1, 25.00,   '2023-02-01 00:00:00'),   -- Alice also bought a Mouse
(1003, 2, 4, 2, 12.00,   '2023-02-15 00:00:00'),   -- Alice bought 2 Bottles
(1004, 3, 3, 1, 150.00,  '2023-02-20 00:00:00'),   -- Bob bought an Office Chair
(1005, 4, 2, 2, 25.00,   '2023-03-01 00:00:00');   -- Alice bought 2 Mice
