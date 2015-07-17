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
       
    //see if theres already a person with the same email
    var Person = Parse.Object.extend("Person");
    var emailquery = new Parse.Query(Person);
    emailquery.equalTo("email", user_email);
    emailquery.find({
        success: function(results) {
            
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
                person_obj.save();
            }
             
            //query done but nothing found, create new person
            if (results.length == 0) {
            
                //set stuff for the new person object
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
                person_obj.save();
            }
        },
        error: function(error) {
            //something went wrong with the query
        }
    });
});