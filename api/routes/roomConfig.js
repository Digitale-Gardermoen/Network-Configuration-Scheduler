const roomConfig = require('../controller/roomConfig')
const router = require('express').Router()

// Main router
router.route('/:roomID/:zoneName')
    .get((req, res) => {
        roomConfig.getRoomConfig(req, res, req.params.roomID, req.params.zoneName)
    });

    module.exports = router;