(function(globals) {
	'use strict';

var decodeParam = function(str) { 
	return decodeURIComponent(str.replace(/\+/g, " "));
};

var parseUrlQuery = function(query) {
	var regex = /([^&=]+)=?([^&]*)/g;
	var params = {}, e;
	while(e = regex.exec(query)) { 
		var k = decodeParam(e[1]), v = decodeParam(e[2]);
		if(k.substring(k.length - 2) === '[]') {
			k = k.substring(0, k.length - 2);
			(params[k] || (params[k] = [])).push(v);
		}
		else {
			params[k] = v;
		}
	}
	return params;
};

// Get the query string from a url, returns an empty string if there is no query
var urlQuery = function(url) {
	return url.split('?')[1] || '';
};

globals.Grapple = {
	Util: {
		urlQuery: urlQuery,
		parseUrlQuery: parseUrlQuery
	}
};

})(window);
