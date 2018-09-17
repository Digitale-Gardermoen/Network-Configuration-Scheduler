const sql = require('../../DB')

exports.getRoom = function(req, res, inputVal) {
    sql.executeProcedure(
        (result)=>{res.end(JSON.stringify(result.recordset))},
        'Config.GetRoomByID',
        'RoomID',
        inputVal //Change this to check if value is given or not.
    )
}