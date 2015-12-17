var _ = require("underscore");
 
//set up search words for the class "Talk"
Parse.Cloud.beforeSave("Talk", function(request, response) {
    var talk = request.object;
    var fn = "";
    var ln = "";
    var ins = "";
    var author = talk.get("author");
    author.fetch({
        success: function(author) {
            fn = author.get("first_name");
            ln = author.get("last_name");
            ins = author.get("institution");
               
            var toLowerCase = function(w) { return w.toLowerCase(); };
            var stopWords = ["the", "in", "and"]
        
            var word_desc;
            if(talk.get("content") != null) {
                word_desc = talk.get("content").split(/\b/);
                word_desc = _.map(word_desc, toLowerCase);
                word_desc = _.filter(word_desc, function(w) { return w.match(/^\w+$/) && ! _.contains(stopWords, w); });
            }
        
            var word_name;
            if(talk.get("name") != null) {
                word_name = talk.get("name").split(/\b/);
                word_name = _.map(word_name, toLowerCase);
                word_name = _.filter(word_name, function(w) { return w.match(/^\w+$/) && ! _.contains(stopWords, w); });
            }
       
            var fname;
            if(fn != null) {
                fname = fn.split(/\b/);
                fname = _.map(fname, toLowerCase);
                fname = _.filter(fname, function(w) { return w.match(/^\w+$/) && ! _.contains(stopWords, w); });
            }
       
            var lname;
            if(ln != null) {
                lname = ln.split(/\b/);
                lname = _.map(lname, toLowerCase);
                lname = _.filter(lname, function(w) { return w.match(/^\w+$/) && ! _.contains(stopWords, w); });
            }
       
            var inst;
            if (ins != null) {
                inst = ins.split(/\b/);
                inst = _.map(inst, toLowerCase);
                inst = _.filter(inst, function(w) { return w.match(/^\w+$/) && ! _.contains(stopWords, w); });
            }
            
            var fullname;
			var chname;
			if (ln != null && fn != null) {
				var sfn = fn.split(/\b/);
				var sln = ln.split(/\b/);
				fullname = sln+sfn;
				fullname = _.map(fullname, toLowerCase);
		
				var cfn = fn;
				var cln = ln;
				chname = cln+cfn;
				chname = chname.split(/\b/);
				chname = _.map(chname, toLowerCase);
			}
			
			var fulltitle;
			if(talk.get("name") != null) {
                var stn = talk.get("name").split(/\b/);
                fulltitle = _.map(stn, toLowerCase);
            }
       
            var words = word_desc.concat(word_name);
            words = words.concat(fname);
            words = words.concat(lname);
            words = words.concat(inst);
            words = words.concat(fullname);
			words = words.concat(chname);
			words = words.concat(fulltitle);
            words = _.uniq(words);
            talk.set("words", words);
    
            response.success();
        }
    });
});

//set up search words for the class "Person"
Parse.Cloud.beforeSave("Person", function(request, response) {
    var person = request.object;
    var toLowerCase = function(w) { return w.toLowerCase(); };
    var stopWords = ["the", "in", "and"]
    var fname;
    if (person.get("first_name") != null) {
        fname = person.get("first_name").split(/\b/);
        fname = _.map(fname, toLowerCase);
        //fname = _.filter(fname, function(w) { return w.match(/^\w+$/) && ! _.contains(stopWords, w); });
    }
        
    var lname;
    if (person.get("last_name") != null) {
        lname = person.get("last_name").split(/\b/);
        lname = _.map(lname, toLowerCase);
        //lname = _.filter(lname, function(w) { return w.match(/^\w+$/) && ! _.contains(stopWords, w); });
    }
    
    var fullname;
    var chname;
    if (person.get("last_name") != null && person.get("first_name") != null) {
    	var fn = person.get("first_name").split(/\b/);
    	var ln = person.get("last_name").split(/\b/);
    	fullname = ln+fn;
    	fullname = _.map(fullname, toLowerCase);
    	
    	var cfn = person.get("first_name");
    	var cln = person.get("last_name");
    	chname = cln+cfn;
    	chname = chname.split(/\b/);
    	chname = _.map(chname, toLowerCase);
    }
    
    var inststr = person.get("institution");
    if (inststr == null)
    {
        inststr = " ";
    }   
    var inst = inststr.split(/\b/);

    inst = _.map(inst, toLowerCase);
    //inst = _.filter(inst, function(w) { return w.match(/^\w+$/) && ! _.contains(stopWords, w); });
    
    var words = fname.concat(lname);
    words = words.concat(inst);
    words = words.concat(fullname);
    words = words.concat(chname);
    words = _.uniq(words);
    person.set("words", words);
    
    response.success();
});

