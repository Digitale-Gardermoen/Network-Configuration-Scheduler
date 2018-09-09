const sql = require('../../DB')

exports.GetSwitches = function(req, res, inputVal) {
    sql.executeProcedure(
        (result)=>{res.end(JSON.stringify(result.recordset))},
        'Assets.GetSwitches',
        'SwitchName',
        inputVal //Change this to check if value is given or not.
    )
}