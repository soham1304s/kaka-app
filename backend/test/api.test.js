const http = require('http');
const app = require('../src/app');
const { initializeDatabase } = require('../src/database/initDb');

function request(server, options, body = null) {
  return new Promise((resolve, reject) => {
    const port = server.address().port;
    const reqOptions = {
      hostname: '127.0.0.1',
      port,
      path: options.path,
      method: options.method || 'GET',
      headers: options.headers || {},
    };

    if (body) {
      reqOptions.headers['Content-Type'] = 'application/json';
    }

    const req = http.request(reqOptions, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        let json = null;
        try {
          json = JSON.parse(data);
        } catch {
          json = data;
        }
        resolve({ status: res.statusCode, data: json });
      });
    });

    req.on('error', reject);
    if (body) {
      req.write(JSON.stringify(body));
    }
    req.end();
  });
}

async function runTests() {
  console.log('🧪 Starting Kaka Food Backend API integration tests...\n');
  await initializeDatabase();

  const server = app.listen(0);
  let passed = 0;
  let failed = 0;

  function assert(condition, message) {
    if (condition) {
      console.log(`  ✅ PASS: ${message}`);
      passed++;
    } else {
      console.error(`  ❌ FAIL: ${message}`);
      failed++;
    }
  }

  try {
    // 1. Health check
    const health = await request(server, { path: '/api/health' });
    assert(health.status === 200 && health.data.status === 'ok', 'GET /api/health returns ok');

    // 2. Categories
    const categories = await request(server, { path: '/api/food/categories' });
    assert(
      categories.status === 200 && Array.isArray(categories.data.data) && categories.data.data.includes('Burgers'),
      'GET /api/food/categories returns category list including Burgers'
    );

    // 3. Food items
    const foods = await request(server, { path: '/api/food' });
    assert(
      foods.status === 200 && foods.data.data.length >= 8,
      `GET /api/food returns gourmet items (${foods.data.data.length} items found)`
    );

    // 4. Food filtering
    const burgerFilter = await request(server, { path: '/api/food?category=Burgers' });
    assert(
      burgerFilter.status === 200 && burgerFilter.data.data.every((i) => i.category === 'Burgers'),
      'GET /api/food?category=Burgers filters correctly'
    );

    // 5. Promo banners
    const promos = await request(server, { path: '/api/food/promos' });
    assert(
      promos.status === 200 && promos.data.data.length >= 3,
      'GET /api/food/promos returns promo cards'
    );

    // 6. Demo login
    const demo = await request(server, { path: '/api/auth/demo', method: 'POST' });
    assert(
      demo.status === 200 && demo.data.data.token && demo.data.data.user.email === 'chef.alex@kakafood.com',
      'POST /api/auth/demo returns Chef Alex profile and JWT token'
    );
    const token = demo.data.data.token;

    // 7. Authenticated profile check
    const profile = await request(server, {
      path: '/api/auth/me',
      headers: { Authorization: `Bearer ${token}` },
    });
    assert(
      profile.status === 200 && profile.data.data.user.fullName === 'Alex Vance',
      'GET /api/auth/me returns authenticated user'
    );

    // 8. Register new user
    const testEmail = `test_${Date.now()}@kakafood.com`;
    const reg = await request(
      server,
      { path: '/api/auth/register', method: 'POST' },
      { name: 'Priya Sharma', email: testEmail, password: 'password123', phone: '+91 99887 76655' }
    );
    assert(
      reg.status === 201 && reg.data.data.user.walletBalance === 150.0,
      'POST /api/auth/register creates user with ₹150 wallet credit'
    );
    const userToken = reg.data.data.token;

    // 9. Place order
    const order = await request(
      server,
      {
        path: '/api/orders',
        method: 'POST',
        headers: { Authorization: `Bearer ${userToken}` },
      },
      {
        items: [
          {
            foodId: 'f1',
            foodName: 'Double Truffle Smash Burger',
            quantity: 2,
            price: 399.0,
            imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd',
          },
        ],
        deliveryAddress: 'Flat 402, High Street Towers, Bangalore',
        paymentMethod: 'UPI (Google Pay)',
        discountAmount: 150.0,
      }
    );
    assert(
      order.status === 201 && order.data.data.order.finalAmount === 648.0,
      `POST /api/orders places order (Total: ₹798, Final with ₹150 off: ₹${order.data.data?.order?.finalAmount})`
    );

    // 10. Get user orders
    const userOrders = await request(server, {
      path: '/api/orders',
      headers: { Authorization: `Bearer ${userToken}` },
    });
    assert(
      userOrders.status === 200 && userOrders.data.data.length === 1,
      'GET /api/orders returns user order history with items'
    );

    console.log(`\n🎉 Results: ${passed} passed, ${failed} failed.`);
    server.close();
    process.exit(failed > 0 ? 1 : 0);
  } catch (err) {
    console.error('Unhandled test failure:', err);
    server.close();
    process.exit(1);
  }
}

runTests();
