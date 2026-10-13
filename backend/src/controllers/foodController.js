const { runAsync, getAsync, allAsync } = require('../config/db');

function formatFoodItem(row) {
  if (!row) return null;
  let parsedIngredients = [];
  try {
    parsedIngredients = typeof row.ingredients === 'string' 
      ? JSON.parse(row.ingredients) 
      : (row.ingredients || []);
  } catch {
    parsedIngredients = [];
  }

  return {
    id: row.id,
    name: row.name,
    category: row.category,
    description: row.description,
    price: Number(row.price),
    rating: Number(row.rating),
    reviewCount: Number(row.review_count),
    deliveryTime: row.delivery_time,
    calories: Number(row.calories),
    imageUrl: row.image_url,
    isPopular: Boolean(row.is_popular),
    isChefSpecial: Boolean(row.is_chef_special),
    ingredients: parsedIngredients,
    spicyLevel: Number(row.spicy_level),
    isVegetarian: Boolean(row.is_vegetarian),
  };
}

// 1. Get food items with filtering and sorting
async function getAllFoods(req, res, next) {
  try {
    const { category, search, sortBy } = req.query;

    let sql = 'SELECT * FROM food_items WHERE 1=1';
    const params = [];

    // Filter by Category
    if (category && category !== 'All') {
      sql += ' AND category = ?';
      params.push(category);
    }

    // Filter by Search Query
    if (search && search.trim().length > 0) {
      const q = `%${search.trim().toLowerCase()}%`;
      sql += ' AND (LOWER(name) LIKE ? OR LOWER(description) LIKE ? OR LOWER(category) LIKE ?)';
      params.push(q, q, q);
    }

    // Sort order
    switch (sortBy) {
      case 'Rating':
        sql += ' ORDER BY rating DESC, review_count DESC';
        break;
      case 'Price: Low to High':
        sql += ' ORDER BY price ASC';
        break;
      case 'Price: High to Low':
        sql += ' ORDER BY price DESC';
        break;
      case 'Fastest Delivery':
        sql += ' ORDER BY delivery_time ASC';
        break;
      case 'Popular':
      default:
        sql += ' ORDER BY is_popular DESC, rating DESC';
        break;
    }

    const rows = await allAsync(sql, params);
    const items = rows.map(formatFoodItem);

    res.json({
      success: true,
      count: items.length,
      data: items,
    });
  } catch (error) {
    next(error);
  }
}

// 2. Get single food item by ID
async function getFoodById(req, res, next) {
  try {
    const { id } = req.params;
    const row = await getAsync('SELECT * FROM food_items WHERE id = ?', [id]);

    if (!row) {
      return res.status(404).json({
        success: false,
        error: { message: `Food item with id '${id}' not found.` },
      });
    }

    res.json({
      success: true,
      data: formatFoodItem(row),
    });
  } catch (error) {
    next(error);
  }
}

// 3. Get all categories
async function getCategories(req, res, next) {
  try {
    const rows = await allAsync('SELECT name FROM categories ORDER BY sort_order ASC');
    const categories = rows.map((r) => r.name);

    res.json({
      success: true,
      data: categories,
    });
  } catch (error) {
    next(error);
  }
}

// 4. Get promo banners
async function getPromoBanners(req, res, next) {
  try {
    const rows = await allAsync('SELECT * FROM promo_banners ORDER BY id ASC');
    const banners = rows.map((r) => ({
      id: r.id,
      title: r.title,
      subtitle: r.subtitle,
      tag: r.tag,
      discountCode: r.discount_code,
      imageUrl: r.image_url,
    }));

    res.json({
      success: true,
      data: banners,
    });
  } catch (error) {
    next(error);
  }
}

// 5. Toggle favorite item for authenticated user
async function toggleFavorite(req, res, next) {
  try {
    const userId = req.user.id;
    const { id: foodId } = req.params;

    const existing = await getAsync(
      'SELECT * FROM favorites WHERE user_id = ? AND food_id = ?',
      [userId, foodId]
    );

    let isFavorited = false;
    if (existing) {
      await runAsync(
        'DELETE FROM favorites WHERE user_id = ? AND food_id = ?',
        [userId, foodId]
      );
      isFavorited = false;
    } else {
      await runAsync(
        'INSERT INTO favorites (user_id, food_id) VALUES (?, ?)',
        [userId, foodId]
      );
      isFavorited = true;
    }

    // Update count in users table
    const favCountRow = await getAsync(
      'SELECT COUNT(*) as count FROM favorites WHERE user_id = ?',
      [userId]
    );
    await runAsync(
      'UPDATE users SET saved_favorites_count = ? WHERE id = ?',
      [favCountRow.count, userId]
    );

    res.json({
      success: true,
      data: {
        foodId,
        isFavorited,
        totalFavorites: favCountRow.count,
        message: isFavorited ? 'Added to favorites' : 'Removed from favorites',
      },
    });
  } catch (error) {
    next(error);
  }
}

// 6. Get all favorite foods of authenticated user
async function getFavorites(req, res, next) {
  try {
    const userId = req.user.id;
    const rows = await allAsync(
      `SELECT f.* FROM food_items f
       INNER JOIN favorites fav ON f.id = fav.food_id
       WHERE fav.user_id = ?
       ORDER BY fav.created_at DESC`,
      [userId]
    );

    res.json({
      success: true,
      count: rows.length,
      data: rows.map(formatFoodItem),
    });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getAllFoods,
  getFoodById,
  getCategories,
  getPromoBanners,
  toggleFavorite,
  getFavorites,
};
