const dotenv = require("dotenv").config();
const SSH2Shell = require("ssh2shell");
const amqp = require('amqplib/callback_api');

console.log(process.env.AMQP_USER)

// RabbitMQ connection
amqp.connect('amqp://' + process.env.AMQP_USER + ':' +  process.env.AMQP_PASS + '@' + process.env.AMQP_HOST, function (err, conn) {

    if (err) {
        console.log(err);
        return;
    }

    // Listen to channel q
    conn.createChannel(function (err, ch) {

        if (err) {
            console.log(err);
            return;
        }

        const q = process.env.AMQP_QUEUE;
        ch.assertQueue(q, { durable: false });

        console.log(" [*] Waiting for messages in %s. To exit press CTRL+C", q);

        // Get messages in queue
        ch.consume(q, function (msg) {
            console.log(" [x] Received %s", msg.content.toString());
            /* 
            // TODO: Generate SSH2Shell config object
            var ssh = new SSH2Shell(host);
            ssh.connect();
            */
        }, { noAck: true });
    });
});

function test() {
    const timeout = 10 * 1000;
    const server = {
        host: "localhost",
        port: 22,
        userName: process.env.SSH_USERNAME,
        password: process.env.SSH_PASSWORD,
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

    var hostname = "";

    function onCommandProcessing(command, response, sshObj, stream) {
        //console.log("Command: '" + command + "'", response);
        if (command == "en" && response.indexOf("assword:") != -1 && sshObj.firstRun !== true) {
            stream.write(process.env.SSH_PASSWORD + "\n");
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

    function done(sessionText) {
        console.log("---------- DONE -----------\n", sessionText);
    }

    const commands = [
        " ",
        "terminal length 0",
        "en",
        "sh vlan | i active"
    ];

    var host = {};
    host.idleTimeOut = timeout;
    host.server = server;
    host.commands = commands;
    host.onCommandComplete = onCommandComplete;
    host.onCommandProcessing = onCommandProcessing;


    server.host = "10.252.0.32";

    /**
     * Below here is the running of the config.
     */

    var ssh = new SSH2Shell(host);
    ssh.connect();
}