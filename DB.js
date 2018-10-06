const sql = require('mssql')

const dbConfig = {
    server: 'localhost', //Enable TCP/IP and have SQL Server browser running
    database: 'ZoneController', 
    user: 'test', //Set security to allow SQL logins, it is default to Integrated only.
    password: 'test',
    options: {
        encrypt: false
    }
}

//Function to connect to database and execute procedures
exports.executeProcedure = async function(callback, query, inputName, inputVal){
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input(inputName, inputVal) //InputName = the name of the parameter in the SQL Procedure
            //------------------------------------
            //.input(inputName, [sqlDataType], inputVal);
            //JS Data Type To SQL Data Type Map:
            //String -> sql.NVarChar
            //Number -> sql.Int
            //Boolean -> sql.Bit
            //Date -> sql.DateTime
            //Buffer -> sql.VarBinary
            //sql.Table -> sql.TVP
            //This should not be needed at all for this application, since we do not have any abstract datatypes in the database. No need for datatype.
            //------------------------------------
            .execute(query);
        sql.close(); //There is a function to close pools as well, not sure if its better to close the connection in the pool, or the current sql connection
        //https://www.npmjs.com/package/mssql#close
        callback(result);
    }
    catch(err){
        console.log(err)
        sql.close()
    }
    sql.on('error', err => {
        // ... error handler
    })          
}

exports.executeProcedureNoParam = async function(callback, query) {
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .execute(query);
        sql.close();
        callback(result);
    }
    catch(err) {
        console.log(err);
        sql.close();
    }
    sql.on('error', err => {
        // ... error handler
    })
}

exports.executeProcedureTwoParams = async function(callback, query, inputName, inputVal, inputName2, inputVal2){
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input(inputName, inputVal)
            .input(inputName2, inputVal2)
            .execute(query);
        sql.close();
        //https://www.npmjs.com/package/mssql#close
        callback(result);
    }
    catch(err){
        console.log(err)
        sql.close()
    }
    sql.on('error', err => {
        // ... error handler
    })
}
