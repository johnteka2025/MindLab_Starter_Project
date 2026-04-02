const express = require('express');
const app = express();

app.use(express.json());

app.post('/score', (req, res) => {
    console.log("[REQ] POST /score", req.body);

    res.json({
        success: true,
        received: req.body,
        score: 1
    });
});

app.listen(8085, () => {
    console.log("Server running on port 8085");
});


