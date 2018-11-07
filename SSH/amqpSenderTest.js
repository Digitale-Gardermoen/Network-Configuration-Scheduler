const amqp = require('amqplib/callback_api');
const dotenv = require("dotenv").config();

amqp.connect('amqp://' + process.env.AMQP_USER + ':' +  process.env.AMQP_PASS + '@' + process.env.AMQP_HOST, function(err, conn) {

    if (err) {
        console.log(err);
        return;
    }

  conn.createChannel(function(err, ch) {

    if (err) {
        console.log(err);
        return;
    }

    var q = process.env.AMQP_QUEUE;
    var msg = 'Hello World!';

    ch.assertQueue(q, {durable: false});
    ch.sendToQueue(q, Buffer.from(msg));
    console.log(" [x] Sent %s", msg);
  });
  setTimeout(function() { conn.close(); process.exit(0) }, 500);
});