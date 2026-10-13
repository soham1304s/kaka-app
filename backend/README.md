# 🍔 Kaka Food Delivery - Production Backend & Database

A production-grade REST API and relational database service for the **Kaka Food** mobile application, built with Node.js, Express, and high-performance SQLite (WAL mode).

---

## 🏗️ Architecture Overview

```text
backend/
├── .env                  # Environment configuration
├── .env.example          # Environment variables template
├── package.json          # Node dependencies and scripts
├── server.js             # Server entrypoint with DB initialization
├── test/
│   └── api.test.js       # Automated integration test suite
└── src/
    ├── app.js            # Express app, middleware, routes
    ├── config/
    │   └── db.js         # SQLite connection with async Promise wrappers & WAL mode
    ├── database/
    │   ├── schema.sql    # Relational schema (tables, foreign keys & indices)
    │   ├── initDb.js     # Migration runner and automated seeder
    │   └── kaka_food.db  # Persistent database file
    ├── controllers/
    │   ├── authController.js   # Register, Login, Demo, Profile
    │   ├── foodController.js   # Menu, Category filters, Search, Promos, Favorites
    │   └── orderController.js  # Order placement, Calculation, Order tracking
    ├── middleware/
    │   ├── authMiddleware.js   # JWT token verification (Bearer token)
    │   ├── errorHandler.js     # Standardized JSON error response handler
    │   └── logger.js           # Structured request logging
    └── routes/
        ├── authRoutes.js       # /api/auth routes
        ├── foodRoutes.js       # /api/food routes
        └── orderRoutes.js      # /api/orders routes
```

---

## 🗄️ Database Schema & Features

The database uses SQLite with **Write-Ahead Logging (WAL)** and **Foreign Key enforcement** enabled:

1. **`users`**:
   - `id`, `full_name`, `email` (unique index), `password_hash` (bcrypt), `phone_number`, `avatar_url`, `membership_tier`, `total_orders`, `saved_favorites_count`, `loyalty_points`, `wallet_balance`, `address`, `preferred_payment`, `created_at`.
2. **`food_items`**:
   - `id`, `name`, `category` (indexed), `description`, `price`, `rating`, `review_count`, `delivery_time`, `calories`, `image_url`, `is_popular`, `is_chef_special`, `ingredients` (JSON array), `spicy_level`, `is_vegetarian`.
3. **`categories`**:
   - `id`, `name` (unique), `sort_order`.
4. **`promo_banners`**:
   - `id`, `title`, `subtitle`, `tag`, `discount_code`, `image_url`.
5. **`orders`**:
   - `id`, `user_id` (foreign key), `total_amount`, `discount_amount`, `final_amount`, `status`, `delivery_address`, `payment_method`, `created_at`.
6. **`order_items`**:
   - `id`, `order_id` (foreign key), `food_id`, `food_name`, `quantity`, `price`, `image_url`.
7. **`favorites`**:
   - Composite key `(user_id, food_id)` with cascading foreign keys.

---

## 🚀 Quick Start

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Run Database Seeding (Runs automatically on first startup)
```bash
npm run seed
```

### 3. Start Server
```bash
# Production mode
npm start

# Development mode (auto-reload on changes)
npm run dev
```
The server will start on `http://localhost:5000` (or the port specified in `.env`).

### 4. Run Automated API Tests
```bash
npm test
```

---

## 📡 API Endpoints Reference

### 1. System
- `GET /api/health`: Health status, SQLite connection, uptime.

### 2. Authentication (`/api/auth`)
- `POST /api/auth/register`: Register new user with full name, email, phone, password. (Gives ₹150 welcome bonus).
- `POST /api/auth/login`: Authenticate with email & password, returns JWT token.
- `POST /api/auth/demo`: Instant 1-tap demo login as Chef Alex Vance.
- `GET /api/auth/me`: Get current authenticated user profile (`Authorization: Bearer <token>`).
- `PUT /api/auth/profile`: Update address, phone, avatar, or preferences.

### 3. Food Menu (`/api/food`)
- `GET /api/food`: List items. Supports query parameters:
  - `?category=Burgers`
  - `?search=truffle`
  - `?sortBy=Price: Low to High` / `Rating` / `Popular` / `Fastest Delivery`
- `GET /api/food/:id`: Get detailed food item by ID.
- `GET /api/food/categories`: List category strings (`['All', 'Burgers', 'Pizza', ...]`).
- `GET /api/food/promos`: List promotional banner campaigns.
- `POST /api/food/:id/favorite`: Toggle favorite status (`Authorization: Bearer <token>`).
- `GET /api/food/favorites`: List user's favorite foods (`Authorization: Bearer <token>`).

### 4. Orders (`/api/orders`)
- `POST /api/orders`: Place order with items, address, payment method (`Authorization: Bearer <token>`). Automatically awards 10% loyalty points and increments order count.
- `GET /api/orders`: Get user's order history with line items (`Authorization: Bearer <token>`).
- `GET /api/orders/:id`: Get order receipt by ID (`Authorization: Bearer <token>`).
