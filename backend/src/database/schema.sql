-- Kaka Food Delivery - Production Database Schema (SQLite / SQL)

PRAGMA foreign_keys = ON;

-- 1. Users table
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    phone_number TEXT DEFAULT '',
    avatar_url TEXT DEFAULT '',
    membership_tier TEXT DEFAULT 'Welcome Foodie ⭐',
    total_orders INTEGER DEFAULT 0,
    saved_favorites_count INTEGER DEFAULT 0,
    loyalty_points INTEGER DEFAULT 100,
    wallet_balance REAL DEFAULT 150.00,
    address TEXT DEFAULT '221B Baker Street, Suite 4',
    preferred_payment TEXT DEFAULT 'UPI / Google Pay',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Index for fast user authentication lookup
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- 2. Categories table
CREATE TABLE IF NOT EXISTS categories (
    id TEXT PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    sort_order INTEGER DEFAULT 0
);

-- 3. Food items table
CREATE TABLE IF NOT EXISTS food_items (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    description TEXT NOT NULL,
    price REAL NOT NULL,
    rating REAL DEFAULT 4.5,
    review_count INTEGER DEFAULT 0,
    delivery_time TEXT NOT NULL,
    calories INTEGER DEFAULT 0,
    image_url TEXT NOT NULL,
    is_popular INTEGER DEFAULT 0,
    is_chef_special INTEGER DEFAULT 0,
    ingredients TEXT DEFAULT '[]', -- JSON string of string array
    spicy_level INTEGER DEFAULT 0,  -- 0: None, 1: Mild, 2: Medium, 3: Hot
    is_vegetarian INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Indices for filtering by category, search and popularity
CREATE INDEX IF NOT EXISTS idx_food_category ON food_items(category);
CREATE INDEX IF NOT EXISTS idx_food_popular ON food_items(is_popular);
CREATE INDEX IF NOT EXISTS idx_food_rating ON food_items(rating);

-- 4. Promo Banners table
CREATE TABLE IF NOT EXISTS promo_banners (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    subtitle TEXT NOT NULL,
    tag TEXT NOT NULL,
    discount_code TEXT NOT NULL,
    image_url TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 5. Orders table
CREATE TABLE IF NOT EXISTS orders (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    total_amount REAL NOT NULL,
    discount_amount REAL DEFAULT 0.0,
    final_amount REAL NOT NULL,
    status TEXT DEFAULT 'placed', -- placed, preparing, out_for_delivery, delivered, cancelled
    delivery_address TEXT NOT NULL,
    payment_method TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id);

-- 6. Order items table
CREATE TABLE IF NOT EXISTS order_items (
    id TEXT PRIMARY KEY,
    order_id TEXT NOT NULL,
    food_id TEXT NOT NULL,
    food_name TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    price REAL NOT NULL,
    image_url TEXT DEFAULT '',
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (food_id) REFERENCES food_items(id)
);

CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);

-- 7. Favorites table
CREATE TABLE IF NOT EXISTS favorites (
    user_id TEXT NOT NULL,
    food_id TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, food_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (food_id) REFERENCES food_items(id) ON DELETE CASCADE
);
