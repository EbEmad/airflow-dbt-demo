-- SQL script to initialize the database schema
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
