module Shutl::Resource
  module RestResourceClassMethods
    def find(args, params = {})
      unless args.kind_of?(Hash)
        id = args
        args = { resource_id_name => id }
      end
      token = params.delete :auth
      url = member_url args.dup, params
      response = get url, headers_with_auth(token)

      check_fail response, "Failed to find #{name} with the id #{id}"

      parsed = response.parsed_response

      including_parent_attributes = parsed[@resource_name].merge args

      new_object including_parent_attributes, response
    end

    def create attributes = {}, options = {}
      url = generate_collection_url attributes
      attributes.delete "response"

      response = post(url,
        {body: {@resource_name => attributes}.to_json}.
          merge(headers_with_auth options[:auth]))

      check_fail response, "Create failed"

      parsed = response.parsed_response || {}

      attributes = parsed[@resource_name] || {}
      new_object attributes, response
    end

    def destroy instance, options = {}
      message =  "Failed to destroy #{name.downcase.pluralize}"

      perform_action(
        instance,
        :delete,
        headers_with_auth(options[:auth]),
        message
      ).success?
    end

    def save instance, options = {}
      #TODO: this is sometimes a hash and sometimes a RestResource - need to rethink this
      attributes = instance.attributes rescue instance

      response = perform_action instance, :put,
        {body: {@resource_name => attributes}.to_json}.merge(headers_with_auth options[:auth]),
      "Save failed"

      response.success?
    end

    def update args, options = {}
      save args, options
    end


    def all(args = {})
      token = args.delete :auth
      partition = args.partition {|key,value| !remote_collection_url.index(":#{key}").nil? }

      url_args = partition.first.inject({}) { |h,pair| h[pair.first] = pair.last ; h }
      params   = partition.last. inject({}) { |h,pair| h[pair.first] = pair.last ; h }

      url = generate_collection_url url_args, params
      response = get url, headers_with_auth(token)

      check_fail response, "Failed to find all #{name.downcase.pluralize}"

      response.parsed_response[@resource_name.pluralize].map do |h|
        new_object(args.merge(h), response)
      end
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

    def add_resource_id_to args={}
      args = args.dup.with_indifferent_access
      unless args.has_key? "id"
        args.merge!({"id" => args[resource_id_name]})
      end
      args
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


    private

    def headers_with_auth token
      { headers: headers.merge('Authorization' => "Bearer #{token}") }
    end

    def perform_action instance, verb, args, failure_message
      attributes = instance.is_a?(Hash) ?  instance : instance.attributes
      attributes.delete "response" #used in debugging requests/responses

      url = member_url attributes
      response = send verb, url, args

      check_fail response, failure_message

      response
    end

    def new_object(args={}, response=nil)
      new add_resource_id_to(args), response
    end

    def check_fail response, message
      c = response.code
      failure_klass = case c
                      when 299 then Shutl::NoQuotesGenerated
                      when 400 then Shutl::BadRequest
                      when 401 then Shutl::UnauthorizedAccess
                      when 403 then Shutl::ForbiddenAccess
                      when 404 then Shutl::ResourceNotFound
                      when 409 then Shutl::ResourceConflict
                      when 410 then Shutl::ResourceGone
                      when 422 then Shutl::ResourceInvalid
                      when 411..499
                        Shutl::BadRequest
                      when 500 then Shutl::ServerError
                      when 503 then Shutl::ServiceUnavailable
                      when 501..Float::INFINITY
                        Shutl::ServerError
                      end

      raise failure_klass.new message, response if failure_klass
    end

    protected

    def generate_url!(url_pattern, args, params = {})
      url = url_pattern.dup

      args, url = replace_args_from_pattern! args, url

      url = URI.escape url
      unless params.empty?
        url += '?'
        params.each { |key, value| url += "#{key}=#{value}&" }
      end
      url
    end

    private
    def replace_args_from_pattern! args, url
      args = args.reject! do |key,value|
        if s = url[":#{key}"]
          url.gsub!(s, value.to_s)
        end
      end

      return args, url
    end
  end
end
