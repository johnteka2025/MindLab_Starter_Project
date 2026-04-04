const express = require('express');
const app = express();

app.use(express.json());

app.post('/score', (req, res) => {
    console.log('[BODY]', req.body);

    res.json({
        success: true,
        received: req.body
    });
});

const PORT = 8085;

app.listen(PORT, () => {
    console.log('Server running on port ' + PORT);
});
