module Shutl
  module DynamicResource

    def initialize(args = {})
      args.each { |key, value| instance_variable_set "@#{key}", value }
    end

    def to_json
      {
        :"#{prefix}" => to_hash
      }.to_json
    end

    protected

    def prefix
      'test_resource'
    end

    def to_hash
     instance_variables.inject({}) { |h, variable| h[variable.to_s.gsub('@','').to_sym] = instance_variable_get(variable) ; h }
    end
  end
end
