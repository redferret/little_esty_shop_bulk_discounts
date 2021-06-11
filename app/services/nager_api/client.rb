require_relative '../lib/api_exceptions'
require_relative 'api_calls'

module NagerAPI
  class Client
    
    extend ApiExceptions
    extend ApiCalls

    API_ENDPOINT = 'https://date.nager.at'.freeze

    attr_reader :response

    private
    def self.client
      @_faraday_connection ||= Faraday.new(API_ENDPOINT) do |client|
        client.headers['Accept'] = 'application/json'
      end
    end

    def self.request(http_method: :get, endpoint: nil, params: {})
      raise 'API endpoint must be defined' if endpoint.nil?
      
      @response = client.public_send(http_method, endpoint, params)
      
      return parse_json if response_successful?
      
      raise http_error, "Status: #{response.status}, Response: #{response.body}"
    end
    
    def self.parse_json
      Oj.load(response.body)
    end
  end
end