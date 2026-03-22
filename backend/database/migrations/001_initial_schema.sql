-- ============================================================
-- Food Delivery App — Initial Schema
-- Migration: 001
-- Description: Creates all tables for the food delivery app
-- ============================================================


-- ============================================================
-- EXTENSIONS
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


-- ============================================================
-- ENUMS
-- ============================================================
CREATE TYPE user_role AS ENUM (
    'customer',
    'rider',
    'admin'
);

CREATE TYPE order_status_value AS ENUM (
    'pending',
    'confirmed',
    'preparing',
    'picked_up',
    'delivered',
    'cancelled'
);

CREATE TYPE payment_method AS ENUM (
    'cash',
    'card'
);

CREATE TYPE payment_status AS ENUM (
    'pending',
    'paid',
    'failed',
    'refunded'
);

CREATE TYPE notification_type AS ENUM (
    'order',
    'payment',
    'delivery'
);

CREATE TYPE vehicle_type AS ENUM (
    'bike',
    'motorcycle',
    'car'
);


-- ============================================================
-- USER DOMAIN
-- ============================================================

-- Base users table
CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email           VARCHAR(255) NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    phone           VARCHAR(20) NOT NULL,
    role            user_role NOT NULL,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Customer profile
CREATE TABLE customers (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    first_name      VARCHAR(100) NOT NULL,
    last_name       VARCHAR(100) NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Rider profile
CREATE TABLE riders (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    first_name      VARCHAR(100) NOT NULL,
    last_name       VARCHAR(100) NOT NULL,
    vehicle_type    vehicle_type NOT NULL,
    vehicle_number  VARCHAR(50) NOT NULL,
    is_available    BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);


-- ============================================================
-- ADDRESS DOMAIN
-- ============================================================

-- Countries lookup table
CREATE TABLE countries (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    country_name    VARCHAR(100) NOT NULL UNIQUE,
    country_code    VARCHAR(3) NOT NULL UNIQUE
);

-- Reusable addresses
CREATE TABLE addresses (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    country_id      UUID NOT NULL REFERENCES countries(id),
    unit_number     VARCHAR(20),
    street_number   VARCHAR(20),
    address_line1   VARCHAR(255) NOT NULL,
    address_line2   VARCHAR(255),
    city            VARCHAR(100) NOT NULL,
    region          VARCHAR(100),
    postal_code     VARCHAR(20)
);

-- Customer can have many addresses
CREATE TABLE customer_addresses (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id     UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    address_id      UUID NOT NULL REFERENCES addresses(id) ON DELETE CASCADE,
    is_default      BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE(customer_id, address_id)
);


-- ============================================================
-- RESTAURANT DOMAIN
-- ============================================================

CREATE TABLE restaurants (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id        UUID NOT NULL REFERENCES users(id),
    address_id      UUID NOT NULL REFERENCES addresses(id),
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    phone           VARCHAR(20) NOT NULL,
    email           VARCHAR(255) NOT NULL,
    cuisine_type    VARCHAR(100),
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE menu_items (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id   UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    price           NUMERIC(10, 2) NOT NULL CHECK (price > 0),
    category        VARCHAR(100),
    is_available    BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);


-- ============================================================
-- ORDER DOMAIN
-- ============================================================

CREATE TABLE orders (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id             UUID NOT NULL REFERENCES customers(id),
    restaurant_id           UUID NOT NULL REFERENCES restaurants(id),
    rider_id                UUID REFERENCES riders(id),
    delivery_address_id     UUID NOT NULL REFERENCES addresses(id),
    status                  order_status_value NOT NULL DEFAULT 'pending',
    subtotal                NUMERIC(10, 2) NOT NULL CHECK (subtotal >= 0),
    delivery_fee            NUMERIC(10, 2) NOT NULL DEFAULT 0 CHECK (delivery_fee >= 0),
    total_amount            NUMERIC(10, 2) NOT NULL CHECK (total_amount >= 0),
    notes                   TEXT,
    rider_rating            SMALLINT CHECK (rider_rating BETWEEN 1 AND 5),
    restaurant_rating       SMALLINT CHECK (restaurant_rating BETWEEN 1 AND 5),
    ordered_at              TIMESTAMP NOT NULL DEFAULT NOW(),
    delivered_at            TIMESTAMP,
    updated_at              TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE order_items (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id        UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    menu_item_id    UUID NOT NULL REFERENCES menu_items(id),
    quantity        SMALLINT NOT NULL CHECK (quantity > 0),
    unit_price      NUMERIC(10, 2) NOT NULL CHECK (unit_price > 0),
    subtotal        NUMERIC(10, 2) NOT NULL CHECK (subtotal > 0)
);


-- ============================================================
-- PAYMENT
-- ============================================================

CREATE TABLE payments (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id        UUID NOT NULL UNIQUE REFERENCES orders(id),
    amount          NUMERIC(10, 2) NOT NULL CHECK (amount > 0),
    method          payment_method NOT NULL,
    status          payment_status NOT NULL DEFAULT 'pending',
    transaction_id  VARCHAR(255) UNIQUE,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);


-- ============================================================
-- NOTIFICATIONS
-- ============================================================

CREATE TABLE notifications (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title           VARCHAR(255) NOT NULL,
    message         TEXT NOT NULL,
    type            notification_type NOT NULL,
    is_read         BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);


-- ============================================================
-- INDEXES
-- speeds up frequent queries
-- ============================================================

-- Users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- Customers
CREATE INDEX idx_customers_user_id ON customers(user_id);

-- Riders
CREATE INDEX idx_riders_user_id ON riders(user_id);
CREATE INDEX idx_riders_is_available ON riders(is_available);

-- Restaurants
CREATE INDEX idx_restaurants_owner_id ON restaurants(owner_id);
CREATE INDEX idx_restaurants_is_active ON restaurants(is_active);

-- Menu items
CREATE INDEX idx_menu_items_restaurant_id ON menu_items(restaurant_id);
CREATE INDEX idx_menu_items_is_available ON menu_items(is_available);

-- Orders
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_restaurant_id ON orders(restaurant_id);
CREATE INDEX idx_orders_rider_id ON orders(rider_id);
CREATE INDEX idx_orders_status ON orders(status);

-- Order items
CREATE INDEX idx_order_items_order_id ON order_items(order_id);

-- Payments
CREATE INDEX idx_payments_order_id ON payments(order_id);
CREATE INDEX idx_payments_status ON payments(status);

-- Notifications
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);


-- ============================================================
-- SEED DATA
-- Lookup data that must exist before app runs
-- ============================================================

-- Seed countries
INSERT INTO countries (country_name, country_code) VALUES
    ('Pakistan', 'PAK'),
    ('United States', 'USA'),
    ('United Kingdom', 'GBR'),
    ('United Arab Emirates', 'UAE'),
    ('Saudi Arabia', 'SAU');