const sql = require('../../DB')

exports.GetSwitches = function(req, res) {
    sql.executeProcedure(
        (result)=>{
            res.end(JSON.stringify(result.recordset))
        }, 'Assets.GetSwitches',
        'SwitchName',
        null //Change this to check if value is given or not.
    )
}