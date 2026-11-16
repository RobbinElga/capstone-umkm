CREATE TABLE categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR(80) NOT NULL
);

CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  price NUMERIC(12,2) NOT NULL,
  category_id INTEGER REFERENCES categories(id),
  created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO categories (name) VALUES
  ('Makanan Berat'),   -- 1
  ('Kue & Jajanan'),   -- 2
  ('Minuman'),         -- 3
  ('Seafood'),         -- 4
  ('Oleh-oleh');       -- 5

INSERT INTO products (name, price, category_id) VALUES
  ('Bubur Pedas Sambas', 20000, 1),
  ('Kwetiau Sapi Pontianak', 35000, 1),
  ('Mie Tiaw Goreng', 28000, 1),
  ('Asam Pedas Ikan Baung', 45000, 4),
  ('Chai Kwe', 15000, 2),
  ('Pengkang', 12000, 2),
  ('Es Lidah Buaya', 10000, 3),
  ('Es Kopi Tiam', 12000, 3),
  ('Lempok Durian', 30000, 5),
  ('Kerupuk Basah Pontianak', 25000, 5);

-- 300 baris tambahan supaya respons cukup besar saat uji beban
INSERT INTO products (name, price, category_id)
SELECT 'Menu UMKM ' || g, 10000 + (g % 40) * 1000, 1 + (g % 5)
FROM generate_series(1, 300) AS g;