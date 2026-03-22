-- Справочник стран покупателей
CREATE TABLE dim_customer_country (
    country_id   SERIAL PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL UNIQUE
);

-- Измерение: Покупатели
CREATE TABLE dim_customer (
    customer_id  SERIAL PRIMARY KEY,
    first_name   VARCHAR(100),
    last_name    VARCHAR(100),
    age          INTEGER,
    email        VARCHAR(200),
    country_id   INTEGER REFERENCES dim_customer_country(country_id),
    postal_code  VARCHAR(50)
);

-- Измерение: Питомцы покупателей
CREATE TABLE dim_pet (
    pet_id    SERIAL PRIMARY KEY,
    pet_type  VARCHAR(50),
    pet_name  VARCHAR(100),
    pet_breed VARCHAR(100)
);

-- Справочник стран продавцов
CREATE TABLE dim_seller_country (
    country_id   SERIAL PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL UNIQUE
);

-- Измерение: Продавцы
CREATE TABLE dim_seller (
    seller_id   SERIAL PRIMARY KEY,
    first_name  VARCHAR(100),
    last_name   VARCHAR(100),
    email       VARCHAR(200),
    country_id  INTEGER REFERENCES dim_seller_country(country_id),
    postal_code VARCHAR(50)
);

-- Справочник категорий товаров
CREATE TABLE dim_product_category (
    category_id   SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

-- Справочник брендов
CREATE TABLE dim_product_brand (
    brand_id   SERIAL PRIMARY KEY,
    brand_name VARCHAR(100) NOT NULL UNIQUE
);

-- Измерение: Товары
CREATE TABLE dim_product (
    product_id   SERIAL PRIMARY KEY,
    product_name VARCHAR(200),
    category_id  INTEGER REFERENCES dim_product_category(category_id),
    brand_id     INTEGER REFERENCES dim_product_brand(brand_id),
    price        NUMERIC(10,2),
    weight       NUMERIC(10,2),
    color        VARCHAR(50),
    size         VARCHAR(50),
    material     VARCHAR(100),
    description  TEXT,
    rating       NUMERIC(3,1),
    reviews      INTEGER,
    release_date DATE,
    expiry_date  DATE
);

-- Справочник категорий питомцев (для товаров)
CREATE TABLE dim_pet_category (
    pet_category_id   SERIAL PRIMARY KEY,
    pet_category_name VARCHAR(50) NOT NULL UNIQUE
);

-- Справочник стран магазинов
CREATE TABLE dim_store_country (
    country_id   SERIAL PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL UNIQUE
);

-- Измерение: Магазины
CREATE TABLE dim_store (
    store_id   SERIAL PRIMARY KEY,
    store_name VARCHAR(200),
    location   VARCHAR(200),
    city       VARCHAR(100),
    state      VARCHAR(100),
    country_id INTEGER REFERENCES dim_store_country(country_id),
    phone      VARCHAR(50),
    email      VARCHAR(200)
);

-- Справочник стран поставщиков
CREATE TABLE dim_supplier_country (
    country_id   SERIAL PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL UNIQUE
);

-- Измерение: Поставщики
CREATE TABLE dim_supplier (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name    VARCHAR(200),
    contact_person   VARCHAR(200),
    email            VARCHAR(200),
    phone            VARCHAR(50),
    address          VARCHAR(300),
    city             VARCHAR(100),
    country_id       INTEGER REFERENCES dim_supplier_country(country_id)
);

-- Таблица фактов: Продажи
CREATE TABLE fact_sale (
    sale_id         SERIAL PRIMARY KEY,
    customer_id     INTEGER REFERENCES dim_customer(customer_id),
    pet_id          INTEGER REFERENCES dim_pet(pet_id),
    seller_id       INTEGER REFERENCES dim_seller(seller_id),
    product_id      INTEGER REFERENCES dim_product(product_id),
    pet_category_id INTEGER REFERENCES dim_pet_category(pet_category_id),
    store_id        INTEGER REFERENCES dim_store(store_id),
    supplier_id     INTEGER REFERENCES dim_supplier(supplier_id),
    sale_date       DATE,
    quantity         INTEGER,
    total_price     NUMERIC(10,2)
);
