module Shutl::Resource
  class BackendResourcesController < ApplicationController
    respond_to :json
    before_filter :request_access_token
    before_filter :load_resource, only: [:show]

    rescue_from Shutl::Resource::Error do |e|
      case e.response.content_type
      when "text/html"
        response_hash = { debug_info: e.response.body.to_json}

      when "application/json"
        begin
          response_hash = e.response.parsed_response
        rescue
          debug_info = <<-eof
          Failed to parse JSON response from quote service:

          #{e.message}

          #{e.class}

          #{e.backtrace}

          #{e.response.body}
          eof

          response_hash = { debug_info: debug_info}
        end
      end

      render status: e.response.code, json: response_hash
    end

    def index
      authenticated_request do
        instance_variable_set(
          pluralized_instance_variable_name,
          resource_klass.all(id_params.merge auth: access_token))
      end

      response_collection = pluralized_instance_variable.map do |o|
        attributes_to_front_end o.attributes
      end

      render json: response_collection
    end

    def new
      self.instance_variable= resource_klass.new
      respond_with_json
    end

    def create
      authenticated_request do
        self.instance_variable= resource_klass.create id_params.merge(attributes_from_params), auth: access_token
      end

      render status: instance_variable.status, json: instance_variable.parsed
    end

    def show
      respond_with_json
    end

    def update
      authenticated_request do
        resource_klass.update id_params.merge(attributes_from_params), auth: access_token
      end

      render nothing: true, status: 204
    end

    def destroy
      authenticated_request do
        resource_klass.destroy(id_params.merge(id: params[:id]), auth: access_token)
      end

      render nothing: true, status: 204
    end

    private

    def id_params
      params.dup.keep_if do |k, v|
        k == 'id' or k =~ /_id\Z/
      end
    end

    # Respond_with does not work in this case
    def respond_with_json(status=200)
      render status: status, json: attributes_to_front_end(instance_variable.attributes)
    end

    def load_resource
      authenticated_request do
        self.instance_variable = resource_klass.find(id_params, auth: access_token)
      end

      render nothing: true, status: 404 if instance_variable.nil?
    end

    def resource_klass
      resource_klass_name.constantize
    end

    def instance_variable
      instance_variable_get instance_variable_name
    end

    def instance_variable= value
      instance_variable_set instance_variable_name, value
    end

    def pluralized_instance_variable
      instance_variable_get pluralized_instance_variable_name
    end

    def pluralized_instance_variable= value
      instance_variable_set pluralized_instance_variable_name, value
    end

    def pluralized_instance_variable_name
      :"@#{pluralized_resource_name}"
    end

    def pluralized_resource_name
      singular_resource_name.pluralize
    end

    def instance_variable_name
      :"@#{singular_resource_name}"
    end

    def singular_resource_name
      resource_klass_name.underscore
    end

    def resource_klass_name
      self.class.to_s.gsub(/Controller/,"").singularize
    end

    def attributes_from_params
      @attributes ||= converter_class.to_back_end set_attributes_from_params
    end

    def set_attributes_from_params
      params[singular_resource_name].dup.tap do |p|
        p[:id] = params[:id] if params[:id]
      end
    end

    def converter_class
      Shutl::Resource::Converter.class_for resource_klass
    end

    def attributes_to_front_end attrs
      converter_class.to_front_end attrs
    end
  end
end
