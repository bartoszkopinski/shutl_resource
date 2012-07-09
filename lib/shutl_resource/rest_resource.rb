require 'httparty'
require 'active_support/core_ext/string'
require 'active_support/inflector'
require 'shutl_resource/dynamic_resource'
require 'json'
require 'shutl_resource/exceptions'


module Shutl
  module RestResource
    extend HTTParty

    def self.included(base)
      base.send :include, HTTParty
      base.send :include, Shutl::DynamicResource
      base.send :extend, ClassMethods
      base.send :headers, { 'Content-Type' => 'application/json' } 

      base.instance_variable_set :@remote_resource_name, base.name.underscore
    end


    module ClassMethods

      def find(id)
        url = "/#{@remote_resource_name.pluralize}/#{id}"
        response = get(url)

        raise Shutl::RemoteError.new("Failed to find #{name} with the id #{id}") unless response.success?

        new JSON.parse(response.body)[@remote_resource_name]
      end

      def all
        url = "/#{@remote_resource_name.pluralize}"
        response = get(url)

        raise Shutl::RemoteError.new("Failed to find all #{name}") unless response.success?

        JSON.parse(response.body)[@remote_resource_name.pluralize].map { |h| new(h) }
      end

      def resource_id(variable_name)
        instance_variable_set :@resource_id, variable_name
      end
    end

    def create
      url = "/#{self.class.instance_variable_get(:@remote_resource_name).pluralize}"
      response = self.class.post(url, body: to_json )

      response.success?
    end

    def delete
      url = "/#{self.class.instance_variable_get(:@remote_resource_name).pluralize}/#{resource_id}"
      response = self.class.delete(url)

      response.success?
    end

    def save
      url = "/#{self.class.instance_variable_get(:@remote_resource_name).pluralize}/#{resource_id}"
      response = self.class.put(url, body: to_json)

      response.success?
    end

    def create!
      created = create

      raise Shutl::RemoteError.new("Failed to create a #{self.class.name}") unless created
    end

    def save!
      updated = save

      raise Shutl::RemoteError.new("Failed to update the #{self.class.name}") unless updated
    end

    private

    def resource_id
      resource_name = self.class.instance_variable_get(:@resource_id)
      instance_variable_get "@#{resource_name}"
    end
  end
end
