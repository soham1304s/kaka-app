const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');
const { authenticateToken } = require('../middleware/authMiddleware');

// All order routes require authentication
router.use(authenticateToken);

router.post('/', orderController.createOrder);
router.get('/', orderController.getUserOrders);
router.get('/:id', orderController.getOrderById);

module.exports = router;
