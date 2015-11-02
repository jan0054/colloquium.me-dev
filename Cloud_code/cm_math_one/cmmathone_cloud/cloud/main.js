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
       
            var words = word_desc.concat(word_name);
            words = words.concat(fname);
            words = words.concat(lname);
            words = words.concat(inst);
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
    words = _.uniq(words);
    person.set("words", words);
    
    response.success();
});
 
//after a new user signs up (or user preferences are updated), check persons for the same email and link
Parse.Cloud.afterSave(Parse.User, function(request) {
    //grab info of the user
    var user_email = request.object.get("email");
    var user_fn = request.object.get("first_name");
    var user_ln = request.object.get("last_name");
    var user_inst = request.object.get("institution");
    var user_link = request.object.get("link");
    var user_mailswitch = request.object.get("email_status");
    var user_chatswitch = request.object.get("chat_status");
    var user_eventswitch = request.object.get("event_status");
    var user_events = request.object.get("events");
        
    var toLowerCase = function(w) { return w.toLowerCase(); };
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
    words = _.map(words, toLowerCase);
    words = _.filter(words, function(w) { return w.match(/^\w+$/) && ! _.contains(stopWords, w); });
    words = _.uniq(words);
    request.object.set("words", words);
    request.object.save();
     
    //see if theres already a person with the same email
    var Person = Parse.Object.extend("Person");
    var emailquery = new Parse.Query(Person);
    emailquery.equalTo("email", user_email);
    emailquery.find({
        success: function(results) {
            Parse.Cloud.useMasterKey();
            console.log("Person query done:");
            console.log(results.length);
            //query done, link the user and person here
            for (var i = 0; i < results.length; i++) {
                    
                //for each person found, set his user pointer and update info
                var person_obj = results[i];
                person_obj.set("user", request.object);
                person_obj.set("is_user", 1);
                person_obj.set("first_name", user_fn);
                person_obj.set("last_name", user_ln);
                person_obj.set("institution", user_inst);
                person_obj.set("link", user_link);
                person_obj.set("email_status", user_mailswitch);
                person_obj.set("chat_status", user_chatswitch);
                person_obj.set("event_status", user_eventswitch);
                person_obj.set("events", user_events);
                person_obj.save();
                 
                request.object.set("person", person_obj);
                request.object.set("is_person", 1);
                request.object.save();
                 
                console.log("Existing Person updated");
            }
              
            //query done but nothing found, create new person
            if (results.length == 0) {
                var person_obj = new Person();
                person_obj.set("user", request.object);
                person_obj.set("is_user", 1);
                person_obj.set("email", user_email);
                person_obj.set("first_name", user_fn);
                person_obj.set("last_name", user_ln);
                person_obj.set("institution", user_inst);
                person_obj.set("link", user_link);
                person_obj.set("email_status", user_mailswitch);
                person_obj.set("chat_status", user_chatswitch);
                person_obj.set("event_status", user_eventswitch);
                person_obj.set("events", user_events);
                request.object.set("person", person_obj);
                request.object.set("is_person", 1);
                request.object.save();
                console.log("New Person created");
            }
        },
        error: function(error) {
            console.error("Got an error " + error.code + " : " + error.message);
            //something went wrong with the query
             
        }
    });
});