const sql = require('../../DB')

exports.getVlan = function(req, res, inputVal) {
    sql.executeProcedure(
        (result)=>{res.end(JSON.stringify(result.recordset))},
        'Config.GetVLANBySwitchID',
        'SwitchID',
        inputVal //Change this to check if value is given or not.
    )
}