const sql = require('mssql')

const dbConfig = {
    server: 'localhost\\DOTDB', //Enable TCP/IP and have SQL Server browser running
    database: 'ZoneController', 
    user: 'test', //Set security to allow SQL logins, it is default to Integrated only.
    password: 'test',
    
    options: {
        encrypt: false
    }
}

//Function to connect to database and execute query
exports.executeQuery = async function(callback, query){
    try {
        const pool = await sql.connect(dbConfig);
    
        const result = await pool.request()
            //.input('SwitchName', sql.NVarChar(30), null)
            //.output('output_parameter', sql.VarChar(50))
            .execute(query);
    
        sql.close();
        callback(result);
    }
    catch(err){
        console.log(err)
    }
     
    sql.on('error', err => {
        // ... error handler
    })          
}