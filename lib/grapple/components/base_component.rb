module Grapple
	module Components

		# Base class for components
		class BaseComponent
			
			cattr_accessor :default_settings
			@@default_settings = {}
			
			def self.setting(name, default = nil)
				attr_accessor(name)
				@@default_settings[self.name] = {} unless @@default_settings.has_key?(self.name)
				@@default_settings[self.name][name] = default
			end
			
			attr_reader :columns
			attr_reader :records
			attr_reader :template
			attr_reader :params
			attr_reader :builder

			def initialize(columns, records, template, params, builder, settings = {})
				@template = template
				@columns = columns
				@records = records
				@params = params
				@builder = builder
				merge_settings(settings).each do |name, value|
					self.send(:"#{name}=", value)
				end
			end

			def render(*options, &block)
				raise StandardError.new("Component must override render method")
			end
			
		protected
		
			# TODO: this is all pretty hacky
			def merge_settings(settings)
				result = {}
				klass = self.class
				while klass && klass.name != 'BaseComponent'
					if @@default_settings[klass.name]
						@@default_settings[klass.name].each do |name, value|
							result[name] = value
						end
					end
					klass = klass.superclass
				end

				settings.each do |name, value|
					result[name] = value
				end
				result
			end
		
			# Shortcut for translations
			# Won't try to translate strings, just symbols
			def t(*args)
				# Don't translate strings
				return args[0] if args.length == 1 && args[0].kind_of?(String)
				begin
					return template.t(*args) if template.method_defined?(:t)
				ensure
					return I18n.translate(*args)
				end
			end
		
			# Number of columns in the table
			def num_columns
				@columns.length
			end

			def capture_block(default = '', &block)
				return default if block.nil?
				template.with_output_buffer(&block).html_safe
			end

			# Renders a block if present, otherwise renders the components with options
			def block_or_components(components, options, &block)
				block.nil? ? render_components(components, options, &block).join : capture_block(&block)
			end
			
			# Render an array of components 
			def render_components(components, options, &block)
				html = []
				components.each do |component|
					if component == :body
						html << capture_block(&block)
					elsif options[component] === false
						next
					else
						args = options[component] || []
						html << self.builder.send(component, *args)
					end
				end
				html
			end
			
			# Returns a url parameter in the namespaced format
			def url_parameter(param)
				@builder.namespace ? @builder.namespace + '[' + param.to_s + ']' : param.to_s
			end
			
		end
	end
end