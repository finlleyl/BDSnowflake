-- =============================================
-- Шаг 1. Заполнение справочников
-- =============================================

-- Единый справочник стран
INSERT INTO dim_country (country_name)
SELECT DISTINCT country_name FROM (
    SELECT customer_country AS country_name FROM mock_data
    UNION
    SELECT seller_country FROM mock_data
    UNION
    SELECT store_country FROM mock_data
    UNION
    SELECT supplier_country FROM mock_data
) t
WHERE country_name IS NOT NULL
ORDER BY country_name;

-- Единый справочник городов
INSERT INTO dim_city (city_name)
SELECT DISTINCT city_name FROM (
    SELECT store_city AS city_name FROM mock_data
    UNION
    SELECT supplier_city FROM mock_data
) t
WHERE city_name IS NOT NULL
ORDER BY city_name;

-- Категории и бренды
INSERT INTO dim_product_category (category_name)
SELECT DISTINCT product_category FROM mock_data
WHERE product_category IS NOT NULL
ORDER BY product_category;

INSERT INTO dim_product_brand (brand_name)
SELECT DISTINCT product_brand FROM mock_data
WHERE product_brand IS NOT NULL
ORDER BY product_brand;

INSERT INTO dim_pet_category (pet_category_name)
SELECT DISTINCT pet_category FROM mock_data
WHERE pet_category IS NOT NULL
ORDER BY pet_category;

-- =============================================
-- Шаг 2. Заполнение измерений
-- =============================================

-- Покупатели
INSERT INTO dim_customer (first_name, last_name, age, email, country_id, postal_code)
SELECT DISTINCT
    r.customer_first_name,
    r.customer_last_name,
    r.customer_age,
    r.customer_email,
    c.country_id,
    r.customer_postal_code
FROM mock_data r
LEFT JOIN dim_country c ON c.country_name = r.customer_country;

-- Питомцы
INSERT INTO dim_pet (pet_type, pet_name, pet_breed)
SELECT DISTINCT
    customer_pet_type,
    customer_pet_name,
    customer_pet_breed
FROM mock_data;

-- Продавцы
INSERT INTO dim_seller (first_name, last_name, email, country_id, postal_code)
SELECT DISTINCT
    r.seller_first_name,
    r.seller_last_name,
    r.seller_email,
    c.country_id,
    r.seller_postal_code
FROM mock_data r
LEFT JOIN dim_country c ON c.country_name = r.seller_country;

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
FROM mock_data r
LEFT JOIN dim_product_category pc ON pc.category_name = r.product_category
LEFT JOIN dim_product_brand pb ON pb.brand_name = r.product_brand;

-- Магазины
INSERT INTO dim_store (store_name, location, city_id, state, country_id, phone, email)
SELECT DISTINCT
    r.store_name,
    r.store_location,
    ci.city_id,
    r.store_state,
    c.country_id,
    r.store_phone,
    r.store_email
FROM mock_data r
LEFT JOIN dim_country c ON c.country_name = r.store_country
LEFT JOIN dim_city ci ON ci.city_name = r.store_city;

-- Поставщики
INSERT INTO dim_supplier (supplier_name, contact_person, email, phone, address, city_id, country_id)
SELECT DISTINCT
    r.supplier_name,
    r.supplier_contact,
    r.supplier_email,
    r.supplier_phone,
    r.supplier_address,
    ci.city_id,
    c.country_id
FROM mock_data r
LEFT JOIN dim_country c ON c.country_name = r.supplier_country
LEFT JOIN dim_city ci ON ci.city_name = r.supplier_city;

-- =============================================
-- Шаг 3. Заполнение таблицы фактов
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
FROM mock_data r
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
-- Шаг 4. Очистка: удаление исходной таблицы
-- =============================================
DROP TABLE mock_data;
