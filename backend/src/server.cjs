const express = require('express');
const cors = require('cors');

const app = express();

app.use(cors());
app.use(express.json());

app.post('/score', (req, res) => {
    console.log('[BODY]', req.body);
    res.json({ success: true, data: req.body });
});

app.listen(8085, () => {
    console.log('Server running on port 8085');
});
