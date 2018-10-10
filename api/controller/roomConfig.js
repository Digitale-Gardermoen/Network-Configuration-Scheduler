const sql = require('../../DB')

exports.getRoomConfig = function(req, res, inputVal, inputVal2) {
    sql.executeProcedureTwoParams(
        (result)=>{res.end(JSON.stringify(result.recordset))}, // send result to rabbitMQ
        'Config.GetRoomConfig',
        'RoomID',
        inputVal,
        'ZoneName',
        inputVal2
    )
}