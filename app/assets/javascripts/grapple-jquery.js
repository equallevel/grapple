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
GrappleTable.CSS_FILTERS_BELOW = 'grapple-toolbar--filters-below';
GrappleTable.CSS_FILTERS_STACKED = 'grapple-toolbar--filters-stacked';
GrappleTable.DESKTOP_QUERY = '(min-width: 761px)';
GrappleTable.CSS_RANGE_WRAPPED = 'grapple-range--wrapped';
GrappleTable.CSS_PAGINATION_COMPACT = 'grapple-pagination--compact';
// The one-row From/To width (grapple.css), below which they move to their own row
GrappleTable.RANGE_INPUT_MIN_WIDTH = 98;
GrappleTable.CSS_TRUNCATE = 'grapple-truncate';
GrappleTable.CSS_TRUNCATE_MOBILE = 'grapple-truncate-mobile';
GrappleTable.CSS_CLAMP = 'grapple-clamp';
GrappleTable.CSS_CLAMP_MOBILE = 'grapple-clamp--mobile';
// Truncating hides overflow, which would clip controls, menus and nested tables
GrappleTable.TRUNCATE_SKIP = 'input, select, textarea, button, table, .dropdown';
GrappleTable.DATA_CLAMP_TITLE = 'grapple-clamp-title';

/**
 * Shows a clipped value in full on hover. Checked on each hover, not on load, because resizing
 * changes which values are clipped. A tooltip already inside the value, such as a supplier list,
 * is left to show instead.
 */
