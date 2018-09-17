const switches = require('../controller/switch')
const router = require('express').Router()

// Main router
router.route('/')
    .get((req, res) => {
        switches.getSwitches(req, res)
    });

router.route('/id/:switchID')
    .get((req, res) => {
        switches.getSwitchByID(req, res, req.params.switchID)
    });

router.route('/sw/:switchName')
    .get((req, res) => {
        switches.getSwitchByName(req, res, req.params.switchName)
    });

router.route('/roomid/:roomID')
    .get((req, res) => {
        switches.getSwitchByRoomID(req, res, req.params.roomID)
    });
module.exports = router