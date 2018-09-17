const room = require('../controller/room')
const router = require('express').Router()

// Main router
router.route('/id/:roomID')
    .get((req, res) => {
        room.getRoom(req, res, req.params.roomID)
    });

module.exports = router