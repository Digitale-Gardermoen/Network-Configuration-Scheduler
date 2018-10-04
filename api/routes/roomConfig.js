const roomConfig = require('../controller/roomConfig')
const router = require('express').Router()

// Main router
router.route('/:roomID/:zoneName')
    .get((req, res) => {
        switches.getRoomConfig(req, res)
    });