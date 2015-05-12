var _ = require("underscore");

//set up search words for the class "Poster"
Parse.Cloud.beforeSave("Poster", function(request, response) {
    var poster = request.object;
    var fn = "";
    var ln = "";
    var ins = "";
    var author = poster.get("author");
    author.fetch({
        success: function(author) {
            fn = author.get("first_name");
            ln = author.get("last_name");
            ins = author.get("institution");
            
            var toLowerCase = function(w) { return w.toLowerCase(); };
            var stopWords = ["the", "in", "and"]
            
            var word_desc = poster.get("content").split(/\b/);
            word_desc = _.map(word_desc, toLowerCase);
            word_desc = _.filter(word_desc, function(w) { return w.match(/^\w+$/) && ! _.contains(stopWords, w); });
            
            var word_name = poster.get("name").split(/\b/);
            word_name = _.map(word_name, toLowerCase);
            word_name = _.filter(word_name, function(w) { return w.match(/^\w+$/) && ! _.contains(stopWords, w); });
            
            var fname = fn.split(/\b/);
            fname = _.map(fname, toLowerCase);
            fname = _.filter(fname, function(w) { return w.match(/^\w+$/) && ! _.contains(stopWords, w); });
            
            var lname = ln.split(/\b/);
            lname = _.map(lname, toLowerCase);
            lname = _.filter(lname, function(w) { return w.match(/^\w+$/) && ! _.contains(stopWords, w); });
            
            var inst = ins.split(/\b/);
            lname = _.map(lname, toLowerCase);
            lname = _.filter(lname, function(w) { return w.match(/^\w+$/) && ! _.contains(stopWords, w); });
            
            var w1 = word_desc.concat(word_name);
            var w2 = w1.concat(fname);
            var w3 = w2.concat(lname);
            var w4 = w3.concat(inst);
            var words = w4;
            words = _.uniq(words);
            poster.set("words", words);
            
            response.success();
        }
    });
});

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
      
            var word_desc = talk.get("content").split(/\b/);
            word_desc = _.map(word_desc, toLowerCase);
            word_desc = _.filter(word_desc, function(w) { return w.match(/^\w+$/) && ! _.contains(stopWords, w); });
      
            var word_name = talk.get("name").split(/\b/);
            word_name = _.map(word_name, toLowerCase);
            word_name = _.filter(word_name, function(w) { return w.match(/^\w+$/) && ! _.contains(stopWords, w); });
     
            var fname = fn.split(/\b/);
            fname = _.map(fname, toLowerCase);
            fname = _.filter(fname, function(w) { return w.match(/^\w+$/) && ! _.contains(stopWords, w); });
     
            var lname = ln.split(/\b/);
            lname = _.map(lname, toLowerCase);
            lname = _.filter(lname, function(w) { return w.match(/^\w+$/) && ! _.contains(stopWords, w); });
     
            var inst = ins.split(/\b/);
            lname = _.map(lname, toLowerCase);
            lname = _.filter(lname, function(w) { return w.match(/^\w+$/) && ! _.contains(stopWords, w); });
     
            var w1 = word_desc.concat(word_name);
            var w2 = w1.concat(fname);
            var w3 = w2.concat(lname);
            var w4 = w3.concat(inst);
            var words = w4;
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
    var fname = person.get("first_name").split(/\b/);
    fname = _.map(fname, toLowerCase);
    fname = _.filter(fname, function(w) { return w.match(/^\w+$/) && ! _.contains(stopWords, w); });
      
    var lname = person.get("last_name").split(/\b/);
    lname = _.map(lname, toLowerCase);
    lname = _.filter(lname, function(w) { return w.match(/^\w+$/) && ! _.contains(stopWords, w); });
      
    var inst = person.get("institution").split(/\b/);
    inst = _.map(inst, toLowerCase);
    inst = _.filter(inst, function(w) { return w.match(/^\w+$/) && ! _.contains(stopWords, w); });
      
    var arr_mid = fname.concat(lname);
    var arr_fin = arr_mid.concat(inst);
    arr_fin = _.uniq(arr_fin);
    person.set("words", arr_fin);
  
    response.success();
});

//if "on_site" = 1 for a newly added person, check existing user and link them if found
Parse.Cloud.afterSave("Person", function(request, response) {
    var person = request.object;
    if (person.get("on_site") == 1)
    {
        var person_email = person.get("email");
        var user_query = new Parse.Query(Parse.User);
        user_query.equalTo("email", person_email);
        user_query.find({
            success: function(results) {
                //query done, link the user and person here
                for (var i = 0; i < results.length; i++) {
             
                    //for each user found, set his person pointer
                    var user_obj = results[i];
                    user_obj.set("person", person);
                    user_obj.set("is_person", 1);
                    user_obj.set("last_name", person.get("last_name"));
                    user_obj.set("first_name", person.get("first_name"));
                    user_obj.set("chat_status", 1);
                  
                    //set the person's "user" pointer to be the user found
                    person.set("user", user_obj);
                    person.set("is_user", 1);
                    person.set("chat_status", 1);
                 
                    user_obj.save();
                    person.save();
                }
            },
            error: function(error) {
                //something went wrong with the query
            }
        });
    }
});

//after a new user signs up, check persons for the same email and link, or create new person
Parse.Cloud.afterSave(Parse.User, function(request) {
    //grab email of the newly signed up user
    var user_email = request.object.get("email");
    var user_name = request.object.get("username");
      
    //see if he is a registered "person" of the conference
    var Person = Parse.Object.extend("Person");
    var emailquery = new Parse.Query(Person);
    emailquery.equalTo("email", user_email);
    emailquery.find({
        success: function(results) {
            //query done, link the user and person here
            for (var i = 0; i < results.length; i++) {
                  
                //for each person found, set his user pointer
                var person_obj = results[i];
                person_obj.set("user", request.object);
                person_obj.set("is_user", 1);
                person_obj.save();
                  
                //set the user's properties
                request.object.set("person", person_obj);
                request.object.set("is_person", 1);
                request.object.set("last_name", person_obj.get("last_name"));
                request.object.set("first_name", person_obj.get("first_name")); 
                request.object.save();
            }
            
            //query done but nothing found, create new person
            if (results.length == 0) {
            	//set stuff for the new person object
            	var person_obj = new Person();
            	person_obj.set("user", request.object);
            	person_obj.set("is_user", 1);
            	person_obj.set("email", user_email);
            	person_obj.save();
            	
            	//set user properties
            	request.object.set("person", person_obj);
                request.object.set("is_person", 1);
                request.object.save();
            }
        },
        error: function(error) {
            //something went wrong with the query
        }
    });
});