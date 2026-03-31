const express = require('express')
const router = express.Router()

router.post('/score', (req, res) => {
    res.json({ success: true, received: req.body })
})

module.exports = router
