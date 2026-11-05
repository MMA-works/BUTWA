const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 8085;
const WEB_DIR = path.join(__dirname, 'build', 'web');
const CSV_PATH = path.join('C:', 'Users', 'M. Ali', 'Desktop', 'BATWA_Transactions_Ledger.csv');

// Initialize CSV header if not present
if (!fs.existsSync(CSV_PATH)) {
  const header = 'Date & Time,Transaction Ref,Sender,Recipient,Bank / Channel,Amount (PKR),Fee (PKR),Status,Note\n';
  fs.writeFileSync(CSV_PATH, header, 'utf8');
}

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.wav': 'audio/wav',
  '.mp4': 'video/mp4',
  '.woff': 'application/font-woff',
  '.ttf': 'application/font-ttf',
  '.eot': 'application/vnd.ms-fontobject',
  '.otf': 'application/font-otf',
  '.wasm': 'application/wasm'
};

const server = http.createServer((req, res) => {
  // CORS Headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  // 📝 Live Transaction Logger Endpoint (Appends directly to Excel CSV on Desktop)
  if (req.url === '/api/log-transaction' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      try {
        const item = JSON.parse(body);
        const now = new Date().toLocaleString('en-PK', { timeZone: 'Asia/Karachi' });
        const row = `"${now}","${item.reference || ''}","${item.sender || 'ali@batwa.com'}","${item.recipient || ''}","${item.bank || 'Batwa Wallet'}","${item.amount || 0}","${item.fee || 0}","${item.status || 'SUCCESS'}","${item.note || ''}"\n`;
        fs.appendFileSync(CSV_PATH, row, 'utf8');
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: true, message: 'Logged to Excel CSV' }));
      } catch (err) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: false, error: err.message }));
      }
    });
    return;
  }

  let parsedUrl = req.url.split('?')[0];
  let safeSuffix = path.normalize(parsedUrl).replace(/^(\.\.[\/\\])+/, '');
  let filePath = path.join(WEB_DIR, safeSuffix);

  if (fs.existsSync(filePath) && fs.statSync(filePath).isDirectory()) {
    filePath = path.join(filePath, 'index.html');
  }

  if (!fs.existsSync(filePath)) {
    filePath = path.join(WEB_DIR, 'index.html');
  }

  const ext = path.extname(filePath).toLowerCase();
  const contentType = MIME_TYPES[ext] || 'application/octet-stream';

  fs.readFile(filePath, (err, content) => {
    if (err) {
      res.writeHead(500);
      res.end(`Server Error: ${err.code}`);
    } else {
      res.writeHead(200, {
        'Content-Type': contentType,
        'Cache-Control': 'no-cache'
      });
      res.end(content);
    }
  });
});

server.listen(PORT, '127.0.0.1', () => {
  console.log(`BATWA Web Server running at http://localhost:${PORT}/`);
  console.log(`Excel CSV Ledger: ${CSV_PATH}`);
});
