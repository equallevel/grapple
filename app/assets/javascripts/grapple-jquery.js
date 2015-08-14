(function(Grapple, $) {
	'use strict';

var urlQuery = Grapple.Util.urlQuery, 
	parseUrlQuery = Grapple.Util.parseUrlQuery;
	
var overrideLink = function(clickable, anchor, callback) {
	var href = $(anchor).attr('href');
	$(anchor).attr('href', 'javascript:void(0)');
	$(clickable).on('click', function() {
		callback(href ? href.split('?')[1] : '');
	});
};

/**
 * Creates a new instance of the Grapple AJAX widget.
 *
 * @param {String} Selector for the table container element.
 * @param {Object} Hash of options for the table (url, namespace, history)
 */
var GrappleTable = function(element, options) {
	options = options || {};
	this.element = $(element);
	this.url = options.url || this.element.data('grapple-ajax-url');
	this.namespace = options.namespace || this.element.data('grapple-ajax-namespace') || null;
	this.currentParams = options.params || '';
	if(typeof options.history !== 'undefined' && options.history !== true) {
		this.history = options.history;
	}
	else if(this.element.data('grapple-ajax-history') == 1 || options.history === true) {
		this.history = new Grapple.History();
	}
	else {
		this.history = null;
	}
	this.init();
};

GrappleTable.CSS_AJAX_LOADING = 'grapple-ajax-loading';
GrappleTable.CSS_LOADING = 'grapple-loading';
GrappleTable.CSS_LOADING_OVERLAY = 'loading-overlay';
GrappleTable.NON_TABLE_RESPONSE = '<!DOCTYPE html>';

GrappleTable.prototype = {
	
	/**
	 *
	 */
	init: function() {
		var self = this;
		self.table = self.element.children('table');
		self.header = self.table.children('thead');
		self.body = self.table.children('tbody');
		self.footer = self.table.children('tfoot');
		
		self.initSorting();
		self.initSearchForm();
		self.initPagination();
		self.initHistory();
		
		self.element.removeClass(GrappleTable.CSS_AJAX_LOADING);
	},

	initHistory: function() {
		if(this.history) {
			var self = this;
			this.history.unsubscribe();
			this.history = new Grapple.History();
			this.history.subscribe(function(params) {
				self.onHistoryChange(params);
			});
		}
	},
	
	onHistoryChange: function(params) {
		console.log("HISTORY CHANGE");
		this._showLoading();
		this._updateTable($.param(params));
	},
	
	/**
	 *
	 */
	loadTable: function(params) {
		console.log("LOAD TABLE ", params);
		this._showLoading();

		if(this.history) {
			console.log("ADD History");
			this.history.unsubscribe();
			this.history.add(this.namespace, params);
		}
		
		console.log("Update table");
		this._updateTable(params);
	},
	
	_showLoading: function() {
		// Add loading class to the container
		this.element.addClass(GrappleTable.CSS_LOADING);
		
		// Set the position of the loading overlay based on the size of the table
		var loadingBar = this.element.find('.' + GrappleTable.CSS_LOADING_OVERLAY)
		loadingBar.width(this.table.width());
		var barHeight = loadingBar.height() || 20;
		var top = (this.table.height() / 2) - barHeight;
		loadingBar.css('top', top + 'px');
	},
	
	_hideLoading: function() {
		// Remove the loading class from the container
		this.element.removeClass(GrappleTable.CSS_LOADING);
	},
	
	_updateTable: function(params) {
		var self = this;
		var url = this.url;
		if(params.length) {
			url += '?' + params;
		}

		$.ajax(url, {
			success: function(data) {
				// HACK
				var nonTableKeyIndex = data.indexOf(GrappleTable.NON_TABLE_RESPONSE);
				if(nonTableKeyIndex > -1 && nonTableKeyIndex < 100) {
					data = "Failed to load table";
				}
				self.element.addClass(GrappleTable.CSS_AJAX_LOADING);
				self.element.html(data);
				self.init();
				self._hideLoading();
			},
			error: function(a, b, c) {
				// TODO: handle loading errors
				console.log("Failed to load table");
				console.log(a);
				console.log(b);
				console.log(c);
			}
		});
	},
	
	initSorting: function() {
		var self = this;
		this.header.find('th.sortable').each(function(i, elem) {
			overrideLink(elem, $(elem).find('a'), function(params) {
				// Return to the first page on sorting
				params = params.replace(/&?page=[0-9]+/, '');
				params += '&page=1';				
				self.loadTable(params);
			});
		});
	},
	
	initSearchForm: function() {
		var self = this;
		this.header.find('form.search-form').each(function(i, elem) {
			$(elem).on('submit', function(event) {
				// Don't submit the form
				event.preventDefault();
				self.loadTable($(elem).serialize());
			});
		});
	},
	
	initPagination: function() {
		var self = this;
		this.footer.find('.pagination a').each(function(i, elem) {
			overrideLink(elem, elem, function(params) { 
				self.loadTable(params);
			});
		});
	}

};

Grapple.Table = GrappleTable;

function Plugin(option) {
	return this.each(function() {
		var $this   = $(this);
		var data    = $this.data('grapple');
		var options = typeof option == 'object' && option;

		if (!data && /destroy|hide/.test(option)) return;
		if (!data) $this.data('grapple', (data = new GrappleTable(this, options)));
		if (typeof option == 'string') data[option]();
	});
}

var old = $.fn.grapple;

$.fn.grapple             = Plugin;
$.fn.grapple.Constructor = GrappleTable;

$.fn.grapple.noConflict = function() {
	$.fn.grapple = old;
	return this;
}

})(Grapple, jQuery);
