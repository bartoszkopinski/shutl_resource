require 'forwardable'
require 'awesome_print'

module Faraday
  class Middleware
    class DefaultLogger < Faraday::Middleware
      extend Forwardable

      def_delegators :@logger, :debug, :info, :warn, :error, :fatal

      def initialize(app, options = {})
        @app = app
        @logger = options.fetch(:logger) {
          require 'logger'
          ::Logger.new($stderr)
        }
      end

      def call(env)
        start_time = Time.now
        info  request_info(env)
        debug request_debug(env)

        @app.call(env).on_complete do
          end_time = Time.now
          response_time = end_time - start_time
          info  response_info(env, response_time)
          debug response_debug(env)
        end
      end

      private

      def request_info(env)
        "  Started %s request to: %s" % [ env[:method].to_s.upcase, env[:url] ]
      end

      def response_info(env, response_time)
        "  Response from %s; Status: %d; Time: %.1fms" % [ env[:url], env[:status], (response_time * 1_000.0) ]
      end

      def request_debug(env)
        request_headers = strip_auth env[:request_headers]

        debug_message("Request", request_headers, env[:body])
      end

      def strip_auth(headers)
        headers.dup.tap do |h|
          h["Authorization"] = h["Authorization"][0..3] << "***" << h["Authorization"][-4..-1]
        end
      end

      def response_debug(env)
        debug_message("Response", env[:response_headers], env[:body])
      end

      def debug_message(name, headers, body)
        <<-MESSAGE.gsub(/^ +([^ ])/m, '    \\1')
        #{name} Headers:
        ----------------
        #{format_headers(headers)}

        #{name} Body:
        -------------
        #{body}
        MESSAGE
      end

      def format_headers(headers)
        length = headers.map {|k,v| k.to_s.size }.max
        headers.map { |name, value| "    #{name.to_s.ljust(length)} : #{value}" }.join("\n")
      end
    end
  end
end
