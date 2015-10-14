module Grapple
	class BaseTableBuilder

		# Create a helper
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

		attr_reader :columns, :records, :template, :params

		def initialize(template, columns, records, params = {}, *options)
			@template = template
			@columns = columns
			@records = records
			@params = params
			@options = options[0] || {}
			@helper_instances = {}
		end

		def before_table
			''
		end

		def after_table
			''
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
