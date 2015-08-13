# grapple
Customizable data table for Rails

## Installation

``` ruby
## Gemfile for Rails 3+
gem 'grapple'
```

``` css
# app/assets/stylesheets/application.css
*= require grapple
```
	
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

## Paging (will_paginate)
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
TODO

# Customizing
TODO