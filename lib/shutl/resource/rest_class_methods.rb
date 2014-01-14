require 'open-uri'
module Shutl::Resource
  module RestClassMethods

    def base_uri uri
      @base_uri = uri
    end

    def connection
      @connection ||= Faraday.new(:url => @base_uri || Shutl::Resource.base_uri) do |faraday|
        faraday.request :url_encoded # form-encode POST params


        if Shutl::Resource.logger
          faraday.use :default_logger, logger: Shutl::Resource.logger
        end

        faraday.response :json
        faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
      end
    end

    def find(args = {}, params = {})
      if @singular_resource
        params = args
        url    = singular_member_url params
      elsif !args.kind_of?(Hash)
        id   = args
        args = { resource_id_name => id }
        url  = member_url args.dup, params
      else
        url = member_url args.dup, params
      end
      response     = connection.get(url) do |req|
        req.headers = generate_request_header(header_options(params))
      end

      check_fail response, "Failed to find #{name}! args: #{args}, params: #{params}"

      including_parent_attributes = response.body[@resource_name].merge args
      new_object including_parent_attributes, response.body
    end

    def create attributes = {}, options = {}
      url = generate_collection_url attributes
      attributes.delete "response"

      response = connection.post(url) do |req|
        req.headers = generate_request_header(header_options(options))
        req.body = { @resource_name => attributes }.to_json
      end

      check_fail response, "Create failed"

      body     = response.body || {}
      attributes = body[@resource_name] || {}

      new_object attributes, body
    end

    def destroy instance, options = {}
      failure_message = "Failed to destroy #{name.downcase.pluralize}"

      perform_action(
        instance,
        :delete,
        {}.to_json,
        generate_request_header(header_options(options)),
        failure_message
      ).success?
    end

    def save instance, options = {}
      attributes = instance.attributes rescue instance

      body = { @resource_name => convert_new_id(attributes) }.to_json

      response = perform_action(instance,
                                :put,
                                body,
                                generate_request_header(header_options(options)),
                                "Save failed")

      response.success?
    end

    def update args, options = {}
      save args, options
    end


    def all(args = {})
      partition    = args.partition { |key, value| !remote_collection_url.index(":#{key}").nil? }

      url_args = partition.first.inject({}) { |h, pair| h[pair.first] = pair.last; h }
      params   = partition.last.inject({}) { |h, pair| h[pair.first] = pair.last; h }

      url      = generate_collection_url url_args, params
      response = connection.get(url) do |req|
        req.headers = generate_request_header(header_options(args))
      end

      check_fail response, "Failed to find all #{name.downcase.pluralize}"

      response_object = response.body[@resource_name.pluralize].map do |h|
        new_object(args.merge(h), response.body)
      end
      if order_collection?
        response_object.sort! do |a,b|
          str_a = a.send(@order_collection_by).to_s
          str_b = b.send(@order_collection_by).to_s
          str_a.casecmp(str_b)
        end
      end

      RestCollection.new(response_object, response.body['pagination'])
    end

    class RestCollection
      include Enumerable

      attr_reader :collection

      def initialize(collection, pagination)
        @collection = collection
        @pagination = pagination
      end

      delegate :each, to: :collection

      class Pagination < Struct.new(:page,
                                    :items_on_page,
                                    :total_count,
                                    :number_of_pages)
      end

      def pagination
        return unless @pagination.present?
        Pagination.new(@pagination['page'],
                       @pagination['items_on_page'],
                       @pagination['total_count'],
                       @pagination['number_of_pages'])
      end
    end

    def singular_resource
      @singular_resource = true
    end

    def resource_name(name)
      instance_variable_set :@resource_name, name
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

    def order_collection_by(field)
      @order_collection_by = field
    end

    def convert_new_id attributes
      if attributes[:new_id]
        attributes = attributes.clone.tap { |h| h[:id] = h[:new_id]; h.delete(:new_id) }
      end

      attributes
    end

    def add_resource_id_to args={}
      args = args.dup.with_indifferent_access
      unless args.has_key? "id"
        args.merge!({ "id" => args[resource_id_name] })
      end
      args
    end

    def singular_member_url params
      generate_url! "/#{@resource_name}", {}, params
    end

    def member_url *args
      attributes = args.first.with_indifferent_access

      unless attributes[resource_id_name] ||= attributes[:id]
        raise ArgumentError, "Missing resource id with name: `#{resource_id_name}' for #{self}"
      end

      args[0] = attributes

      generate_url! remote_resource_url, *(args.dup)
    end

    def generate_collection_url *args
      generate_url! remote_collection_url, *args
    end


    def self.from_user= email
      Thread.current[:user_email] = email
    end

    private

    def headers
      {
        'Accept'        => 'application/json',
        'Content-Type'  => 'application/json',
        'User-Agent'    => "Shutl Resource Gem v#{Shutl::Resource::VERSION}"
      }
    end

    def header_options params
      header_opts = params[:headers] || {}
      header_opts.merge!(authorization: "Bearer #{params[:auth]}") if params[:auth]
      header_opts.merge!(from: current_user_email(params))         if current_user_email(params)
      header_opts
    end

    def current_user_email params
      params[:from] || Thread.current[:user_email]
    end


    def generate_request_header header_options = {}
      header_options.inject(headers) do |h, (k,v)|
        h[header_name(k.to_s)] = v if v
        h
      end
    end

    def header_name header_key
      header_key.split(%r{\_|\-}).map {|e| e.capitalize }.join("-")
    end

    def perform_action instance, verb, body, headers, failure_message
      attributes = instance.is_a?(Hash) ? instance : instance.attributes
      attributes.delete "response" #used in debugging requests/responses

      url      = member_url attributes

      response = connection.send(verb, url) do |req|
        req.headers = headers
        req.body = body
      end

      check_fail response, failure_message

      response
    end

    def new_object(args={}, body)
      instance = new add_resource_id_to(args)

      instance.tap do |i|
        i.errors     = body["errors"]
        i.pagination = body["pagination"]
      end
    end

    def check_fail response, message
      if klass = failure_klass(response.status)
        body = if response.headers["content-type"] =~ %r{application/json}
                 response.body
               else
                 {debug_info: response.body}
               end


        raise klass.new body, response.status
      end
    end

    def failure_klass(status)
      case status
      when 299
        if Shutl::Resource.raise_exceptions_on_no_quotes_generated
          Shutl::NoQuotesGenerated
        else
          nil
        end

      when 400 then Shutl::BadRequest
      when 401 then Shutl::UnauthorizedAccess
      when 403 then Shutl::ForbiddenAccess
      when 404 then Shutl::ResourceNotFound
      when 409 then Shutl::ResourceConflict
      when 410 then Shutl::ResourceGone
      when 422
        if Shutl::Resource.raise_exceptions_on_validation
          Shutl::ResourceInvalid
        else
          nil #handled as validation failure
        end

      when 411..499
        Shutl::BadRequest
      when 500 then Shutl::ServerError
      when 503 then Shutl::ServiceUnavailable
      when 501..Float::INFINITY
        Shutl::ServerError
      end
    end

    protected

    def generate_url!(url_pattern, args, params = {})
      url = url_pattern.dup

      args, url = replace_args_from_pattern! args, url

      url = URI.escape url
      params = params.except(:headers, :auth, :from, 'headers', 'auth', 'from')
      unless params.empty?
        url += '?' + params.entries.map do |key, value|
          URI::encode "#{key}=#{value}"
        end.join("&")
      end
      url
    end

    def order_collection?
      !!@order_collection_by
    end

    private
    def replace_args_from_pattern! args, url
      args = args.reject! do |key, value|
        if s = url[":#{key}"]
          url.gsub!(s, value.to_s)
        end
      end

      return args, url
    end
  end
end
