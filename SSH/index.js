const dotenv = require("dotenv").config();
const SSH2Shell = require("ssh2shell");
const amqp = require('amqplib/callback_api');

console.log(process.env.AMQP_USER)
const connectionString = 'amqp://' + process.env.AMQP_USER + ':' +  process.env.AMQP_PASS + '@' + process.env.AMQP_HOST
console.log(connectionString)

const testMessage = {
    host: process.env.SSH_HOST,
    port: 22,
    username: process.env.SSH_USER,
    password: process.env.SSH_PASS,
    commands: [
        " ",
        "terminal length 0",
        "en",
        "sh vlan | i active"
    ]
}

const ssh = createSSHFromMessage(testMessage);
ssh.connect();

// RabbitMQ connection
amqp.connect(connectionString, (err, conn) => {

    if (err) {
        console.log(err);
        return;
    }

    // Listen to channel defined in variable q
    conn.createChannel((err, ch) => {

        if (err) {
            console.log(err);
            return;
        }

        const q = process.env.AMQP_QUEUE;
        ch.assertQueue(q, { durable: true });

        console.log(" [*] Waiting for messages in %s. To exit press CTRL+C", q);

        // Get messages in queue
        ch.consume(q, (msg) => {
            console.log(" [x] Received %s", msg.content.toString());

            // Create a configured SSH2Shell object from message
            //const ssh = createSSHFromMessage(msg);
            //ssh.connect();    // Execute SSH2Shell object

        }, { noAck: true });
    });
});


// Returns configured SSH2Shell object
function createSSHFromMessage(message) {
    const timeout = 10 * 1000;
    const server = {
        host: message.host,
        port: message.port,
        userName: message.username,
        password: message.password,
        algorithms: {
            kex: [
                'diffie-hellman-group1-sha1',
                'ecdh-sha2-nistp256',
                'ecdh-sha2-nistp384',
                'ecdh-sha2-nistp521',
                'diffie-hellman-group-exchange-sha256',
                'diffie-hellman-group14-sha1'],
            cipher: [
                'aes128-ctr',
                'aes192-ctr',
                'aes256-ctr',
                'aes128-gcm',
                'aes128-gcm@openssh.com',
                'aes256-gcm',
                'aes256-gcm@openssh.com',
                'aes256-cbc'
            ]
        }
    }

    let hostname = "";

    function onCommandProcessing(command, response, sshObj, stream) {
        //console.log("Command: '" + command + "'", response);
        if (command == "en" && response.indexOf("assword:") != -1 && sshObj.firstRun !== true) {
            stream.write(process.env.SSH_PASS + "\n");
            sshObj.firstRun = true;
        }
    }

    function onCommandComplete(command, result, sshObj, stream) {
        if (command == " ") {
            hostname = result.replace(" \r\n", "").replace(/>$/, "");
            console.log("hostname:", hostname);
        }
        result = result.replace(command + "\r\n", "");
        result = result.replace(hostname + ">", "");
        result = result.replace(hostname + "#", "");
        result = result.replace(/\r\n$/, "");

        console.log("Command:", "'" + command + "'", "Result:");
        console.log(result);
        console.log("----");
        sshObj.firstRun = false;
    }

    function onEnd(sessionText, sshObj) {
        console.log("---- End ----")
    }

    let host = {};
    host.idleTimeOut = timeout;
    host.server = server;
    host.commands = message.commands;
    host.onCommandComplete = onCommandComplete;
    host.onCommandProcessing = onCommandProcessing;
    host.onEnd = onEnd;

    return new SSH2Shell(host);
}
