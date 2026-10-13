const fs = require('fs');
const path = require('path');
const bcrypt = require('bcryptjs');
const { execAsync, runAsync, getAsync } = require('../config/db');

const FALLBACK_SCHEMA_SQL = `
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
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

CREATE TABLE IF NOT EXISTS categories (
    id TEXT PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    sort_order INTEGER DEFAULT 0
);

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
    ingredients TEXT DEFAULT '[]',
    spicy_level INTEGER DEFAULT 0,
    is_vegetarian INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_food_category ON food_items(category);
CREATE INDEX IF NOT EXISTS idx_food_popular ON food_items(is_popular);
CREATE INDEX IF NOT EXISTS idx_food_rating ON food_items(rating);

CREATE TABLE IF NOT EXISTS promo_banners (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    subtitle TEXT NOT NULL,
    tag TEXT NOT NULL,
    discount_code TEXT NOT NULL,
    image_url TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    total_amount REAL NOT NULL,
    discount_amount REAL DEFAULT 0.0,
    final_amount REAL NOT NULL,
    status TEXT DEFAULT 'placed',
    delivery_address TEXT NOT NULL,
    payment_method TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id);

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

CREATE TABLE IF NOT EXISTS favorites (
    user_id TEXT NOT NULL,
    food_id TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, food_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (food_id) REFERENCES food_items(id) ON DELETE CASCADE
);
`;

