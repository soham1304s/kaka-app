const { runAsync, getAsync, allAsync } = require('../config/db');

// 1. Create a new order
async function createOrder(req, res, next) {
  try {
    const userId = req.user.id;
    const {
      items,
      deliveryAddress,
      paymentMethod,
      discountAmount = 0.0,
    } = req.body;

    if (!items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({
        success: false,
        error: { message: 'Order must contain at least one item.' },
      });
    }

    if (!deliveryAddress || !paymentMethod) {
      return res.status(400).json({
        success: false,
        error: { message: 'Delivery address and payment method are required.' },
      });
    }

    // Calculate totals
    let totalAmount = 0;
    for (const item of items) {
      const qty = Number(item.quantity) || 1;
      const price = Number(item.price) || 0;
      totalAmount += qty * price;
    }

    const finalAmount = Math.max(0, totalAmount - Number(discountAmount));
    const orderId = `ord_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`;

    // Insert Order
    await runAsync(
      `INSERT INTO orders (
        id, user_id, total_amount, discount_amount, final_amount,
        status, delivery_address, payment_method
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        orderId,
        userId,
        totalAmount,
        discountAmount,
        finalAmount,
        'placed',
        deliveryAddress,
        paymentMethod,
      ]
    );

    // Insert Order Items
    for (const item of items) {
      const itemId = `item_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`;
      await runAsync(
        `INSERT INTO order_items (
          id, order_id, food_id, food_name, quantity, price, image_url
        ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
          itemId,
          orderId,
          item.foodId || item.id,
          item.foodName || item.name || 'Gourmet Dish',
          Number(item.quantity) || 1,
          Number(item.price) || 0,
          item.imageUrl || '',
        ]
      );
    }

    // Award loyalty points & increment total_orders for user
    const earnedPoints = Math.floor(finalAmount * 0.1); // 10% points
    await runAsync(
      `UPDATE users SET
        total_orders = total_orders + 1,
        loyalty_points = loyalty_points + ?
      WHERE id = ?`,
      [earnedPoints, userId]
    );

    // Fetch created order with items
    const orderRow = await getAsync('SELECT * FROM orders WHERE id = ?', [orderId]);
    const itemRows = await allAsync('SELECT * FROM order_items WHERE order_id = ?', [orderId]);

    res.status(201).json({
      success: true,
      data: {
        order: {
          id: orderRow.id,
          userId: orderRow.user_id,
          totalAmount: Number(orderRow.total_amount),
          discountAmount: Number(orderRow.discount_amount),
          finalAmount: Number(orderRow.final_amount),
          status: orderRow.status,
          deliveryAddress: orderRow.delivery_address,
          paymentMethod: orderRow.payment_method,
          createdAt: orderRow.created_at,
          items: itemRows.map((r) => ({
            id: r.id,
            foodId: r.food_id,
            foodName: r.food_name,
            quantity: r.quantity,
            price: Number(r.price),
            imageUrl: r.image_url,
          })),
        },
        earnedLoyaltyPoints: earnedPoints,
        message: 'Order placed successfully! Chef is preparing your meal.',
      },
    });
  } catch (error) {
    next(error);
  }
}

// 2. Get user orders
async function getUserOrders(req, res, next) {
  try {
    const userId = req.user.id;
    const orderRows = await allAsync(
      'SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC',
      [userId]
    );

    const orders = [];
    for (const order of orderRows) {
      const items = await allAsync(
        'SELECT * FROM order_items WHERE order_id = ?',
        [order.id]
      );
      orders.push({
        id: order.id,
        userId: order.user_id,
        totalAmount: Number(order.total_amount),
        discountAmount: Number(order.discount_amount),
        finalAmount: Number(order.final_amount),
        status: order.status,
        deliveryAddress: order.delivery_address,
        paymentMethod: order.payment_method,
        createdAt: order.created_at,
        items: items.map((r) => ({
          id: r.id,
          foodId: r.food_id,
          foodName: r.food_name,
          quantity: r.quantity,
          price: Number(r.price),
          imageUrl: r.image_url,
        })),
      });
    }

    res.json({
      success: true,
      count: orders.length,
      data: orders,
    });
  } catch (error) {
    next(error);
  }
}

// 3. Get single order details
async function getOrderById(req, res, next) {
  try {
    const { id } = req.params;
    const order = await getAsync('SELECT * FROM orders WHERE id = ?', [id]);

    if (!order) {
      return res.status(404).json({
        success: false,
        error: { message: `Order '${id}' not found.` },
      });
    }

    const items = await allAsync('SELECT * FROM order_items WHERE order_id = ?', [id]);

    res.json({
      success: true,
      data: {
        id: order.id,
        userId: order.user_id,
        totalAmount: Number(order.total_amount),
        discountAmount: Number(order.discount_amount),
        finalAmount: Number(order.final_amount),
        status: order.status,
        deliveryAddress: order.delivery_address,
        paymentMethod: order.payment_method,
        createdAt: order.created_at,
        items: items.map((r) => ({
          id: r.id,
          foodId: r.food_id,
          foodName: r.food_name,
          quantity: r.quantity,
          price: Number(r.price),
          imageUrl: r.image_url,
        })),
      },
    });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  createOrder,
  getUserOrders,
  getOrderById,
};
