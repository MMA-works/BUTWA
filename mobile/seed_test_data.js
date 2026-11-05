const http = require('http');

function post(path, body, token) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify(body);
    const req = http.request({
      hostname: '127.0.0.1',
      port: 8080,
      path: '/api/v1' + path,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(data),
        ...(token ? { 'Authorization': `Bearer ${token}` } : {})
      }
    }, res => {
      let resBody = '';
      res.on('data', chunk => resBody += chunk);
      res.on('end', () => resolve(JSON.parse(resBody)));
    });
    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

async function run() {
  console.log('1. Logging in as ali@batwa.com...');
  const loginRes = await post('/auth/login', {
    identifier: 'ali@batwa.com',
    password: 'Password@123'
  });
  console.log('Login res:', loginRes.success, loginRes.message);
  const token = loginRes.data?.accessToken;

  if (token) {
    console.log('2. Adding $5,000 topup...');
    const topupRes = await post('/wallets/topup', {
      amount: 5000.00,
      paymentMethod: 'BANK_TRANSFER',
      description: 'Initial Wallet Balance'
    }, token);
    console.log('Topup res:', topupRes.success, topupRes.data?.amount, 'Balance now:', topupRes.data?.destinationWallet?.balance);
  }

  console.log('3. Registering second recipient user (sara@batwa.com)...');
  try {
    const regSara = await post('/auth/register', {
      fullName: 'Sara Ahmed',
      email: 'sara@batwa.com',
      phoneNumber: '+923009876543',
      password: 'Password@123',
      customTag: 'sara'
    });
    console.log('Sara registration:', regSara.success, regSara.message);
  } catch (e) {
    console.log('Sara register error (may already exist):', e.message);
  }

  console.log('Done!');
}

run().catch(console.error);
