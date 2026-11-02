(function(Grapple, $) {
	'use strict';
	
var overrideLink = function(clickable, anchor, callback) {
	var href = $(anchor).attr('href');
	// use `#` + preventDefault() rather than `javascript:void(0)` so
	// the anchor passes strict script-src without navigating on click.
	$(anchor).attr('href', '#');
	$(clickable).on('click', function(e) {
		e.preventDefault();
		callback(href ? href.split('?')[1] : '');
	});
};

/**
 * Creates a new instance of the Grapple AJAX widget.
 *
 * @param {String} element - Selector for the table container element.
 * @param {Object} options - Hash of options for the table (url, namespace, history)
 */
var GrappleTable = function(element, options) {
	options = options || {};
	this.element = $(element);
	this.url = options.url || this.element.data('grapple-ajax-url');
	this.namespace = options.namespace || this.element.data('grapple-ajax-namespace') || null;
	this.currentParams = options.params || '';
	this.plugins = {};
	if(typeof options.history !== 'undefined' && options.history !== true) {
		this.plugins.history = options.history;
	}
	else if(this.element.data('grapple-ajax-history') == 1 || options.history === true) {
		this.plugins.history = new Grapple.History(this);
	}

	this.init();

	if (this.element.data('grapple-ajax-init-params')) {
		this.loadTable(this.element.data('grapple-ajax-init-params'))
	}
};

GrappleTable.CSS_AJAX_LOADING = 'grapple-ajax-loading';
GrappleTable.CSS_LOADING = 'grapple-loading';
GrappleTable.CSS_LOADING_OVERLAY = 'loading-overlay';
GrappleTable.NON_TABLE_RESPONSE = '<!DOCTYPE html>';
GrappleTable.SEARCH_FIELD = 'input.search-query';
GrappleTable.SEARCH_SUBMIT = 'input[type=submit]:not(.reset-button), button[type=submit]:not(.reset-button)';
GrappleTable.CSS_SEARCH_ERROR = 'grapple-search-error';
GrappleTable.CSS_SEARCH_FIELD_ERROR = 'grapple-search-field--error';
GrappleTable.CSS_FILTERS_BELOW = 'grapple-toolbar--filters-below';
GrappleTable.CSS_FILTERS_STACKED = 'grapple-toolbar--filters-stacked';
GrappleTable.DESKTOP_QUERY = '(min-width: 761px)';

GrappleTable.prototype = {
	
	/**
	 * Initialize the grapple table
	 */
	init: function() {
		var self = this;
		// The toolbar and count sit above the data table and the pagination below it
		var scroll = self.element.children('.grapple-scroll');
		self.table = scroll.length ? scroll.children('table') : self.element.children('table');
		self.controls = self.element.children('.grapple-controls');
		self.header = self.controls.children('table').children('thead').add(self.table.children('thead'));
		self.body = self.table.children('tbody');
		self.footer = self.table.children('tfoot')
			.add(self.element.children('.grapple-pagination').children('table').children('tfoot'));
		
		self.initSorting();
		self.initSearchForm();
		self.initPagination();
		self.initMenus();
		self.initToolbarLayout();
		self.initPlugins();
		
		self.element.removeClass(GrappleTable.CSS_AJAX_LOADING);
	},

	/**
	 * Initialize plugins
	 */
	initPlugins: function() {
		for(var name in this.plugins) {
			this.plugins[name].init();
		}
	},
	
	/**
	 * Load the table contents
	 * @param {String} params - Query string of parameters to load the table with
	 * @fires Grapple#grapple:before_load
	 * @fires Grapple#grapple:after_load
	 */
	loadTable: function(params) {
		this.element.trigger('grapple:before_load', params);
		this._showLoading();
		this._updateTable(params);
	},
	
	_showLoading: function() {
		// Add loading class to the container
		this.element.addClass(GrappleTable.CSS_LOADING);
		
		// Center the loading overlay on the data table, below the toolbar
		var loadingBar = this.element.find('.' + GrappleTable.CSS_LOADING_OVERLAY);
		var box = this.table.parent('.grapple-scroll');
		if(!box.length) {
			box = this.table;
		}
		loadingBar.width(box.outerWidth());
		var barHeight = loadingBar.height() || 20;
		// offsetTop, not .position(), which subtracts the box's top margin
		var top = box[0].offsetTop + (box.outerHeight() / 2) - barHeight;
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
			url += (url.indexOf('?') == -1 ? '?' : '&') + params;
		}
		$.ajax(url, {
			beforeSend: function() {
				var event = jQuery.Event('grapple:before_ajax_send');
				self.element.trigger(event, { url: url });
				return !event.isDefaultPrevented();
			},
			success: function(data) {
				// HACK: handle full page responses
				var nonTableKeyIndex = data.indexOf(GrappleTable.NON_TABLE_RESPONSE);
				if(nonTableKeyIndex > -1 && nonTableKeyIndex < 100) {
					data = "Failed to load table";
				}
				self.loadHtml(data, url);
			},
			error: function(a, b, c) {
				// TODO: handle loading errors
				console.log("Failed to load table", a, b, c);
			}
		});
	},
	
	loadHtml: function(html, url) {
		this.element.addClass(GrappleTable.CSS_AJAX_LOADING);
		this.element.html(html);
		this.init();
		this._hideLoading();
		this.element.trigger('grapple:after_load', { url: url, html: html });
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
		var self = this, selector = 'form.search-form';
		this.header.find(selector).each(function(i, elem) {
			$(elem).on('submit', function(event) {
				// Don't submit the form
				event.preventDefault();
				if(self._isEmptySearch(elem, event)) {
					self._showSearchError(elem);
					return;
				}
				self.loadTable($(elem).serialize());
			});
			$(elem).find(GrappleTable.SEARCH_FIELD).on('input', function() {
				self._hideSearchError(elem);
			});
		});
		
		// Automatically submit the form when dropdowns are changed
		this.header.find(selector + ' select').change(function() {
			$(this).closest(selector).submit()
		});
	},
	
	initPagination: function() {
		var self = this;
		this.footer.find('.pagination a').each(function(i, elem) {
			overrideLink(elem, elem, function(params) { 
				self.loadTable(params);
			});
		});
	},

	/**
	 * Row menus use fixed positioning so the scrolling data table doesn't clip them.
	 * Requires Bootstrap 5 JS; without it the data-bs-toggle attributes do nothing.
	 */
	initMenus: function() {
		if(typeof bootstrap === 'undefined' || !bootstrap.Dropdown) {
			return;
		}
		this.table.find('.grapple-row-menu__toggle').each(function(i, toggle) {
			if(!bootstrap.Dropdown.getInstance(toggle)) {
				new bootstrap.Dropdown(toggle, { popperConfig: { strategy: 'fixed' } });
			}
		});
	},

	/**
	 * The filters share the search row while they fit, drop to their own row when they don't,
	 * and stack one per row when they don't fit on one row either. Without ResizeObserver the
	 * toolbar just wraps.
	 */
	initToolbarLayout: function() {
		var self = this;
		var toolbar = this.controls.find('tr.toolbar');
		if(this._toolbarObserver) {
			this._toolbarObserver.disconnect();
		}
		if(!toolbar.length || typeof ResizeObserver === 'undefined') {
			return;
		}
		var width = null;
		this._toolbarObserver = new ResizeObserver(function() {
			var current = self.controls.width();
			if(current === width) {
				return;
			}
			width = current;
			self.layoutToolbar(toolbar);
		});
		this._toolbarObserver.observe(this.controls[0]);
		// Filter labels change width as options are picked
		toolbar.on('change', function() {
			window.requestAnimationFrame(function() { self.layoutToolbar(toolbar); });
		});
		if(document.fonts && document.fonts.ready) {
			document.fonts.ready.then(function() { self.layoutToolbar(toolbar); });
		}
	},

	layoutToolbar: function(toolbar) {
		var cell = toolbar.children('th')[0];
		if(!cell) {
			return;
		}
		// Measure the natural widths in the plain wrapping layout
		toolbar.removeClass(GrappleTable.CSS_FILTERS_BELOW + ' ' + GrappleTable.CSS_FILTERS_STACKED);
		var gap = parseFloat(window.getComputedStyle(cell).columnGap) || 0;
		var available = $(cell).width();
		var search = [], actions = [], filters = [];
		$.each(this._flexItems(cell), function(i, item) {
			var $item = $(item);
			if($item.is('#more-filters-row')) {
				return;
			}
			if($item.is('.actions')) {
				actions.push(item);
			}
			else if($item.is(GrappleTable.SEARCH_FIELD + ', ' + GrappleTable.SEARCH_SUBMIT) ||
				$item.find(GrappleTable.SEARCH_FIELD + ', ' + GrappleTable.SEARCH_SUBMIT).length) {
				search.push(item);
			}
			else {
				filters.push(item);
			}
		});
		if(!filters.length) {
			return;
		}
		// The search field can shrink to fit the row, so it counts at its max-width (its preferred size)
		var total = function(items) {
			var sum = 0;
			$.each(items, function(i, item) {
				var style = window.getComputedStyle(item);
				var width = item.getBoundingClientRect().width;
				var maxWidth = parseFloat(style.maxWidth);
				if(search.indexOf(item) > -1 && maxWidth > width) {
					width = maxWidth;
				}
				sum += width + parseFloat(style.marginRight);
				// Actions' auto margin computes to the row's free space, which made every fit a tie
				if(actions.indexOf(item) === -1) {
					sum += parseFloat(style.marginLeft);
				}
			});
			return sum + Math.max(items.length - 1, 0) * gap;
		};
		// Below the desktop breakpoint the search field always fills its own row
		var desktop = window.matchMedia(GrappleTable.DESKTOP_QUERY).matches;
		if(desktop && total(search.concat(filters, actions)) <= available) {
			return;
		}
		toolbar.addClass(total(filters) <= available ? GrappleTable.CSS_FILTERS_BELOW : GrappleTable.CSS_FILTERS_STACKED);
	},

	// The boxes a flex container lays out: display: contents children are replaced by their own
	_flexItems: function(container) {
		var self = this, items = [];
		$(container).children().each(function(i, child) {
			var display = window.getComputedStyle(child).display;
			if(display === 'contents') {
				items = items.concat(self._flexItems(child));
			}
			else if(display !== 'none') {
				items.push(child);
			}
		});
		return items;
	},

	/**
	 * An empty search only counts when it comes from the search field or its button. Filter
	 * changes submit the same form with no submitter, and Enter in another text filter submits
	 * with the search button as the submitter, so both still load.
	 */
	_isEmptySearch: function(form, event) {
		var field = $(form).find(GrappleTable.SEARCH_FIELD).first();
		if(!field.length || $.trim(field.val()) !== '' || !this.element.data('grapple-search-required-message')) {
			return false;
		}
		var submitter = (event.originalEvent || {}).submitter;
		if(!submitter || $(submitter).is('.reset-button')) {
			return false;
		}
		var active = document.activeElement;
		var otherField = active && active !== submitter && active !== field[0] && $(active).is(':input');
		return !(otherField && $.contains(form, active));
	},

	_showSearchError: function(form) {
		var field = $(form).find(GrappleTable.SEARCH_FIELD).first();
		var id = (field.attr('id') || 'query') + '-error';
		if(!$(form).find('.' + GrappleTable.CSS_SEARCH_ERROR).length) {
			$('<div role="alert"></div>')
				.addClass(GrappleTable.CSS_SEARCH_ERROR)
				.attr('id', id)
				.text(this.element.data('grapple-search-required-message'))
				.insertAfter(field);
		}
		field.addClass(GrappleTable.CSS_SEARCH_FIELD_ERROR).attr({ 'aria-invalid': 'true', 'aria-describedby': id });
		field.trigger('focus');
	},

	_hideSearchError: function(form) {
		$(form).find('.' + GrappleTable.CSS_SEARCH_ERROR).remove();
		$(form).find(GrappleTable.SEARCH_FIELD)
			.removeClass(GrappleTable.CSS_SEARCH_FIELD_ERROR)
			.removeAttr('aria-invalid aria-describedby');
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
