const express = require('express');
const router = express.Router();
const foodController = require('../controllers/foodController');
const { authenticateToken } = require('../middleware/authMiddleware');

// Specific endpoints before :id param
router.get('/categories', foodController.getCategories);
router.get('/promos', foodController.getPromoBanners);
router.get('/favorites', authenticateToken, foodController.getFavorites);

// General food items
router.get('/', foodController.getAllFoods);
router.get('/:id', foodController.getFoodById);
router.post('/:id/favorite', authenticateToken, foodController.toggleFavorite);

module.exports = router;
