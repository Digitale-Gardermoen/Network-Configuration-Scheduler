const switches = require('../controller/switch')
const router = require('express').Router()

// Main router
router.route('/:SwitchName')
    .get((req, res) => {
        switches.GetSwitches(req, res, req.params.SwitchName)
    });

module.exports = router