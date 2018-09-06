const sql = require('../../DB')

exports.GetSwitches = function(req, res) {
    sql.executeQuery(
        (result)=>{
            res.end(JSON.stringify(result.recordset))
        }, 'Assets.GetSwitches'
    )
}