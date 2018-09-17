const sql = require('../../DB')

exports.getSwitches = function(req, res) {
    sql.executeProcedure(
        (result)=>{res.end(JSON.stringify(result.recordset))},
        'Assets.GetSwitches'
    )
}

exports.getSwitchByID = function(req, res, inputVal) {
    sql.executeProcedure(
        (result)=>{res.end(JSON.stringify(result.recordset))},
        'Assets.GetSwitchByID',
        'SwitchID',
        inputVal //Change this to check if value is given or not.
    )
}

exports.getSwitchByName = function(req, res, inputVal) {
    sql.executeProcedure(
        (result)=>{res.end(JSON.stringify(result.recordset))},
        'Assets.GetSwitchByName',
        'SwitchName',
        inputVal //Change this to check if value is given or not.
    )
}

exports.getSwitchByRoomID = function(req, res, inputVal) {
    sql.executeProcedure(
        (result)=>{res.end(JSON.stringify(result.recordset))},
        'Assets.GetSwitchByRoomID',
        'RoomID',
        inputVal //Change this to check if value is given or not.
    )
}