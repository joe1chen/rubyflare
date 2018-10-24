module Rubyflare
  class Connect

    attr_reader :response
    attr_reader :adapter

    API_URL = "https://api.cloudflare.com/client/v4/"

    def initialize(email, api_key, adapter = :curb)
      @email = email
      @api_key = api_key

      case adapter
        when :curb
          require 'curb'
        when :faraday
          require 'faraday'
        else
          raise ArgumentError, ":#{adapter} is not a valid HTTP client"
      end

      @adapter = adapter
    end

    def perform_request(method_name, endpoint, options)
      case @adapter
        when :curb
          options = options.to_json unless method_name == :get
          response = Curl.send(method_name, API_URL + endpoint, options) do |http|
            http.headers['X-Auth-Email'] = @email
            http.headers['X-Auth-Key'] = @api_key
            http.headers['Content-Type'] = 'application/json'
            http.headers['User-Agent'] = "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36"
          end

          return response.body_str

        when :faraday
          if defined?(HTTPClient)
            conn = Faraday.new(url: API_URL) do |c|
              c.adapter :httpclient
            end
          else
            conn = Faraday.new(url: API_URL)
          end

          response = conn.send(method_name, API_URL + endpoint, options) do |req|
            req.headers['X-Auth-Email'] = @email
            req.headers['X-Auth-Key'] = @api_key
            req.headers['Content-Type'] = 'application/json'
            req.headers['User-Agent'] = "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36"

            req.options.timeout = 45            # open/read timeout in seconds
            req.options.open_timeout = 10       # connection open timeout in seconds

            if options
              if options.is_a?(Hash)
                req.body = options.to_json
              elsif options.is_a?(String)
                req.body = options
              end
            end
          end

          return response.body
      end
    end
    
    %i(get post put patch delete).each do |method_name|
      define_method(method_name) do |endpoint, options = {}|
        response_body = perform_request(method_name, endpoint, options)
        @response = Rubyflare::Response.new(method_name, endpoint, response_body)
      end
    end


  end
end


