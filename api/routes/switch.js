const switches = require('../controller/switch')
const router = require('express').Router()

// Main router
router.route('/:SwitchName')
    .get((req, res) => {
        res.send(req.params);
        //switches.GetSwitches(req, res, req.params);
    })

module.exports = router