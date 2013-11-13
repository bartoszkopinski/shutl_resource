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
      attrs.each do |a, v|
        unless String(a) == 'id' && attributes.include?('id')
          a = 'id' if String(a) == 'new_id'
          attributes.update String(a) => v
        end
      end
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
        return attributes[String(args.first)] if method.to_s == '[]'
        attributes.fetch(String(method)) { super }
    end

    def respond_to? method
      attributes.has_key?(String(method)) ? true : super
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
      @attributes ||= {}
    end

    protected

    def prefix
      self.class.instance_variable_get(:@resource_name)
    end
  end
end
