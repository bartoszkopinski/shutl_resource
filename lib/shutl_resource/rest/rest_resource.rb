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

        def find(args)
          unless args.kind_of?(Hash)
            id = args
            args = { resource_id_name => id }
          end
          url = generate_url(remote_resource_url, args)
          response = get(url)

          raise Shutl::RemoteError.new("Failed to find #{name} with the id #{id}") unless response.success?

          attrs = JSON.parse(response.body, symbolize_names: true)[@resource_name.to_sym] 
          create_object args.merge(attrs)
        end

        def all(args = {})
          url = generate_url(remote_collection_url, args)
          response = get(url)

          raise Shutl::RemoteError.new("Failed to find all #{name}") unless response.success?

          JSON.parse(response.body, symbolize_names: true)[@resource_name.pluralize.to_sym].map { |h| create_object(args.merge(h)) }
        end

        def create!(attrs)
          create_object(attrs).create
        end

        def resource_id(variable_name)
          instance_variable_set :@resource_id, variable_name
        end

        def resource_id_name
          instance_variable_get(:@resource_id).to_sym
        end

        def remote_collection_url
          @remote_collection_url ||= "/#{@resource_name.pluralize}"
        end

        def remote_resource_url
          @remote_resource_url ||= "#{remote_collection_url}/:#{resource_id_name}"
        end

        def collection_url(url)
          @remote_collection_url = url
        end

        def resource_url(url)
          @remote_resource_url = url
        end

        private

        def create_object(args = {})
          unless args.has_key? :id
            args.merge!( { id: args[resource_id_name] })
          end
          new args
        end

        protected

        def generate_url(url_pattern, args)
          url = url_pattern.dup
          args.each { |key,value| url.gsub!(":#{key}", value.to_s) }
          url
        end
      end

      def create
        url = self.class.send :generate_url, self.class.remote_collection_url, attributes
        response = self.class.post(url, body: to_json )

        response.success?
      end

      def delete
        url = self.class.send :generate_url, self.class.remote_resource_url, attributes
        response = self.class.delete(url)

        response.success?
      end

      def update!(attrs)
        update_attributes!(attrs)
        save!
      end

      def save
        url = self.class.send :generate_url, self.class.remote_resource_url, attributes
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

      private

      def attributes
        instance_variables.inject({}) { |h, var| h.merge( { var.to_s.gsub('@','').to_sym => instance_variable_get(var)}) }
      end

    end
  end
end
