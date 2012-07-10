require 'httparty'
require 'active_support/core_ext/string'
require 'active_support/inflector'
require 'json'

module Shutl
  module Rest
    module RestResource
      extend HTTParty

      def self.included(base)
        base.send :include, HTTParty
        base.send :include, Shutl::DynamicResource
        base.send :extend,  ClassMethods
        base.send :headers, { 'Content-Type' => 'application/json' } 

        base.send(:resource_id, :id)
      end

      module ClassMethods

        def find(id)
          url = "/#{@resource_name.pluralize}/#{id}"
          response = get(url)

          raise Shutl::RemoteError.new("Failed to find #{name} with the id #{id}") unless response.success?

          create_object JSON.parse(response.body, symbolize_names: true)[@resource_name.to_sym]
        end

        def all
          url = "/#{@resource_name.pluralize}"
          response = get(url)

          raise Shutl::RemoteError.new("Failed to find all #{name}") unless response.success?

          JSON.parse(response.body, symbolize_names: true)[@resource_name.pluralize.to_sym].map { |h| create_object(h) }
        end

        def resource_id(variable_name)
          instance_variable_set :@resource_id, variable_name
        end

        def resource_id_name
          instance_variable_get(:@resource_id).to_sym
        end

        private

        def create_object(args = {})
          unless args.has_key? :id
            args.merge!( { id: args[resource_id_name] })
          end
          new args
        end
      end

      def create
        url = "/#{self.class.instance_variable_get(:@resource_name).pluralize}"
        response = self.class.post(url, body: to_json )

        response.success?
      end

      def delete
        url = "/#{self.class.instance_variable_get(:@resource_name).pluralize}/#{resource_id}"
        response = self.class.delete(url)

        response.success?
      end

      def update
        save
      end

      def update!
        save!
      end

      def save
        url = "/#{self.class.instance_variable_get(:@resource_name).pluralize}/#{resource_id}"
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

      def resource_id
        instance_variable_get :"@#{self.class.resource_id_name}"
      end

    end
  end
end
