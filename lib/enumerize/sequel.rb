module Enumerize
  module SequelSupport
    def enumerize(name, options={})
      super

      _enumerize_module.dependent_eval do
        if defined?(::Sequel::Model) && self < ::Sequel::Model
          if options[:scope]
            _define_scope_methods!(name, options)
          end

          include InstanceMethods
        end
      end
    end

    private

    def _define_scope_methods!(name, options)
      scope_name = options[:scope] == true ? "with_#{name}" : options[:scope]

      dataset_module do
        define_singleton_method scope_name do |*values|
          values = values.map { |value| enumerized_attributes[name].find_value(value).value }
          values = values.first if values.size == 1

          where(name => values)
        end

        if options[:scope] == true
          define_singleton_method "without_#{name}" do |*values|
            values = values.map { |value| enumerized_attributes[name].find_value(value).value }
            exclude(name => values)
          end
        end
      end
    end
  end
end
