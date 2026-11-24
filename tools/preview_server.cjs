const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '..', 'build', 'web');
const mime = {'.html':'text/html; charset=utf-8','.js':'text/javascript; charset=utf-8','.json':'application/json','.css':'text/css; charset=utf-8','.wasm':'application/wasm','.png':'image/png','.svg':'image/svg+xml','.ico':'image/x-icon','.ttf':'font/ttf','.woff2':'font/woff2'};
http.createServer((req, res) => {
  let requested;
  try { requested = decodeURIComponent(new URL(req.url, 'http://127.0.0.1').pathname); }
  catch { res.writeHead(400).end(); return; }
  const file = path.resolve(root, '.' + (requested === '/' ? '/index.html' : requested));
  if (!file.startsWith(root + path.sep)) { res.writeHead(403).end(); return; }
  fs.stat(file, (error, stat) => {
    const target = !error && stat.isFile() ? file : path.join(root, 'index.html');
    fs.readFile(target, (readError, body) => {
      if (readError) { res.writeHead(500).end(); return; }
      res.writeHead(200, {'Content-Type': mime[path.extname(target)] || 'application/octet-stream', 'Cache-Control':'no-store'});
      res.end(body);
    });
  });
}).listen(8080, '127.0.0.1', () => console.log('Serving latest build at http://127.0.0.1:8080'));

