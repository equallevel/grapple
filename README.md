# grapple
Customizable data grid for Rails

## Features
* Modular design
* Server side rendering
* Usable out of the box
* Sorting
* Searching/Filtering
* Pagination
* AJAX

## Installation

``` ruby
# Gemfile for Rails 3+
gem 'grapple'
```

``` css
/* app/assets/stylesheets/application.css */
*= require grapple
```

## Dependencies
* Rails 3+

Optional Dependencies:

* will_paginate - for pagination support
* jQuery - for AJAX support
* history.js - for back button support when using the AJAX data table

## Table Builders
HtmlTableBuilder - A basic HTML table builder

DataGridBuilder (default) - An HTML table builder with support for paging, filtering, sorting, and actions.

AjaxDataGridBuilder - DataGridBuilder that uses AJAX to retrieve results when sorting/filtering the table.

In an initializer set the default builder:
``` ruby
Grapple::Helpers::TableHelper.builder = Grapple::AjaxDataGridBuilder
```

## Basic Usage (DataGridBuilder)
app/controllers/posts_controller.rb
``` ruby
class PostsController < ApplicationController
	def index
		@posts = Post.all
	end
end
```

app/views/posts/index.html.erb
``` HTML+ERB
<%
	columns = [
		{ label: 'Name' },
		{ label: 'Title' },
		{ label: 'Content' },	
		{ label: '' },
		{ label: '' },
		{ label: '' }
	]

	actions = [
		{ label: 'New Post', url: new_posts_path }
	]
%>
<%= table_for(columns, @posts) do |t| %>
	<%= t.header do %>
		<%= t.toolbar do %>
			<%= t.actions actions %>
		<% end %>
		<%= t.column_headings %>
	<% end %>
	<%= t.body do |item| %>
		<td><%= post.name %></td>
		<td><%= post.title %></td>
		<td><%= post.content %></td>
		<td><%= link_to 'Show', post %></td>
		<td><%= link_to 'Edit', edit_post_path(post) %></td>
		<td><%= link_to 'Destroy', post, confirm: 'Are you sure?', method: :delete %></td>
	<% end %>
<% end %>
```

## Sorting
TODO

## Pagination (requires will_paginate)
app/controllers/posts_controller.rb
``` ruby
def index
	@posts = Post.paginate(page: params[:page] || 1, per_page: 10)
end
```

app/views/posts/index.html.erb
``` HTML+ERB
<%= table_for(columns, @posts) do |t| %>
	<%= t.header %>
	<%= t.footer do %>
		<%= t.pagination %>
	<% end %>
<% end %>
```

## Filtering/Searching
TODO

## Actions
The Actions component can be used to generate buttons/links for actions related to the table.  This can be used to provide links to export the data in the table or create new objects.
``` HTML+ERB
<%= table_for(columns, @posts) do |t| %>
	<%= t.header do %>
		<%= t.toolbar do %>
			<%= t.actions [
					{ label: :new_post, url: new_posts_path },
					{ label: :export_posts, url: export_posts_path }
				] %>
		<% end %>
		<%= t.column_headings %>
	<% end %>
<% end %>
```

## AJAX
The AjaxDataGridBuilder generates tables that can update their content using AJAX rather than re-loading the page.  jQuery is required.
``` javascript
// app/assets/javascripts/application.js
//= require grapple
//= require grapple-jquery
```

``` ruby
# app/controllers/posts_controller.rb
class PostsController < ApplicationController
	def index
		@posts = table_results
	end
	
	# Method called by AJAX requests - renders the table without a layout
	def table
		@posts = table_results
		render partial: 'table'
	end
	
protected

	def table_results
		Post.paginate(page: params[:page] || 1, per_page: 10)
	end
end
```

Create a container around the table that can be updated by the JavaScript
``` HTML+ERB
<%# app/views/posts/index.html.erb %>
<%= grapple_container(id: 'posts_table') do %>
	<%= render :partial => 'table' %>
<% end %>
```

Render the table using `table_for` in `app/views/posts/_table.html.erb`

## History w/AJAX (back button)

Requires: https://github.com/browserstate/history.js/

``` javascript
// app/assets/javascripts/application.js
//= require jquery-history
//= require grapple
//= require grapple-history
//= require grapple-jquery
```

## Customizing
TODO