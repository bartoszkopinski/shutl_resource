require 'active_model/serialization'

module Shutl
  module DynamicResource
    include ActiveModel::Serialization

    def self.included(base)
      base.send :extend, ClassMethods
      base.send :resource_name, base.name.underscore
    end

    module ClassMethods
      def resource_name(name)
        instance_variable_set :@resource_name, name
      end
    end

    def initialize(args = {})
      args.each { |key, value| instance_variable_set "@#{key}", value }
    end

    def to_json(options = nil)
      {
        :"#{prefix}" => to_hash
      }.to_json(options)
    end

    def update_attributes!(attrs)
      attrs.each { |property, value| self.instance_variable_set(:"@#{property}", value) }
    end


    def method_missing(method, *args, &block)
      if self.instance_variables.include?(:"@#{method}")
        return self.instance_variable_get(:"@#{method}")
      end
      super
    end

    protected

    def prefix
      self.class.instance_variable_get(:@resource_name)
    end

    def to_hash
      instance_variables.inject({}) { |h, variable| h[variable.to_s.gsub('@','').to_sym] = instance_variable_get(variable) ; h }
    end

  end
end
