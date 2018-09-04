const sql = require('mssql')

const dbConfig = {
    user: 'test',
    password: 'test',
    server: 'localhost',
    database: 'ZoneController',
    port: 1433,

    options: {
        encrypt: false
    }
}

//Function to connect to database and execute query
exports.executeQuery = function(res, query){
    sql.connect(dbConfig).then(pool => {
        // Query
        
        return pool.request()
        //.input('input_parameter', sql.Int, value)
        //.output('output_parameter', sql.VarChar(50))
        .query(query)
    }).then(result => {
        console.dir(result)
    }).catch(err => {
        console.log(err)
    })
     
    sql.on('error', err => {
        // ... error handler
    })          
}