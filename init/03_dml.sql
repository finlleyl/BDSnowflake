-- =============================================
-- Шаг 1. Materialized view с приведением типов
-- =============================================
CREATE MATERIALIZED VIEW raw_data AS
SELECT
    id,
    customer_first_name, customer_last_name, customer_age::int,
    customer_email, customer_country, customer_postal_code,
    customer_pet_type, customer_pet_name, customer_pet_breed,
    seller_first_name, seller_last_name, seller_email, seller_country, seller_postal_code,
    product_name, product_category, product_price::numeric(10,2), product_quantity::int,
    sale_date, sale_customer_id::int, sale_seller_id::int, sale_product_id::int,
    sale_quantity::int, sale_total_price::numeric(10,2),
    store_name, store_location, store_city, store_state, store_country, store_phone, store_email,
    pet_category, product_weight::numeric(10,2), product_color, product_size,
    product_brand, product_material, product_description,
    product_rating::numeric(3,1), product_reviews::int,
    product_release_date, product_expiry_date,
    supplier_name, supplier_contact, supplier_email, supplier_phone,
    supplier_address, supplier_city, supplier_country
FROM mock_data;

-- =============================================
-- Шаг 2. Заполнение справочников
-- =============================================

-- Справочники стран
INSERT INTO dim_customer_country (country_name)
SELECT DISTINCT customer_country FROM raw_data
WHERE customer_country IS NOT NULL
ORDER BY customer_country;

INSERT INTO dim_seller_country (country_name)
SELECT DISTINCT seller_country FROM raw_data
WHERE seller_country IS NOT NULL
ORDER BY seller_country;

INSERT INTO dim_store_country (country_name)
SELECT DISTINCT store_country FROM raw_data
WHERE store_country IS NOT NULL
ORDER BY store_country;

INSERT INTO dim_supplier_country (country_name)
SELECT DISTINCT supplier_country FROM raw_data
WHERE supplier_country IS NOT NULL
ORDER BY supplier_country;

-- Категории и бренды
INSERT INTO dim_product_category (category_name)
SELECT DISTINCT product_category FROM raw_data
WHERE product_category IS NOT NULL
ORDER BY product_category;

INSERT INTO dim_product_brand (brand_name)
SELECT DISTINCT product_brand FROM raw_data
WHERE product_brand IS NOT NULL
ORDER BY product_brand;

INSERT INTO dim_pet_category (pet_category_name)
SELECT DISTINCT pet_category FROM raw_data
WHERE pet_category IS NOT NULL
ORDER BY pet_category;

-- =============================================
-- Шаг 3. Заполнение измерений
-- =============================================

-- Покупатели
INSERT INTO dim_customer (first_name, last_name, age, email, country_id, postal_code)
SELECT DISTINCT
    r.customer_first_name,
    r.customer_last_name,
    r.customer_age,
    r.customer_email,
    cc.country_id,
    r.customer_postal_code
FROM raw_data r
LEFT JOIN dim_customer_country cc ON cc.country_name = r.customer_country;

-- Питомцы
INSERT INTO dim_pet (pet_type, pet_name, pet_breed)
SELECT DISTINCT
    customer_pet_type,
    customer_pet_name,
    customer_pet_breed
FROM raw_data;

-- Продавцы
INSERT INTO dim_seller (first_name, last_name, email, country_id, postal_code)
SELECT DISTINCT
    r.seller_first_name,
    r.seller_last_name,
    r.seller_email,
    sc.country_id,
    r.seller_postal_code
FROM raw_data r
LEFT JOIN dim_seller_country sc ON sc.country_name = r.seller_country;

-- Товары
INSERT INTO dim_product (product_name, category_id, brand_id, price, weight, color, size, material, description, rating, reviews, release_date, expiry_date)
SELECT DISTINCT
    r.product_name,
    pc.category_id,
    pb.brand_id,
    r.product_price,
    r.product_weight,
    r.product_color,
    r.product_size,
    r.product_material,
    r.product_description,
    r.product_rating,
    r.product_reviews,
    TO_DATE(r.product_release_date, 'MM/DD/YYYY'),
    TO_DATE(r.product_expiry_date, 'MM/DD/YYYY')
FROM raw_data r
LEFT JOIN dim_product_category pc ON pc.category_name = r.product_category
LEFT JOIN dim_product_brand pb ON pb.brand_name = r.product_brand;

-- Магазины
INSERT INTO dim_store (store_name, location, city, state, country_id, phone, email)
SELECT DISTINCT
    r.store_name,
    r.store_location,
    r.store_city,
    r.store_state,
    sc.country_id,
    r.store_phone,
    r.store_email
FROM raw_data r
LEFT JOIN dim_store_country sc ON sc.country_name = r.store_country;

-- Поставщики
INSERT INTO dim_supplier (supplier_name, contact_person, email, phone, address, city, country_id)
SELECT DISTINCT
    r.supplier_name,
    r.supplier_contact,
    r.supplier_email,
    r.supplier_phone,
    r.supplier_address,
    r.supplier_city,
    sc.country_id
FROM raw_data r
LEFT JOIN dim_supplier_country sc ON sc.country_name = r.supplier_country;

-- =============================================
-- Шаг 4. Заполнение таблицы фактов
-- =============================================
INSERT INTO fact_sale (customer_id, pet_id, seller_id, product_id, pet_category_id, store_id, supplier_id, sale_date, quantity, total_price)
SELECT
    dc.customer_id,
    dp.pet_id,
    ds.seller_id,
    dprod.product_id,
    dpc.pet_category_id,
    dst.store_id,
    dsup.supplier_id,
    TO_DATE(r.sale_date, 'MM/DD/YYYY'),
    r.sale_quantity,
    r.sale_total_price
FROM raw_data r
LEFT JOIN dim_customer dc
    ON dc.first_name = r.customer_first_name
   AND dc.last_name  = r.customer_last_name
   AND dc.email      = r.customer_email
LEFT JOIN dim_pet dp
    ON dp.pet_type  = r.customer_pet_type
   AND dp.pet_name  = r.customer_pet_name
   AND dp.pet_breed = r.customer_pet_breed
LEFT JOIN dim_seller ds
    ON ds.first_name = r.seller_first_name
   AND ds.last_name  = r.seller_last_name
   AND ds.email      = r.seller_email
LEFT JOIN dim_product dprod
    ON dprod.product_name = r.product_name
   AND dprod.price        = r.product_price
   AND dprod.color        = r.product_color
   AND dprod.size         = r.product_size
   AND dprod.rating       = r.product_rating
   AND dprod.reviews      = r.product_reviews
LEFT JOIN dim_pet_category dpc
    ON dpc.pet_category_name = r.pet_category
LEFT JOIN dim_store dst
    ON dst.store_name = r.store_name
   AND dst.phone     = r.store_phone
   AND dst.email     = r.store_email
LEFT JOIN dim_supplier dsup
    ON dsup.supplier_name = r.supplier_name
   AND dsup.email         = r.supplier_email
   AND dsup.phone         = r.supplier_phone;

-- =============================================
-- Шаг 5. Очистка: удаление materialized view и исходной таблицы
-- =============================================
DROP MATERIALIZED VIEW raw_data;
DROP TABLE mock_data;
