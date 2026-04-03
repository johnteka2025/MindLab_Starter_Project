const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

app.post('/score', (req, res) => {
    console.log('[API REQUEST]', req.method, req.url);
    console.log('[API BODY]', req.body);

    res.json({
        success: true,
        data: { received: req.body }
    });
});

app.get('/health', (req, res) => {
    res.json({ status: 'ok' });
});

const PORT = 8085;
app.listen(PORT, () => {
    console.log('Server running on port', PORT);
});
