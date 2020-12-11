(function(window, Grapple, $) {
	'use strict';

var urlQuery = Grapple.Util.urlQuery, 
	parseUrlQuery = Grapple.Util.parseUrlQuery;

// History.js for backwards compatibility with older browsers
// https://github.com/browserstate/history.js/
var LegacyHistory = function() {
	var api = History;
		
	// Initialization of history.js can be delayed
	// if it was do it now
	if(api.options && api.options.delayInit) {
		api.options.delayInit = false;
		api.init();
	}
	this.api = api;
};

LegacyHistory.prototype = {
	push: function(params) {
		return this.api.pushState(null, document.title, '?' + params);
	},
	get: function() {
		return urlQuery(this.api.getState().url);
	},
	bind: function(callback) {
		$(window).bind('statechange', callback);
	},
	unbind: function(callback) {
		$(window).unbind('statechange', callback);
	}
};

// Native Browser History API
var ModernHistory = function() {

};

ModernHistory.prototype = {
	push: function(params) {
		if(window.history && window.history.pushState) {
			return window.history.pushState(params, document.title, '?' + params);
		}
	},
	get: function() {
		if(window.history) {
			return window.history.state || urlQuery(document.location.toString());
		}
	},
	bind: function(callback) {
		$(window).bind('popstate', callback);
	},
	unbind: function(callback) {
		$(window).unbind('popstate', callback);
	}
};

var GrappleHistory = function(grappleTable) {
	this.grappleTable = grappleTable;
	this._historyChangeCallback = null;
};

// Don't clutter the url with rails form parameters
GrappleHistory.IGNORE_PARAMS = { 'utf8': true, 'authenticity_token': true };

GrappleHistory.prototype = {

	init: function() {
		// Use the History.js wrapper if History.js has been loaded
		this.api = typeof History !== 'undefined' && History.init ? new LegacyHistory() : new ModernHistory();
		this._subscribeToTableChange();
		this._subscribeToHistoryChange();
	},

	/**
	 * Add an entry to the history
	 * @param {String} params 
	 */
	_addHistoryEntry: function(params) {
		var namespace = this.grappleTable.namespace;
		var historyParams = parseUrlQuery(this.api.get());
		var newParams = parseUrlQuery(params);

		// Remove any parameters from the current state 
		// that are for this table
		for(var x in historyParams) {
			var remove = namespace ? 
				// Remove any parameters in the tables namespace
				x.indexOf(namespace + '[') === 0 : 
				// Table is in the global namespace, remove any parameters that aren't namespaced
				x.indexOf('[') === -1;					

			if(remove) {
				delete historyParams[x];
			}
		}
		
		// Add the new parameters
		for(var x in newParams) {
			if(GrappleHistory.IGNORE_PARAMS[x]) continue;
			//var key = namespace ? namespace + '[' + x  + ']' : x;
			historyParams[x] = newParams[x];
		}
		
		this.api.push($.param(historyParams));
	},
	
	/**
	 * Listen for changes to the table to add them to the history
	 */
	_subscribeToTableChange: function() {
		var self = this;
		this._beforeLoadCallback = function(e, params) {
			self._unsubscribeFromTableChange();
			self._unsubscribeFromHistoryChange();
			// Don't add params to history if this was triggered by history change
			if(self._ignoreNextLoad) {
				self._ignoreNextLoad = false;
			}
			else {
				self._addHistoryEntry(params);
			}
		};
		this.grappleTable.element.on('grapple:before_load', this._beforeLoadCallback);
	},

	/**
	 * Stop listening for changes to the table
	 */
	_unsubscribeFromTableChange: function() {
		if(this._beforeLoadCallback) {
			this.grappleTable.element.unbind('grapple:before_load', this._beforeLoadCallback);
			this._beforeLoadCallback = null;
		}
	},

	/**
	 * Listen for changes to the history (back button clicks)
	 */
	_subscribeToHistoryChange: function() {
		var api = this.api, namespace = this.grappleTable.namespace, self = this;
		this._historyChangeCallback = function(event) {
			var params = parseUrlQuery(api.get());
			// Only include the parameters for this namespace
			if(namespace) {
				var r = new RegExp('^' + namespace + '\\[([^\\]]+)\\]$')
				for(var x in params) {
					if(r.exec(x) === null) {
						delete params[x];
					}
				}
			}
			self._ignoreNextLoad = true;
			self.grappleTable.loadTable($.param(params));
		};
		this.api.bind(this._historyChangeCallback);
	},
	
	/**
	 * Stop listening for history changes
	 */
	_unsubscribeFromHistoryChange: function() {
		if(this._historyChangeCallback) {
			this.api.unbind(this._historyChangeCallback);
			this._historyChangeCallback = null;
		}
	}
	
};

Grapple.History = GrappleHistory;

})(window, Grapple, $);
