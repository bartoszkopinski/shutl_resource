require 'httparty'
require 'active_support/core_ext/string'
require 'active_support/inflector'
require 'shutl_resource/dynamic_resource'
require 'json'

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
        puts @remote_resource_name
        url = "/#{@remote_resource_name.pluralize}/#{id}"
        response = get(url)

        new JSON.parse(response.body)[@remote_resource_name]
      end

      def all
        url = "/#{@remote_resource_name.pluralize}"
        response = get(url)

        JSON.parse(response.body)[@remote_resource_name.pluralize].map { |h| new(h) }
      end

      def resource_id(variable_name)
        puts "set resource_id #{variable_name}"
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

    private

    def resource_id
      resource_name = self.class.instance_variable_get(:@resource_id)
      instance_variable_get "@#{resource_name}"
    end
  end
end
