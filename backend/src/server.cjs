const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json());

const dataFile = path.join(__dirname, '../data/scores.json');

app.post('/score', (req, res) => {
    try {
        console.log('[BODY]', req.body);

        let scores = [];
        try {
            scores = JSON.parse(fs.readFileSync(dataFile, 'utf8'));
        } catch (err) {
            console.error('[READ ERROR]', err);
            scores = [];
        }

        const entry = {
            timestamp: new Date().toISOString(),
            ...req.body
        };

        scores.push(entry);

        fs.writeFileSync(dataFile, JSON.stringify(scores, null, 2));

        res.json({ success: true, data: entry });

    } catch (err) {
        console.error('[FULL ERROR]', err);
        res.status(500).json({ success: false, error: err.message });
    }
});

app.get('/health', (req, res) => {
    res.json({ status: 'ok' });
});

const PORT = 8085;
app.listen(PORT, () => {
    console.log('Server running on port', PORT);
});
