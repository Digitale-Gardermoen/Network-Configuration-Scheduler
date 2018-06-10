var express = require('express');
var router = express.Router();

router.get("/",function(req,res){
	res.send("<h1>Welcome...</h1><p>...to the administration interface for the Network Configuration Scheduler.</p>");
});


module.exports = router;