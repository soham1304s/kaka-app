# 🍔 Kaka Food App — Fullstack Food Delivery Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-18+-339933?logo=node.js&logoColor=white)](https://nodejs.org)
[![Express](https://img.shields.io/badge/Express-4.x-000000?logo=express&logoColor=white)](https://expressjs.com)
[![SQLite3](https://img.shields.io/badge/SQLite-WAL--Mode-003B57?logo=sqlite&logoColor=white)](https://sqlite.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A modern, production-ready fullstack food delivery application built with **Flutter** on the frontend and **Node.js / Express / SQLite** on the backend. Designed with fluid micro-animations, warm orange gourmet aesthetics, real-time cart state management, Indian Rupee (₹) localization, JWT authentication, and resilient offline-fallback architecture.

---

## 📱 Features

### 🎨 Mobile App (Flutter)
- **Vibrant Intro Animation**: Smooth hero logo scaling with warm orange background and pulse wave transition.
- **Modern Authentication Flow**: Clean Login & Sign-up sheets with password visibility toggling, validation, and instant Demo Account login (`chef.alex@kakafood.com`).
- **Gourmet Dashboard**: Category chips, promotional carousel, search and sorting filters, and interactive food cards.
- **Detailed Food Modal**: Calorie tags, prep time, ingredient highlights, portion stepper, and real-time subtotal calculations.
- **Cart & Checkout**: Interactive slide-out cart sheet with quantity adjustment, voucher discounts, and loyalty point rewards.
- **Theme Support**: Seamless Dark Mode and Light Mode switching with custom curated color palettes.
- **Currency Localized**: Fully localized to Indian Rupees (`₹`).
- **Resilient Offline Fallback**: If backend is unavailable or during local testing without internet, the app automatically falls back to offline catalog data.

### ⚡ Backend API (Node.js & Express)
- **High-Performance Database**: SQLite configured with `WAL (Write-Ahead Logging)` mode, foreign key enforcement, and indexed queries.
- **Automated Database Seeder**: Auto-initializes schema and populates gourmet menu items, categories, promos, and demo users on startup.
- **Secure Authentication**: Password hashing with `bcryptjs` and stateless Bearer `jsonwebtoken` verification.
- **Full REST API Suite**:
  - `/api/auth/*` — Register, Login, Demo Login, Profile view/updates.
  - `/api/food/*` — Menu filtering (by category, query, price/rating sorting), details, promo banners, favorites.
  - `/api/orders/*` — Order placement, order history, loyalty point crediting.
  - `/api/health` — Service health and uptime monitoring.
- **Production Architecture**: Structured with clean MVC layers (controllers, routes, middleware, config, database).
- **Automated Test Suite**: Integration test suite verifying 100% of core endpoints.

---

## 📁 Project Architecture

```
kaka-app/
├── backend/                       # Production Express API & SQLite database
│   ├── src/
│   │   ├── config/                # Database connection & WAL mode config
│   │   ├── controllers/           # Auth, Food & Order controllers
│   │   ├── database/              # SQL schema & automated seeder
│   │   ├── middleware/            # JWT auth, error handler, HTTP logger
│   │   └── routes/                # Express API routes
│   ├── test/                      # Automated API integration tests
│   ├── .env.example               # Template environment configuration
│   ├── package.json               # Backend dependencies and scripts
│   ├── server.js                  # Server entrypoint with graceful shutdown
│   └── README.md                  # Comprehensive API documentation
├── lib/                           # Flutter mobile frontend
│   ├── data/
│   │   ├── repositories/          # Food & Auth repositories with offline fallback
│   │   └── services/              # ApiService with auto-host resolution & JWT
│   ├── domain/models/             # FoodItem, CartItem, UserProfile
│   ├── ui/
│   │   ├── features/              # Intro, Auth, Dashboard, Cart, Profile
│   │   ├── theme/                 # Dark/Light theme tokens & color schemes
│   │   ├── view_models/           # ChangeNotifier state providers
│   │   └── widgets/               # Reusable UI components
│   └── main.dart                  # Flutter entrypoint
├── test/                          # Flutter unit & widget tests
└── README.md
```

---

## 🚀 Quick Start

### 1. Start the Backend Server

```bash
cd backend
npm install
npm run init-db    # Seed sample categories, food items, and demo user
npm start          # Starts server on http://localhost:5000
```

> **Run Automated API Tests:**
> ```bash
> npm test
> ```

### 2. Run the Flutter Mobile App

```bash
# In the root project directory:
flutter pub get
flutter run
```

> **Targeting Android Emulator or Physical Device:**
> - Android Emulator connects automatically to `http://10.0.2.2:5000`.
> - For physical devices or web, update `baseUrl` in `lib/data/services/api_service.dart` or pass `--dart-define=API_URL=http://<YOUR_IP>:5000/api`.

---

## ☁️ Free Backend Deployment Options

Deploy the `backend/` folder on any modern cloud hosting provider at zero cost:

### Option 1: Render.com (Recommended — 100% Free)
1. Fork or push this repository to GitHub: `https://github.com/soham1304s/kaka-app`.
2. Go to [Render.com](https://render.com) and click **New Web Service**.
3. Connect your `kaka-app` GitHub repository.
4. Configure service settings:
   - **Root Directory**: `backend`
   - **Environment**: `Node`
   - **Build Command**: `npm install && npm run init-db`
   - **Start Command**: `npm start`
5. Add Environment Variables:
   - `PORT`: `5000`
   - `JWT_SECRET`: `your_super_secret_jwt_key`
   - `NODE_ENV`: `production`
6. Click **Deploy**. Render gives you a free URL like: `https://kaka-food-api.onrender.com`.

### Option 2: Fly.io (Free Tier)
1. Install Fly CLI: `curl -L https://fly.io/install.sh | sh`
2. Run in `backend/`:
   ```bash
   cd backend
   fly launch
   fly deploy
   ```

---

## 🔑 Demo Account Credentials

| Role | Email | Password |
|---|---|---|
| Demo User | `chef.alex@kakafood.com` | `password123` |

*(You can also use the one-tap **"Demo Sign In"** button on the Auth screen).*

---

## 🧪 Testing

```bash
# Run Backend Integration Tests
cd backend && npm test

# Run Flutter Unit & Widget Tests
flutter test

# Run Flutter Static Analysis
flutter analyze
```

---

## 📜 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
