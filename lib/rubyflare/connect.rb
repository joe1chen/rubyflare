module Rubyflare
  class Connect

    attr_reader :response
    attr_accessor :adapter

    API_URL = "https://api.cloudflare.com/client/v4/"

    def initialize(email, api_key, adapter = :curb)
      @email = email
      @api_key = api_key

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

          response = conn.send(method_name, (method_name == :get ? options : nil)) do |req|
            setup_request(method_name, req, options)
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

    def setup_request(method_name, req, options = nil)
      req.url endpoint                    # Full url is API_URL + endpoint
      req.headers['X-Auth-Email'] = @email
      req.headers['X-Auth-Key'] = @api_key
      req.headers['Content-Type'] = 'application/json'
      req.options.timeout = 15            # open/read timeout in seconds
      req.options.open_timeout = 10       # connection open timeout in seconds

      if method_name != :get && options && !options.empty?
        req.body = options
      end
    end

  end
end


