const sql = require('../../DB')

exports.GetSwitches = function(req, res) {
    console.log('hei')
    sql.executeQuery(
        res, 'EXEC Assets.GetSwitches()'
    )
}