require 'active_support/core_ext/string'
require 'active_support/core_ext/hash'
require 'active_support/inflector'
require 'json'
require 'uri'
require 'active_model'

module Shutl::Resource
  module Rest
    include ActiveModel::Serialization

    attr_accessor :pagination, :errors

    def self.included(base)
      base.send :extend,  Shutl::Resource::RestClassMethods

      base.send :resource_name, base.name.split('::').last.underscore
      base.send :resource_id,   :id
    end

    def initialize(args = {})
      update_attributes args
    end

    def as_json(_)
      attributes
    end

    def to_json(options = nil)
      {
        :"#{prefix}" => attributes
      }.to_json(options)
    end

    def update_attributes(attrs)
      attrs.each { |a, v| instance_variable_set(:"@#{a}", v) }
    end

    def update!(attrs, headers = {})
      new_attributes = attributes.merge attrs
      update_attributes(self.class.add_resource_id_to new_attributes)
      save(headers)
    end

    def save options={}
      self.class.save self, options
    end

    def destroy options
      self.class.destroy self, options
    end

    def method_missing(method, *args, &block)
      if self.instance_variables.include?(:"@#{method}")
        return self.instance_variable_get(:"@#{method}")
      end
      super
    end

    def respond_to? method
      self.instance_variables.include?(:"@#{method}") ? true : super
    end


    def next_resource
      pagination["next_resource"] if pagination
    end

    def previous_resource
      pagination["previous_resource"] if pagination
    end

    def valid?
      errors.blank?
    end

    def resource_id
      instance_variable_get :"@#{self.class.resource_id_name}"
    end

    def attributes
      (instance_variables- [:@errors, :@pagination]).inject({}.with_indifferent_access) do |h, var|
        h.merge( { var.to_s.gsub('@','').to_sym => instance_variable_get(var)})
      end
    end

    protected

    def prefix
      self.class.instance_variable_get(:@resource_name)
    end
  end
end
