module Grapple
	class BaseTableBuilder

		# Create a helper
		# @param name [Symbol]
		#   The name of the helper
		# @param klass [Grapple::Components::BaseComponent]
		#   The component class
		# @param settings [Hash]
		#   Settings for the component
		def self.helper(name, klass, settings = {})
			class_eval <<-RUBY_EVAL
				def #{name}(*arguments, &block)
					invoke_helper(:"#{name}", *arguments, &block)
				end
			RUBY_EVAL
			define_singleton_method(:"class_for_#{name}") { klass }
			define_singleton_method(:"settings_for_#{name}") { settings }
		end

		# Update settings for a helper
		# @param helper_name [Symbol]
		#   The name of the helper
		# @param options [Hash]
		#   Settings to update for the component
		def self.configure(helper_name, *options)
			settings = options[0] || {}
			method = :"settings_for_#{helper_name}"
			if self.respond_to?(method)
				self.send(method).each do |key, value|
					settings[key] = value unless settings.has_key?(key)
				end
			end
			define_singleton_method(method) { settings }
		end

		# An Array of columns
		# @return [Array<Hash>]
		attr_reader :columns
		
		# An Array, ActiveRecord::Collection or Enumerable of records to be displayed in the table
		# @return [Enumerable]
		attr_reader :records

		# @return [ActionView::Base]
		attr_reader :template
		
		# Request parameters
		attr_reader :params
		
		# @return [String] namespace for the grapple table
		attr_reader :namespace

		def initialize(template, columns, records, params = {}, *options)
			@template = template
			@columns = columns
			@records = records
			@options = default_options.merge(options[0] || {})
			@namespace = @options[:namespace]
			@params = params
			@params = @params[@namespace] || {} if @namespace
			@helper_instances = {}
		end
		
		# Default options for the component
		# @return [Hash]
		def default_options
			{ }
		end

		# HTML to insert before the <table> tag
		def before_table
			''
		end

		# HTML to insert after the </table> tag
		def after_table
			''
		end
		
		def container(inner_html)
			inner_html
		end

	protected

		def invoke_helper(name, *arguments, &block)
			unless @helper_instances.has_key?(name)
				klass = self.class.send(:"class_for_#{name}")
				settings = self.class.send(:"settings_for_#{name}")
				@helper_instances[name] = klass.new(@columns, @records, @template, @params, self, settings)
			end
			@helper_instances[name].send(:render, *arguments, &block)
		end

	end
end
