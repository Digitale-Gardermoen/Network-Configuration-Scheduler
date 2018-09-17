const sql = require('../../DB')

exports.getSwitches = function(req, res, inputVal) {
    sql.executeProcedure(
        (result)=>{res.end(JSON.stringify(result.recordset))},
        'Assets.GetSwitches',
        'SwitchName',
        inputVal //Change this to check if value is given or not.
    )
}

exports.getSwitchByID = function(req, res, inputVal) {
    sql.executeProcedure(
        (result)=>{res.end(JSON.stringify(result.recordset))},
        'Assets.GetSwitches',
        'SwitchID',
        inputVal //Change this to check if value is given or not.
    )
}