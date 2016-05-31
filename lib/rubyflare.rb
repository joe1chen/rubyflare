require 'rubyflare/version'
require 'rubyflare/connect'
require 'rubyflare/response'

require 'json'

module Rubyflare
  class ConnectionError < StandardError
    attr_reader :response
    def initialize(message, response)
      super(message)
      @response = response
    end
  end

  def self.connect_with(email, api_key, adapter = :curb)
    Rubyflare::Connect.new(email, api_key, adapter)
  end
end