async function initializeDatabase() {
  try {
    console.log('🔄 Checking and applying database schema...');
    let schemaSql = FALLBACK_SCHEMA_SQL;
    const schemaPath = path.join(__dirname, 'schema.sql');
    if (fs.existsSync(schemaPath)) {
      try {
        schemaSql = fs.readFileSync(schemaPath, 'utf-8');
      } catch (e) {
        console.warn('Could not read schema.sql from disk, using fallback schema string:', e.message);
      }
    }
    await execAsync(schemaSql);
    console.log('✅ Schema tables verified/created successfully.');

    // 1. Seed Demo User if not exists
    const existingDemoUser = await getAsync(
      'SELECT id FROM users WHERE email = ?',
      ['chef.alex@kakafood.com']
    );

    if (!existingDemoUser) {
      console.log('🌱 Seeding demo user (Alex Vance)...');
      const passwordHash = await bcrypt.hash('password123', 10);
      await runAsync(
        `INSERT INTO users (
          id, full_name, email, password_hash, phone_number, avatar_url,
          membership_tier, total_orders, saved_favorites_count, loyalty_points,
          wallet_balance, address, preferred_payment
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          'usr_demo_chef_alex',
          'Alex Vance',
          'chef.alex@kakafood.com',
          passwordHash,
          '+91 98765 43210',
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
          'Gold Gourmet Member ⭐',
          6,
          4,
          240,
          150.00,
          '221B Baker Street, Suite 4',
          'UPI •••• 9210',
        ]
      );
    }

    // 2. Seed Categories
    const existingCategories = await getAsync('SELECT COUNT(*) as count FROM categories');
    if (existingCategories.count === 0) {
      console.log('🌱 Seeding food categories...');
      const categories = [
        { id: 'cat_all', name: 'All', sort: 0 },
        { id: 'cat_burgers', name: 'Burgers', sort: 1 },
        { id: 'cat_pizza', name: 'Pizza', sort: 2 },
        { id: 'cat_asian', name: 'Asian & Bowls', sort: 3 },
        { id: 'cat_healthy', name: 'Healthy & Salads', sort: 4 },
        { id: 'cat_desserts', name: 'Desserts', sort: 5 },
        { id: 'cat_beverages', name: 'Beverages', sort: 6 },
      ];

      for (const cat of categories) {
        await runAsync(
          'INSERT INTO categories (id, name, sort_order) VALUES (?, ?, ?)',
          [cat.id, cat.name, cat.sort]
        );
      }
    }

    // 3. Seed Food Items
    const existingFood = await getAsync('SELECT COUNT(*) as count FROM food_items');
    if (existingFood.count === 0) {
      console.log('🌱 Seeding initial gourmet menu items...');
      const foods = [
        {
          id: 'f1',
          name: 'Double Truffle Smash Burger',
          category: 'Burgers',
          description: 'Aged Angus patties smashed crisp with black truffle butter, cave-aged cheddar & house brioche.',
          price: 399.00,
          rating: 4.9,
          reviewCount: 320,
          deliveryTime: '20-25 min',
          calories: 680,
          imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&auto=format&fit=crop&q=80',
          isPopular: 1,
          isChefSpecial: 1,
          ingredients: JSON.stringify(['Angus Beef', 'Truffle Aioli', 'Aged Cheddar', 'Caramelized Onion', 'Brioche Bun']),
          spicyLevel: 1,
          isVegetarian: 0,
        },
        {
          id: 'f2',
          name: 'Artisan Burrata Margherita',
          category: 'Pizza',
          description: '48-hour fermented sourdough crust topped with San Marzano tomatoes, whole creamy burrata & fresh sweet basil.',
          price: 449.00,
          rating: 4.8,
          reviewCount: 280,
          deliveryTime: '25-30 min',
          calories: 740,
          imageUrl: 'https://images.unsplash.com/photo-1604382355076-af4b0eb60143?w=800&auto=format&fit=crop&q=80',
          isPopular: 1,
          isChefSpecial: 0,
          ingredients: JSON.stringify(['Sourdough Crust', 'San Marzano Sauce', 'Fresh Burrata', 'EVOO', 'Sweet Basil']),
          spicyLevel: 0,
          isVegetarian: 1,
        },
        {
          id: 'f3',
          name: 'Tonkotsu Chashu Ramen',
          category: 'Asian & Bowls',
          description: 'Rich 24-hour pork bone broth, handcrafted springy noodles, torched chashu pork belly & seasoned ajitama egg.',
          price: 499.00,
          rating: 4.9,
          reviewCount: 410,
          deliveryTime: '20-30 min',
          calories: 620,
          imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800&auto=format&fit=crop&q=80',
          isPopular: 1,
          isChefSpecial: 1,
          ingredients: JSON.stringify(['Slow Broth', 'Pork Chashu', 'Ramen Noodles', 'Ajitama Egg', 'Nori', 'Bamboo Shoots']),
          spicyLevel: 2,
          isVegetarian: 0,
        },
        {
          id: 'f4',
          name: 'Avocado Green Goddess Bowl',
          category: 'Healthy & Salads',
          description: 'Organic tri-color quinoa, hass avocado, edamame, baby spinach, roasted chickpeas & herbaceous green tahini dressing.',
          price: 349.00,
          rating: 4.7,
          reviewCount: 195,
          deliveryTime: '15-20 min',
          calories: 420,
          imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&auto=format&fit=crop&q=80',
          isPopular: 0,
          isChefSpecial: 0,
          ingredients: JSON.stringify(['Quinoa', 'Hass Avocado', 'Edamame', 'Kale', 'Green Tahini', 'Spiced Chickpeas']),
          spicyLevel: 0,
          isVegetarian: 1,
        },
        {
          id: 'f5',
          name: 'Molten Belgian Lava Cake',
          category: 'Desserts',
          description: 'Warm dark chocolate souffle with a cascading 70% Callebaut center, served with madagascar vanilla bean gelato.',
          price: 279.00,
          rating: 4.9,
          reviewCount: 380,
          deliveryTime: '20-25 min',
          calories: 520,
          imageUrl: 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=800&auto=format&fit=crop&q=80',
          isPopular: 1,
          isChefSpecial: 1,
          ingredients: JSON.stringify(['Callebaut Dark Chocolate', 'Pure Butter', 'Vanilla Gelato', 'Berry Coulis']),
          spicyLevel: 0,
          isVegetarian: 1,
        },
        {
          id: 'f6',
          name: 'Cold Brew Nitro Float',
          category: 'Beverages',
          description: 'Single-origin Ethiopian nitro cold brew with velvety microfoam, topped with rich salted caramel cream.',
          price: 229.00,
          rating: 4.8,
          reviewCount: 210,
          deliveryTime: '10-15 min',
          calories: 180,
          imageUrl: 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?w=800&auto=format&fit=crop&q=80',
          isPopular: 0,
          isChefSpecial: 0,
          ingredients: JSON.stringify(['Ethiopian Cold Brew', 'Nitrogen Infusion', 'Sea Salt Caramel Cream']),
          spicyLevel: 0,
          isVegetarian: 1,
        },
        {
          id: 'f7',
          name: 'Crispy Korean Fried Bao',
          category: 'Asian & Bowls',
          description: 'Fluffy steamed lotus buns stuffed with double-crisped chicken glazed in gochujang garlic honey and pickled slaw.',
          price: 369.00,
          rating: 4.8,
          reviewCount: 260,
          deliveryTime: '20-25 min',
          calories: 580,
          imageUrl: 'https://images.unsplash.com/photo-1541696432-82c6da8ce7bf?w=800&auto=format&fit=crop&q=80',
          isPopular: 1,
          isChefSpecial: 0,
          ingredients: JSON.stringify(['Steamed Bao', 'Crispy Chicken', 'Gochujang Honey', 'Pickled Daikon', 'Scallions']),
          spicyLevel: 2,
          isVegetarian: 0,
        },
        {
          id: 'f8',
          name: 'Smoked BBQ Bacon Stack',
          category: 'Burgers',
          description: 'Applewood smoked beef patty, thick cut maple bacon, crisp onion straws, and smoky bourbon barbecue glaze.',
          price: 429.00,
          rating: 4.7,
          reviewCount: 220,
          deliveryTime: '20-25 min',
          calories: 760,
          imageUrl: 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=800&auto=format&fit=crop&q=80',
          isPopular: 0,
          isChefSpecial: 0,
          ingredients: JSON.stringify(['Prime Beef', 'Maple Bacon', 'Crispy Onion Straws', 'Bourbon BBQ', 'Smoked Cheddar']),
          spicyLevel: 1,
          isVegetarian: 0,
        },
      ];

      for (const item of foods) {
        await runAsync(
          `INSERT INTO food_items (
            id, name, category, description, price, rating, review_count,
            delivery_time, calories, image_url, is_popular, is_chef_special,
            ingredients, spicy_level, is_vegetarian
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          [
            item.id,
            item.name,
            item.category,
            item.description,
            item.price,
            item.rating,
            item.reviewCount,
            item.deliveryTime,
            item.calories,
            item.imageUrl,
            item.isPopular,
            item.isChefSpecial,
            item.ingredients,
            item.spicyLevel,
            item.isVegetarian,
          ]
        );
      }
    }

    // 4. Seed Promo Banners
    const existingPromos = await getAsync('SELECT COUNT(*) as count FROM promo_banners');
    if (existingPromos.count === 0) {
      console.log('🌱 Seeding promo banners...');
      const promos = [
        {
          id: 'p1',
          title: 'Chef Special Truffle Burger',
          subtitle: 'Double Angus beef with black truffle glaze & aged cheddar',
          tag: '30% OFF',
          discountCode: 'TRUFFLE30',
          imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&auto=format&fit=crop&q=80',
        },
        {
          id: 'p2',
          title: 'Woodfired Artisan Margherita',
          subtitle: 'San Marzano tomatoes, buffalo mozzarella & basil',
          tag: 'FREE DRINK',
          discountCode: 'PIZZAFREE',
          imageUrl: 'https://images.unsplash.com/photo-1604382355076-af4b0eb60143?w=800&auto=format&fit=crop&q=80',
        },
        {
          id: 'p3',
          title: 'Kyoto Ramen Bowl',
          subtitle: '24-hour slow simmered tonkotsu broth with chashu pork',
          tag: 'TRENDING NOW',
          discountCode: 'RAMENLOVE',
          imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800&auto=format&fit=crop&q=80',
        },
      ];

      for (const promo of promos) {
        await runAsync(
          `INSERT INTO promo_banners (id, title, subtitle, tag, discount_code, image_url)
           VALUES (?, ?, ?, ?, ?, ?)`,
          [promo.id, promo.title, promo.subtitle, promo.tag, promo.discountCode, promo.imageUrl]
        );
      }
    }

    console.log('✨ Database initialization and seeding completed successfully!');
  } catch (error) {
    console.error('❌ Error during database initialization:', error);
    throw error;
  }
}

module.exports = { initializeDatabase };
