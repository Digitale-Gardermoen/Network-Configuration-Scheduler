const room = require('../controller/vlan')
const router = require('express').Router()

// Main router
router.route('/id/:switchID')
    .get((req, res) => {
        room.getRoom(req, res, req.params.switchID)
    });

module.exports = router