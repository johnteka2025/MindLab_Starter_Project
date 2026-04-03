const http = require('http');

const server = http.createServer((req, res) => {

    // FORCE CORS FIRST (NO CONDITIONS)
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    // HANDLE PREFLIGHT IMMEDIATELY
    if (req.method === 'OPTIONS') {
        res.writeHead(200);
        res.end();
        return;
    }

    if (req.method === 'POST' && req.url === '/score') {
        let body = '';

        req.on('data', chunk => {
            body += chunk.toString();
        });

        req.on('end', () => {
            const parsed = JSON.parse(body || '{}');

            const response = {
                success: true,
                received: parsed,
                score: 1
            };

            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify(response));
        });

        return;
    }

    res.writeHead(404);
    res.end();
});

server.listen(8085, '127.0.0.1', () => {
    console.log("Server running on port 8085");
});
