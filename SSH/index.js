const SSH2Shell = require('ssh2shell')

// Host configuration with connection settings and commands
const host = {
    server: {
        host: process.env.SWITCH_HOST,
        userName: process.env.SWITCH_USER,
        password: process.env.SWITCH_PASS,
    },
    commands: ["en", "sh int status"]
};

//Create a new instance passing in the host object
SSH = new SSH2Shell(host)

//Use a callback function to process the full session text
callback = function (sessionText) {
    console.log(sessionText)
}

//Start the process
SSH.connect(callback)