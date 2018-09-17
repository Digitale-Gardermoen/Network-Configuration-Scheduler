const switches = require('../controller/switch')
const router = require('express').Router()

// Main router
router.route('/')
    .get((req, res) => {
        switches.getSwitches(req, res, null)
    });

router.route('/id/:switchID')
    .get((req, res) => {
        switches.getSwitchByID(req, res, req.params.switchID)
    });

router.route('/sw/:switchName')
    .get((req, res) => {
        switches.getSwitches(req, res, req.params.switchName)
    });

module.exports = router