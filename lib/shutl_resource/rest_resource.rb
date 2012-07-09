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
      base.instance_variable_set :@remote_resource_name, base.name.underscore
    end


    module ClassMethods

      def find(id)
        puts @remote_resource_name
        url = "/#{@remote_resource_name.pluralize}/#{id}"
        response = get(url)

        new JSON.parse(response.body)[@remote_resource_name]
      end
    end
  end
end
