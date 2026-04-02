const express = require('express');
const app = express();

app.use(express.json());

app.post('/score', (req, res) => {
    console.log('[REQ] POST /score', req.body);
    res.json({ ok: true, received: req.body });
});

app.get('/', (req, res) => {
    res.send('Backend running');
});

app.listen(8085, '127.0.0.1', () => {
    console.log('Server running on port 8085');
});
