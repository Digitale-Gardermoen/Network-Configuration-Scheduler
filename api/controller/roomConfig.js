const sql = require('../../DB')

exports.getRoomConfig = function(req, res) {
    sql.executeProcedure(
        (result)=>{res.end(JSON.stringify(result.recordset))}, // send result to rabbitMQ
        'Assets.GetSwitchByID', //Make this get room config, create a proc to get this
        'SwitchID',
        inputVal //Change this to check if value is given or not.
    )
}