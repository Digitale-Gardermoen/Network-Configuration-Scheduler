document.addEventListener("DOMContentLoaded", function(event){
	document.querySelector("#intern").onclick = function(){
		configureRoom("intern");
	};

	document.querySelector("#sikker").onclick = function(){
		configureRoom("sikker");
	};

	sendRequest('GET','/roomconfig',null,(data)=>{
		console.log(data);
		changeZone(data.zone);
	})
});

function changeZone(zone){
	var header = document.querySelector("header");
	header.classList.remove('intern', 'sikker');
	header.classList.add(zone);

	var footer = document.querySelector("footer");
	footer.classList.remove('intern', 'sikker');
	footer.classList.add(zone);
}

function configureRoom(zone){
	var params = {};

	location.search.replace("?","").split("&").forEach( value => {
		var parts = value.split("=");
		params[parts[0]] = parts[1];
	 });

	var room = params['room'];
	if(!room){
		console.log("No room defined");
		return;
	}

	sendRequest('POST','/roomconfig', JSON.stringify({
		room:room,
		zone:zone
	}), (data) => {
		console.log(data);
	});
}

function sendRequest(method, url, data, callback){
	var request = new XMLHttpRequest();
	request.open(method, url, true);

	if(method === 'POST'){
		request.setRequestHeader('Content-Type', 'application/json; charset=UTF-8');
	}
	if(method !== 'POST' && data){
		data = null;
	}

	request.onload = function() {
		if (request.status >= 200 && request.status < 400) {
			// Success!
			var resp = request.responseText;
			var data;
			try{
				data = JSON.parse(resp);
			}
			catch(error){
				console.log("Unable to parse JSON: ", resp);
			}

			if(typeof data === 'object'){
				callback(data);
			}

		} else {
			// We reached our target server, but it returned an error
		}
	};

	request.onerror = function() {
	// There was a connection error of some sort
	};

	request.send(data);
}