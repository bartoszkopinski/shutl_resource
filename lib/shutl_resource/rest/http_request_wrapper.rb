require 'date'

module HTTParty
  class Request
    alias_method :perform_no_log, :perform

    def perform(&block)

      start = DateTime.now
      response = perform_no_log &block
      duration = (DateTime.now - start).to_f / 24 * 60 * 60 * 1000

      info "#{@raw_request.method.to_s.upcase} #{http.use_ssl? ? 'https' : 'http'}://#{http.address}:#{http.port}#{@raw_request.path}"
      info "--> %d %s %d (%.1fms)" % [response.code, response.message, response.body.to_s.length, duration]

      response
    end

    private

    def info(message)
      Shutl::Rest.logger.info message
    end
  end
end
