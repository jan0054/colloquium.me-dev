// JavaScript Document for common functions
var clickItem = {
	page: 'page',
	type: 'type',
	typevalue: 'value',
	click: function(){
	  	var link = this.page+"?"+this.type+"="+this.typevalue;
	  	parent.mainFrame.location = link;
	}
}

function listGetCareerWithAuthor(inputID)
{
	Person = Parse.Object.extend("Person");
	var person = new Person();
	person.id = K4;

	Parse.initialize(K1, K2);
	ListItem = Parse.Object.extend("Career");
	query = new Parse.Query(ListItem);
	query.equalTo("author", person);
	query.limit(500);
	query.descending('createdAt');
	query.find({
		success: function(results){
			var ul=document.getElementById(inputID);
			for (var i=0; i<results.length; i++){
				var object=results[i];
				var li = document.createElement("li");
				li.appendChild(document.createTextNode(object.get('content')));
				li.setAttribute("id", object.id);
				li.page = "addcareer.html";
				li.type = "id";
				li.typevalue = object.id;
				li.style.margin = "2px";
				li.addEventListener('click', clickItem.click, false);
				ul.appendChild(li);
			}
		},
		error: function(error)
		{
			alert("Session Error: "+error.code+" "+error.message);
		}
	})
}

function listGetAuthorWithEvent(inputID)
{
	Event = Parse.Object.extend("Event");
	var event = new Event();
	event.id = K3;

	Parse.initialize(K1, K2);
	ListItem = Parse.Object.extend("Person");
	query = new Parse.Query(ListItem);
	query.equalTo("events", event);
	query.limit(1000);
	query.ascending('last_name');
	query.find({
		success: function(results){
			var ul=document.getElementById(inputID);
			for (var i=0; i<results.length; i++)
			{
				var object=results[i];
				var li = document.createElement("li");
				li.appendChild(document.createTextNode(object.get('last_name')+", "+object.get('first_name')));
				li.page = "addperson.html";
				li.type = "email";
				li.typevalue = object.get('email');
				li.style.margin = "2px";
				li.addEventListener('click', clickItem.click, false);
				li.setAttribute("id", object.id);
				ul.appendChild(li);
			} 
		},
		error: function(error)
		{
			alert("Author Error: "+error.code+" "+error.message);
		}
	})
}

function listGetLocationWithEvent(inputID)
{
	Event = Parse.Object.extend("Event");
	var event = new Event();
	event.id = K3;

	Parse.initialize(K1, K2);
	ListItem = Parse.Object.extend("Location");
	query = new Parse.Query(ListItem);
	query.equalTo("event", event);
	query.limit(500);
	query.ascending('name');
	query.find({
		success: function(results){
			var ul=document.getElementById(inputID);
			for (var i=0; i<results.length; i++){
				var object=results[i];
				var li = document.createElement("li");
				li.appendChild(document.createTextNode(object.get('name')));
				li.setAttribute("id", object.id);
				li.page = "addlocation.html";
				li.type = "id";
				li.typevalue = object.id;
				li.style.margin = "2px";
				li.addEventListener('click', clickItem.click, false);
				ul.appendChild(li);
			}
		},
		error: function(error)
		{
			alert("Location Error: "+error.code+" "+error.message);
		}
	})
}

function listGetSessionWithEvent(inputID)
{
	Event = Parse.Object.extend("Event");
	var event = new Event();
	event.id = K3;

	Parse.initialize(K1, K2);
	ListItem = Parse.Object.extend("Session");
	query = new Parse.Query(ListItem);
	query.equalTo("event", event);
	query.limit(500);
	query.ascending('name');
	query.find({
		success: function(results){
			var ul=document.getElementById(inputID);
			for (var i=0; i<results.length; i++){
				var object=results[i];
				var li = document.createElement("li");
				li.appendChild(document.createTextNode(object.get('name')));
				li.setAttribute("id", object.id);
				li.page = "addsession.html";
				li.type = "id";
				li.typevalue = object.id;
				li.style.margin = "5px";
				li.addEventListener('click', clickItem.click, false);
				ul.appendChild(li);
			}
		},
		error: function(error)
		{
			alert("Session Error: "+error.code+" "+error.message);
		}
	})
}

function listGetTalkWithEvent(inputID)
{
	Event = Parse.Object.extend("Event");
	var event = new Event();
	event.id = K3;

	Parse.initialize(K1, K2);
	ListItem = Parse.Object.extend("Talk");
	query = new Parse.Query(ListItem);
	query.equalTo("event", event);
	query.limit(1000);
	query.ascending('name');
	query.find({
		success: function(results){
			var ul=document.getElementById(inputID);
			for (var i=0; i<results.length; i++){
				var object=results[i];
				var li = document.createElement("li");
				li.appendChild(document.createTextNode(object.get('name')));
				li.setAttribute("id", object.id);
				li.page = "addtalk.html";
				li.type = "name";
				li.typevalue = object.get('name');
				li.style.margin = "2px";
				li.addEventListener('click', clickItem.click, false);
				ul.appendChild(li);
			}
		},
		error: function(error)
		{
			alert("Session Error: "+error.code+" "+error.message);
		}
	})
}

