const switches = require('../controller/switch')
const router = require('express').Router()

// Main router
router.route('/')
    .get((req, res) => {
        switches.GetSwitches(req, res, null)
    });

router.route('/ID=:SwitchID')
    .get((req, res) => {
        switches.GetSwitchByID(req, res, req.params.SwitchID)
    });

router.route('/SW=:SwitchName')
    .get((req, res) => {
        switches.GetSwitches(req, res, req.params.SwitchName)
    });

module.exports = router