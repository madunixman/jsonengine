function httpGet(theUrl, mappingDefinition)
{
    var localMapping = mappingDefinition;
    var block;
    if (window.XMLHttpRequest)
    {// code for IE7+, Firefox, Chrome, Opera, Safari
        xmlhttp=new XMLHttpRequest();
    }
    else
    {// code for IE6, IE5
        xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
    }
    xmlhttp.onreadystatechange=function()
    {
        if (xmlhttp.readyState==4 && xmlhttp.status==200)
        {
	    block = JSON.parse(xmlhttp.responseText);
            response= xmlhttp.responseText;
	    localMapping(response);
        }
    }
    xmlhttp.open("GET", theUrl, true);
    xmlhttp.send();    
}


getQueryParams=function(qs) {
    	qs = qs.split("+").join(" ");
    	var params = {}, tokens,
        re = /[?&]?([^=]+)=([^&]*)/g;

    	while (tokens = re.exec(qs)) {
        	params[decodeURIComponent(tokens[1])]
            	= decodeURIComponent(tokens[2]);
    	}
    	return params;
}
