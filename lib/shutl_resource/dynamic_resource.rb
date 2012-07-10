require 'active_model/serialization'

module Shutl
  module DynamicResource
    include ActiveModel::Serialization

    def self.included(base)
      base.instance_variable_set :@resource_name, base.name.underscore
    end

    def initialize(args = {})
      args.each { |key, value| instance_variable_set "@#{key}", value }
    end

    def to_json(options = nil)
      {
        :"#{prefix}" => to_hash
      }.to_json(options)
    end

    protected

    def prefix
      self.class.instance_variable_get(:@resource_name)
    end

    def to_hash
      instance_variables.inject({}) { |h, variable| h[variable.to_s.gsub('@','').to_sym] = instance_variable_get(variable) ; h }
    end

  end
end
