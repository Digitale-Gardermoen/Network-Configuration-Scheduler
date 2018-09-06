const switches = require('../controller/switch')
const router = require('express').Router()

// Main router
router.route('/')
    .get((req, res) => {
        switches.GetSwitches(req, res)
        //res.json({ message: ['/', 'Main router!'] })
    })

module.exports = router