GrappleTable.titleTruncated = function(clamp) {
	var $clamp = $(clamp);
	var owned = $clamp.data(GrappleTable.DATA_CLAMP_TITLE);
	var clipped = clamp.scrollHeight > clamp.clientHeight && !$clamp.find('[title]').length;
	if(clipped) {
		$clamp.attr('title', $.trim($clamp.text())).data(GrappleTable.DATA_CLAMP_TITLE, true);
	}
	else if(owned) {
		$clamp.removeAttr('title').removeData(GrappleTable.DATA_CLAMP_TITLE);
	}
};

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
		self.initTruncation();
		self.initToolbarLayout();
		self.initPaginationLayout();
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
				self.loadTable($(elem).serialize());
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
	/**
	 * Values in columns marked grapple-truncate (a fixed or maximum width) are wrapped so CSS can
	 * cut them off after three lines. Line clamping needs an element inside the cell; it can't apply
	 * to the <td> itself. Columns marked grapple-truncate-mobile (only a mobile width) get a
	 * modifier so the clamp applies only at the mobile breakpoint.
	 */
	initTruncation: function() {
		var columns = [];
		var headings = this.table.children('thead').find('tr.column-headers > th');
		headings.each(function(i, th) {
			if($(th).hasClass(GrappleTable.CSS_TRUNCATE)) {
				columns.push({ index: i, clamp: GrappleTable.CSS_CLAMP });
			}
			else if($(th).hasClass(GrappleTable.CSS_TRUNCATE_MOBILE)) {
				columns.push({ index: i, clamp: GrappleTable.CSS_CLAMP + ' ' + GrappleTable.CSS_CLAMP_MOBILE });
			}
		});
		if(!columns.length) {
			return;
		}
		this.body.children('tr').each(function(i, row) {
			var cells = $(row).children('td');
			// Rows with merged cells, such as the no-results row, don't line up with the headings
			if(cells.length !== headings.length) {
				return;
			}
			$.each(columns, function(j, column) {
				var cell = cells.eq(column.index);
				// The identifier link is truncated on its own so the paperclip stays outside the clipped text
				var identifier = cell.find('.grapple-identifier__link');
				if(identifier.length) {
					identifier.addClass(column.clamp);
					return;
				}
				if(cell.find('.' + GrappleTable.CSS_CLAMP + ', ' + GrappleTable.TRUNCATE_SKIP).length) {
					return;
				}
				cell.wrapInner('<div class="' + column.clamp + '"></div>');
			});
		});
		this.body.on('mouseenter', '.' + GrappleTable.CSS_CLAMP, function() {
			GrappleTable.titleTruncated(this);
		});
	},

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
	 * At the desktop breakpoint the filters share the search row while they all fit beside the
	 * Actions. Otherwise, and always below it, they go on their own row when they fit on one, and
	 * stack one per row when they don't. Without ResizeObserver the toolbar just wraps.
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

	/**
	 * At the desktop breakpoint the full page list shows. When the table is too narrow for it to
	 * fit on one row, the compact list (first, current and last pages) replaces it.
	 */
	initPaginationLayout: function() {
		var self = this;
		var pagination = this.element.children('.grapple-pagination');
		if(this._paginationObserver) {
			this._paginationObserver.disconnect();
		}
		var hasCompact = pagination.find('.grapple-pagination__pages--compact').length > 0;
		if(!hasCompact || typeof ResizeObserver === 'undefined') {
			return;
		}
		var width = null;
		this._paginationObserver = new ResizeObserver(function() {
			var current = pagination.width();
			if(current === width) {
				return;
			}
			width = current;
			self.layoutPagination(pagination);
		});
		this._paginationObserver.observe(pagination[0]);
		if(document.fonts && document.fonts.ready) {
			document.fonts.ready.then(function() { self.layoutPagination(pagination); });
		}
	},

	layoutPagination: function(pagination) {
		// Measure the full list where it shows
		pagination.removeClass(GrappleTable.CSS_PAGINATION_COMPACT);
		if(!window.matchMedia(GrappleTable.DESKTOP_QUERY).matches) {
			return;
		}
		var pages = pagination.find('.grapple-pagination__pages--full .pagination').children();
		if(pages.length && pages.last()[0].offsetTop > pages.first()[0].offsetTop) {
			pagination.addClass(GrappleTable.CSS_PAGINATION_COMPACT);
		}
	},

	layoutToolbar: function(toolbar) {
		var cell = toolbar.children('th')[0];
		if(!cell) {
			return;
		}
		// Measure the natural widths in the plain wrapping layout
		toolbar.removeClass(GrappleTable.CSS_FILTERS_BELOW + ' ' + GrappleTable.CSS_FILTERS_STACKED);
		toolbar.find('.' + GrappleTable.CSS_RANGE_WRAPPED).removeClass(GrappleTable.CSS_RANGE_WRAPPED);
		var self = this;
		var gap = parseFloat(window.getComputedStyle(cell).columnGap) || 0;
		var available = $(cell).width();
		var search = GrappleTable.SEARCH_FIELD + ', ' + GrappleTable.SEARCH_SUBMIT;
		// At the desktop breakpoint the form is a flex box of its own; its items are what wrap
		var items = [];
		$.each(this._flexItems(cell), function(i, item) {
			items = items.concat($(item).is('form.search-form') ? self._flexItems(item) : [item]);
		});
		var filters = [];
		$.each(items, function(i, item) {
			var $item = $(item);
			if($item.is('#more-filters-row, .actions, ' + search) || $item.find(search).length) {
				return;
			}
			filters.push(item);
		});
		if(!filters.length) {
			return;
		}
		if(window.matchMedia(GrappleTable.DESKTOP_QUERY).matches && !this._anyWrapped(items, filters)) {
			return;
		}
		var total = 0;
		$.each(filters, function(i, item) {
			var style = window.getComputedStyle(item);
			total += item.getBoundingClientRect().width + parseFloat(style.marginLeft) +
				parseFloat(style.marginRight);
		});
		total += (filters.length - 1) * gap;
		if(total <= available) {
			toolbar.addClass(GrappleTable.CSS_FILTERS_BELOW);
			return;
		}
		toolbar.addClass(GrappleTable.CSS_FILTERS_STACKED);
		this._wrapRanges(toolbar, available);
	},

	// A date range whose label, dropdown, From/To and X don't fit one stacked row wraps From/To
	_wrapRanges: function(toolbar, available) {
		toolbar.find('.input-group:has(> select)').each(function(i, group) {
			var $group = $(group);
			var inputs = $group.children('.range-input:visible');
			if(!inputs.length) {
				return;
			}
			var needed = inputs.length * GrappleTable.RANGE_INPUT_MIN_WIDTH;
			var row = $group.closest('.more-filter-wrapper').children('.input-group');
			$group.children('.input-group-text:visible, select:visible').add(row.children('button:visible')).each(function(j, el) {
				if($(el).css('position') !== 'absolute') {
					needed += el.getBoundingClientRect().width;
				}
			});
			if(needed > available) {
				$group.addClass(GrappleTable.CSS_RANGE_WRAPPED);
			}
		});
	},

	// Whether any filter sits below the toolbar's first row
	_anyWrapped: function(items, filters) {
		var top = Math.min.apply(null, $.map(items, function(item) {
			return item.getBoundingClientRect().top;
		}));
		return $.grep(filters, function(item) {
			return item.getBoundingClientRect().top - top > 1;
		}).length > 0;
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
