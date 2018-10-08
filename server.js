// Init project
const dotenv = require('dotenv').config();
const express = require('express');
const jsonParser = require('body-parser').json();

var app = express();
app.use(jsonParser);

app.use("/", express.static(__dirname + "/public"));

// Define root handler for ALL methods, default error for now. 
app.all("/",function(req, res){
	res.status(400);
	res.json({"message":"Bad request, missing path."})
});

app.get("/roomconfig/:room", (req, res) => {
	// TODO: Insert actual code here. Below is placeholder for front-end testing
	var zone = ["intern", "sikker"];
	res.json({
		room: req.params.room,
		zone: zone[Math.round(Math.random())]
	});
});

app.post("/roomconfig",(req, res)=>{
	// TODO: Implement logic here, code below is placeholder
	console.log(req.body);
	res.json(req.body);
});

// load routes and connect them to their paths
var booking = require('./api/routes/booking');
app.use("/booking", booking);

var admin = require('./api/routes/admin');
app.use("/admin", admin);

const switches = require('./api/routes/switch');
app.use("/switches", switches);

const room = require('./api/routes/room');
app.use("/room", room);

const vlan = require('./api/routes/vlan');
app.use("/vlan", vlan);

// listen for requests :)
var listener = app.listen(process.env.PORT, function () {
	console.log('Your app is listening on port ' + listener.address().port);
});
