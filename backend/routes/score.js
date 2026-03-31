module.exports = function registerScoreRoute(app) {
    app.post("/score", function (req, res) {
        res.json({
            ok: true,
            received: req.body || null
        })
    })
}
