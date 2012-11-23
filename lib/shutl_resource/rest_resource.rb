require 'httparty'
require 'active_support/core_ext/string'
require 'active_support/core_ext/hash'
require 'active_support/inflector'
require 'json'
require 'uri'
require 'active_model'

module ShutlResource
  module RestResource
    extend HTTParty
    include ActiveModel::Serialization

    attr_reader :response

    def self.included(base)
      base.send :include, HTTParty
      base.send :extend,  ShutlResource::RestResourceClassMethods

      base.send :headers, {
        'Accept'        => 'application/json',
        'Content-Type'  => 'application/json'
      }

      base.send :resource_name, base.name.underscore
      base.send :resource_id,   :id
    end

    def initialize(args = {}, response=nil)
      update_attributes args
      @response = response
    end

    def to_json(options = nil)
      {
        :"#{prefix}" => attributes
      }.to_json(options)
    end

    def update_attributes(attrs)
      attrs.each { |a, v| instance_variable_set(:"@#{a}", v) }
    end

    def update!(attrs)
      new_attributes = attributes.merge attrs
      update_attributes(self.class.add_resource_id_to new_attributes)
      save
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

    def parsed
      response.parsed_response
    end

    def status
      response.code
    end

    def resource_id
      instance_variable_get :"@#{self.class.resource_id_name}"
    end

    def attributes
      (instance_variables - [:@response]).inject({}.with_indifferent_access) do |h, var|
        h.merge( { var.to_s.gsub('@','').to_sym => instance_variable_get(var)})
      end
    end

    private

    def check_fail *args
      self.class.send :check_fail, *args
    end

    protected

    def prefix
      self.class.instance_variable_get(:@resource_name)
    end
  end
end