Parse.Cloud.beforeSave(Parse.User, function(request, response) {
	//get user info
    var user_username = request.object.get("username");
    var user_fn = request.object.get("first_name");
    var user_ln = request.object.get("last_name");
    var user_inst = request.object.get("institution");
    var user_link = request.object.get("link");
    var user_mailswitch = request.object.get("email_status");
    var user_chatswitch = request.object.get("chat_status");
    var user_eventswitch = request.object.get("event_status");
    var user_events = request.object.get("events");
    
    if ( user_fn != null && user_ln != null && user_username != null) 
    {
    	//do the search array (words)
		var toLowerCase = function(w) { return w.toLowerCase(); };
		var fullname;
		var chname;
		if (user_ln != null && user_fn != null) {
			var fn = user_fn.split(/\b/);
			var ln = user_ln.split(/\b/);
			fullname = ln+fn;
			fullname = _.map(fullname, toLowerCase);	
			var cfn = user_fn;
			var cln = user_ln;
			chname = cln+cfn;
			chname = chname.split(/\b/);
			chname = _.map(chname, toLowerCase);
		}    
		var stopWords = ["the", "in", "and"]
		var words;
		if(user_fn != null)
		{
			words = user_fn.split(/\b/);
		}
		if(user_ln != null)
		{
			words = words.concat(user_ln.split(/\b/));
		}
		if(user_inst != null)
		{
			words = words.concat(user_inst.split(/\b/));
		}
		if(fullname != null)
		{
			words = words.concat(fullname);
		}
		if(chname != null)
		{
			words = words.concat(chname);
		}
		words = _.map(words, toLowerCase);
		words = _.uniq(words);
		request.object.set("words", words);
    
    	console.log("Fields present, proceeding");
		var Person = Parse.Object.extend("Person");
		var emailquery = new Parse.Query(Person);
		var linked_person;
		emailquery.equalTo("email", user_username);
		emailquery.find().then(function(results) {
			if (results.length == 0) {   
					//nothing found, create new person
					var person_obj = new Person();
					//person_obj.set("user", request.object);
					person_obj.set("is_user", 1);
					person_obj.set("email", user_username);
					person_obj.set("first_name", user_fn);
					person_obj.set("last_name", user_ln);
					person_obj.set("institution", user_inst);
					person_obj.set("link", user_link);
					person_obj.set("email_status", user_mailswitch);
					person_obj.set("chat_status", user_chatswitch);
					person_obj.set("event_status", user_eventswitch);
					person_obj.set("events", user_events);
					console.log("New Person created");
					return person_obj.save();
			}
			else {
				var person_obj = results[0];
				//person_obj.set("user", request.object);
				person_obj.set("is_user", 1);
				person_obj.set("first_name", user_fn);
				person_obj.set("last_name", user_ln);
				person_obj.set("institution", user_inst);
				person_obj.set("link", user_link);
				person_obj.set("email_status", user_mailswitch);
				person_obj.set("chat_status", user_chatswitch);
				person_obj.set("event_status", user_eventswitch);
				person_obj.set("events", user_events);
				console.log("Existing Person updated");
				return person_obj.save();
			}
		},
		function(error) {
			//person query error
			console.log("person query error " + error.code + " " + error.message);
			response.error(error.code+" : "+error.message);
		}).then(function(object) {
			//person object saved successfully
			Parse.Cloud.useMasterKey();
			console.log("Person saved success");
			linked_person = object;
			request.object.set("is_person", 1);
			request.object.set("person", linked_person);
			response.success();
		}, 
		function(error) {
			//person save error
			console.log("person save error " + error.code + " " + error.message);
			response.error(error.code+" : "+error.message);
		});
    }
    else 
    {
    console.log("Fields missing, skipping");
    	response.success();
    }
});

Parse.Cloud.afterSave(Parse.User, function(request) {
	var user_username = request.object.get("username");
	var Person = Parse.Object.extend("Person");
	var query = new Parse.Query(Person);
	query.equalTo("email", user_username);
	query.find().then(function(results) {
		if (results.length == 0) {   
			//some sort of error handling here?
		}
		else {
			var person_obj = results[0];
			person_obj.set("user", request.object);
			console.log("Aftersave Person-user updated");
			person_obj.save();
		}
	},
	function(error) {
		console.log("after save person query error " + error.code + " " + error.message);
	});
});
 
//refreshes the User class to generate and update search words array
Parse.Cloud.define("refreshUsers", function(request, response) {
  var query = new Parse.Query(Parse.User);
  query.notEqualTo("debug_status", 0);
  query.find({
    success: function(results) {
    	Parse.Cloud.useMasterKey();
      	for (var i = 0; i < results.length; ++i) {
        	var user_obj = results[i];
        	user_obj.set("debug_status", 0);
        	user_obj.save(); 
      	}
      	response.success();
    },
    error: function() {
      	response.error(error.code+" : "+error.message);
      	console.error(error.code+" : "+error.message);
    }
  });
});

//do push notification for event announcements
Parse.Cloud.afterSave("Announcement", function(request) {
	
	//get the event object then fetch it
	var announcement_obj = request.object
	var event_obj = announcement_obj.get("event");
	
	event_obj.fetch({
        success: function(event_obj) {
            var event_name = event_obj.get("name");
            var event_id = event_obj.id;
            
            //arrays to hold the users
			var all_attendees = [];
			var notify_attendees = [];
	
			//query the event, include attendees (users)
			var Event = Parse.Object.extend("Event");
			var query = new Parse.Query(Event);
			query.equalTo("objectId", event_id);
			console.log("EVENT ID:");
			console.log(event_id);
			query.include("attendees");
			query.first({
				success: function(object) {
					all_attendees = object.get("attendees");
					console.log("All attendees:");
					console.log(all_attendees.length);
					for (var i=0; i<all_attendees.length; i++)
					{
						var user_obj = all_attendees[i];
						if (user_obj.get("event_status")==1)
						{
							notify_attendees.push(user_obj);
							console.log("User Added!");
						}
					}
					console.log("Notify attendees:");
					console.log(notify_attendees.length);
					var query = new Parse.Query(Parse.Installation);
					query.containedIn("user", notify_attendees);
					Parse.Push.send({
						where: query,
						data: {
							alert: "Announcement from: "+event_name 
						}
					}, {
						success: function() {
							console.log("announcement push successful");
						},
						error: function(error) {
							console.error(error.code+" : "+error.message);
						}
					});
			
				},
				error: function(error) {
					alert("Error: " + error.code + " " + error.message);
				}
			});
        }
    });
});