function listGetVenueWithEvent(inputID)
{
	Event = Parse.Object.extend("Event");
	var event = new Event();
	event.id = K3;

	Parse.initialize(K1, K2);
	ListItem = Parse.Object.extend("Venue");
	query = new Parse.Query(ListItem);
	query.equalTo("event", event);
	query.limit(500);
	query.ascending('name');
	query.find({
		success: function(results){
			var ul=document.getElementById(inputID);
			for (var i=0; i<results.length; i++){
				var object=results[i];
				var li = document.createElement("li");
				li.appendChild(document.createTextNode(object.get('name')));
				li.setAttribute("id", object.id);
				li.page = "addvenue.html";
				li.type = "id";
				li.typevalue = object.id;
				li.style.margin = "2px";
				li.addEventListener('click', clickItem.click, false);
				ul.appendChild(li);
			}
		},
		error: function(error)
		{
			alert("Session Error: "+error.code+" "+error.message);
		}
	})
}

function selectGetAuthorWithEvent(inputID)
{
	Event = Parse.Object.extend("Event");
	var event = new Event();
	event.id = K3;

	Parse.initialize(K1, K2);
	ListItem = Parse.Object.extend("Person");
	query = new Parse.Query(ListItem);
	query.equalTo("events", event);
	query.limit(1000);
	query.ascending('last_name');
	query.find({
		success: function(results){
			var sel=document.getElementById(inputID);
			for (var i=0; i<results.length; i++)
			{
				var object=results[i];
				if(i==0){
					var new_option = new Option(object.get('last_name')+", "+object.get('first_name'),object.id,1,1);
				}
				else
				{
					var new_option = new Option(object.get('last_name')+", "+object.get('first_name'),object.id);
				}
				sel.options.add(new_option);
			} 
		},
		error: function(error)
		{
			alert("Author Error: "+error.code+" "+error.message);
		}
	})
}

function selectGetLocationWithEvent(inputID)
{
	Event = Parse.Object.extend("Event");
	var event = new Event();
	event.id = K3;

	Parse.initialize(K1, K2);
	ListItem = Parse.Object.extend("Location");
	query = new Parse.Query(ListItem);
	query.equalTo("event", event);
	query.limit(500);
	query.ascending('name');
	query.find({
		success: function(results){
			for (var i=0; i<results.length; i++){
				var object=results[i];
				var sel=document.getElementById(inputID);
				if(i==0){
					var new_option = new Option(object.get('name'),object.id,1,1);
				}
				else
				{
					var new_option = new Option(object.get('name'),object.id);
				}
				sel.options.add(new_option);
				}
			},
		error: function(error)
		{
			alert("Location Error: "+error.code+" "+error.message);
		}
	})
}

function selectGetSessionWithEvent(inputID)
{
	Event = Parse.Object.extend("Event");
	var event = new Event();
	event.id = K3;

	Parse.initialize(K1, K2);
	ListItem = Parse.Object.extend("Session");
	query = new Parse.Query(ListItem);
	query.equalTo("event", event);
	query.limit(500);
	query.ascending('name');
	query.find({
		success: function(results){
			for (var i=0; i<results.length; i++){
				var object=results[i];
				var sel=document.getElementById(inputID);
				if(i==0){
					var new_option = new Option(object.get('name'),object.id,1,1);
				}
				else
				{
					var new_option = new Option(object.get('name'),object.id);
				}
				sel.options.add(new_option);
				}
			},
		error: function(error)
		{
			alert("Session Error: "+error.code+" "+error.message);
		}
	})
}

function getAllEvent(inputID)
{
	Parse.initialize(K1, K2);
	ListItem = Parse.Object.extend("Event");
	query = new Parse.Query(ListItem);
	query.limit(500);
	query.descending('name');
	query.find({
		success: function(results){
			for (var i=0; i<results.length; i++){
				var object=results[i];
				var sel=document.getElementById(inputID);
				if(i==0){
					var new_option = new Option(object.get('name'),object.id,1,1);
				}
				else
				{
					var new_option = new Option(object.get('name'),object.id);
				}
				sel.options.add(new_option);
				}
			},
		error: function(error)
		{
			alert("Event Error: "+error.code+" "+error.message);
		}
	})
}

function GetUnique(inputArray) {
	var outputArray = [];
	for (var i = 0; i < inputArray.length; i++) {
		if (outputArray.some(function(value, index, array){return value == inputArray[i]? true : false;}) == false) {
			outputArray.push(inputArray[i]);
		}
	}
	return outputArray;
}

