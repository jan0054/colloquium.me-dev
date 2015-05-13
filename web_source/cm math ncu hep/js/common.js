// JavaScript Document for common functions

function getAllAuthor(inputStr)
{
	Parse.initialize("ZxpkBR4Fy9XQBQGhE4wfTnJTi5Fi4ZaQrw8wJzWZ", "YLOUyupAg2vLKSNT7HK1eCRfQstbNY1k5QuBCq7B");
	ListItem = Parse.Object.extend("Person");
	query = new Parse.Query(ListItem);
	query.limit(500);
	query.ascending('last_name');
	query.find({
		success: function(results){
			for (var i=0; i<results.length; i++){
				var object=results[i];
				var sel=document.getElementById(inputStr);
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

function getAllLocation(inputStr)
{
	Parse.initialize("ZxpkBR4Fy9XQBQGhE4wfTnJTi5Fi4ZaQrw8wJzWZ", "YLOUyupAg2vLKSNT7HK1eCRfQstbNY1k5QuBCq7B");
	ListItem = Parse.Object.extend("Location");
	query = new Parse.Query(ListItem);
	query.limit(500);
	query.ascending('name');
	query.find({
		success: function(results){
			for (var i=0; i<results.length; i++){
				var object=results[i];
				var sel=document.getElementById(inputStr);
				if(i==0){
					var new_option = new Option(object.get('name')+"("+object.get('capacity')+")",object.id,1,1);
				}
				else
				{
					var new_option = new Option(object.get('name')+"("+object.get('capacity')+")",object.id);
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

function getAllSession(inputStr)
{
	Parse.initialize("ZxpkBR4Fy9XQBQGhE4wfTnJTi5Fi4ZaQrw8wJzWZ", "YLOUyupAg2vLKSNT7HK1eCRfQstbNY1k5QuBCq7B");
	ListItem = Parse.Object.extend("Session");
	query = new Parse.Query(ListItem);
	query.limit(500);
	query.ascending('start_time');
	query.find({
		success: function(results){
			for (var i=0; i<results.length; i++){
				var object=results[i];
				var sel=document.getElementById(inputStr);
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

