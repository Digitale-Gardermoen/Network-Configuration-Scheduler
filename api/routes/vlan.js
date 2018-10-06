const vlan = require('../controller/vlan')
const router = require('express').Router()

// Main router
router.route('/id/:switchID')
    .get((req, res) => {
        vlan.getRoom(req, res, req.params.switchID)
    });

module.exports = router