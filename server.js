// Init project
const dotenv = require('dotenv').config();
const express = require('express');
const jsonParser = require('body-parser').json();

var app = express();
app.use(jsonParser);

// Define root handler for ALL methods, default error for now. 
app.all("/",function(req, res){
	res.status(400);
	res.json({"message":"Bad request, missing path."})
});

// load routes and connect them to their paths
var booking = require('./routes/booking');
app.use("/booking",booking);

var admin = require('./routes/admin');
app.use("/admin",admin);

// listen for requests :)
var listener = app.listen(process.env.PORT, function () {
	console.log('Your app is listening on port ' + listener.address().port);
});
