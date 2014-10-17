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
      # self.errors = args['errors'] if args.has_key? 'errors'
    end

    def as_json(_)
      resource_attributes
    end

    def to_json(options = nil)
      {
        :"#{prefix}" => resource_attributes
      }.to_json(options)
    end

    def update_attributes(attrs)
      attrs.each do |a, v|
        unless String(a) == 'id' && resource_attributes.include?('id')
          a = 'id' if String(a) == 'new_id'
          resource_attributes[String(a)] = v
        end
      end
    end

    def update!(attrs, headers = {})
      new_attributes = resource_attributes.merge attrs
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
        return resource_attributes['id'] if String(method) == 'id'
        return resource_attributes[String(args.first)] if method.to_s == '[]'
        resource_attributes.fetch(String(method)) { super }
    end

    def respond_to? method
        resource_attributes.has_key?(String(method)) ? true : super
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
      self.instance_variable_get :"@#{self.class.resource_id_name}"
    end

    def attributes
      resource_attributes
    end

    def resource_attributes
      unless self.instance_variables.include?(:@resource_attributes)
        self.instance_variable_set(:@resource_attributes, {})
      end
      self.instance_variable_get :@resource_attributes
    end

    protected

    def prefix
      self.class.instance_variable_get(:@resource_name)
    end
  end
end
