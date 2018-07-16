window.onload = function(e){ 

function computeField(item,index){
	console.log("Item n." + item);
	console.log("Item dx." + index);
	console.log("Item name:" + item.name);
	console.log("Item type:" + item.type);
	job_block += "<tr><td> " + item.name+"</td><td>"+ item.type+"</td><td>";
        params = item.params;
	job_block += "<ul style=\"list-style-type:none\">";
        for (k in params)
        {
	    job_block += "<li>" + k +":[<b>"+ params[k] +"</b>]<li/>";
        }
	job_block += "</ul>";
	job_block += "</td></tr>";
}
        
        var myform;
	var job_block ="";
	var endPoint=  "./";
	//Implement for peculiar page modifications
	//--------------------------------------------------------------------
	var mappingDefinition = function () { 
		var block = JSON.parse(response);
		console.log(block);
		myform   = document.getElementById('jobs:job0');
                job_block += "<h2> Job name:[<b>"+ block.name + "</b>]</h2><br/>"
	    if (null != block){
		job_block += "<table name=\"" + block.name + "\" class=\"table table-striped table-hover\">";
		job_block += "<thead class=\"thead-dark\">";
		job_block += "<tr><th>Name</th><th>Type</th><th>Params</th></tr>";
		job_block += "</thead>";
		job_block += "<tbody class=\"\">";
		var myfields = block.tasks;
		myfields.forEach(computeField);
		job_block += "</tbody>";
		job_block +="</table>";
		myform.innerHTML = job_block;
	    }
	}
	//--------------------------------------------------------------------

        var baseEndpoint="./";
	var query = getQueryParams(document.location.search);
	var pparam=query.p;
	var page=endPoint + 'remote.json';
	var method=query.method;
	var id=query.id;
	var actualUrl= baseEndpoint + id + ".json"; //Might need to add decoupling logic
	console.log("PAGE:" + actualUrl)
	var xsite=httpGet(actualUrl, mappingDefinition);
	//--------------------------------------------------------------------
}//onload
