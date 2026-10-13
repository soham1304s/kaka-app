const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { runAsync, getAsync } = require('../config/db');
const { JWT_SECRET } = require('../middleware/authMiddleware');

function formatUser(row) {
  if (!row) return null;
  return {
    id: row.id,
    fullName: row.full_name,
    email: row.email,
    phoneNumber: row.phone_number || '',
    avatarUrl: row.avatar_url || '',
    membershipTier: row.membership_tier || 'Welcome Foodie ⭐',
    totalOrders: Number(row.total_orders) || 0,
    savedFavoritesCount: Number(row.saved_favorites_count) || 0,
    loyaltyPoints: Number(row.loyalty_points) || 0,
    walletBalance: Number(row.wallet_balance) || 0.0,
    address: row.address || '',
    preferredPayment: row.preferred_payment || 'UPI / Google Pay',
  };
}

function generateToken(user) {
  return jwt.sign(
    { id: user.id, email: user.email },
    JWT_SECRET,
    { expiresIn: '30d' }
  );
}

// 1. Register new user
async function register(req, res, next) {
  try {
    const { name, email, phone, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        error: { message: 'Name, email, and password are required fields.' },
      });
    }

    const cleanEmail = email.trim().toLowerCase();
    const existingUser = await getAsync('SELECT id FROM users WHERE email = ?', [cleanEmail]);

    if (existingUser) {
      return res.status(409).json({
        success: false,
        error: { message: 'An account with this email already exists. Please log in.' },
      });
    }

    const passwordHash = await bcrypt.hash(password, 10);
    const userId = `usr_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
    const avatar = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&auto=format&fit=crop&q=80';

    await runAsync(
      `INSERT INTO users (
        id, full_name, email, password_hash, phone_number, avatar_url,
        membership_tier, total_orders, saved_favorites_count, loyalty_points,
        wallet_balance, address, preferred_payment
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        userId,
        name.trim(),
        cleanEmail,
        passwordHash,
        phone || '+91 98765 00000',
        avatar,
        'Welcome Foodie ⭐',
        0,
        0,
        150, // Welcome signup bonus
        150.00, // ₹150 welcome wallet bonus
        'Add your primary delivery address',
        'UPI / Google Pay',
      ]
    );

    const userRow = await getAsync('SELECT * FROM users WHERE id = ?', [userId]);
    const user = formatUser(userRow);
    const token = generateToken(user);

    res.status(201).json({
      success: true,
      data: {
        user,
        token,
        message: 'Account created successfully with ₹150 welcome bonus!',
      },
    });
  } catch (error) {
    next(error);
  }
}

// 2. Login user
async function login(req, res, next) {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        error: { message: 'Please provide both email and password.' },
      });
    }

    const cleanEmail = email.trim().toLowerCase();
    const userRow = await getAsync('SELECT * FROM users WHERE email = ?', [cleanEmail]);

    if (!userRow) {
      return res.status(401).json({
        success: false,
        error: { message: 'Invalid credentials. No user found with this email.' },
      });
    }

    const isMatch = await bcrypt.compare(password, userRow.password_hash);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        error: { message: 'Invalid credentials. Incorrect password.' },
      });
    }

    const user = formatUser(userRow);
    const token = generateToken(user);

    res.json({
      success: true,
      data: {
        user,
        token,
        message: `Welcome back, ${user.fullName}!`,
      },
    });
  } catch (error) {
    next(error);
  }
}

// 3. Demo login (Chef Alex)
async function demoLogin(req, res, next) {
  try {
    const demoRow = await getAsync('SELECT * FROM users WHERE email = ?', ['chef.alex@kakafood.com']);
    
    if (!demoRow) {
      return res.status(404).json({
        success: false,
        error: { message: 'Demo user not found. Please restart server to seed data.' },
      });
    }

    const user = formatUser(demoRow);
    const token = generateToken(user);

    res.json({
      success: true,
      data: {
        user,
        token,
        message: 'Logged in as Demo Chef Alex Vance',
      },
    });
  } catch (error) {
    next(error);
  }
}

// 4. Get authenticated user profile
async function getProfile(req, res, next) {
  try {
    const userRow = await getAsync('SELECT * FROM users WHERE id = ?', [req.user.id]);
    if (!userRow) {
      return res.status(404).json({
        success: false,
        error: { message: 'User profile not found.' },
      });
    }

    res.json({
      success: true,
      data: {
        user: formatUser(userRow),
      },
    });
  } catch (error) {
    next(error);
  }
}

// 5. Update user profile
async function updateProfile(req, res, next) {
  try {
    const userId = req.user.id;
    const {
      fullName,
      phoneNumber,
      avatarUrl,
      address,
      preferredPayment,
      walletBalance,
    } = req.body;

    const existing = await getAsync('SELECT * FROM users WHERE id = ?', [userId]);
    if (!existing) {
      return res.status(404).json({
        success: false,
        error: { message: 'User not found.' },
      });
    }

    await runAsync(
      `UPDATE users SET
        full_name = COALESCE(?, full_name),
        phone_number = COALESCE(?, phone_number),
        avatar_url = COALESCE(?, avatar_url),
        address = COALESCE(?, address),
        preferred_payment = COALESCE(?, preferred_payment),
        wallet_balance = COALESCE(?, wallet_balance),
        updated_at = CURRENT_TIMESTAMP
      WHERE id = ?`,
      [
        fullName || null,
        phoneNumber || null,
        avatarUrl || null,
        address || null,
        preferredPayment || null,
        walletBalance !== undefined ? walletBalance : null,
        userId,
      ]
    );

    const updatedRow = await getAsync('SELECT * FROM users WHERE id = ?', [userId]);

    res.json({
      success: true,
      data: {
        user: formatUser(updatedRow),
        message: 'Profile updated successfully.',
      },
    });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  register,
  login,
  demoLogin,
  getProfile,
  updateProfile,
};
