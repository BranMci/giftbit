require 'active_support'
require 'rest-client'

module Giftbit
  module Base
    def self.included(klass)
      klass.extend ClassMethods

      # By default, set the endpoint to testing
      klass.endpoint  ||= 'https://testbedapp.giftbit.com/papi/v1/'
      # By default, set the auth token to be empty
      klass.auth      ||= ''
    end

    module ClassMethods
      attr_accessor :endpoint, :auth

      # Default resources options included in each request below
      def default_resource_options
        {
          headers: {
            "Authorization" => "Bearer #{@auth}",
            "Accept"        => "application/json",
            "Content-Type"  => "json"
          }
        }
      end

      # Convenience method for building a RestClient::Resource
      def resource(options = {})
        RestClient::Resource.new @endpoint, default_resource_options.deep_merge(options)
      end

      # Convenience method for parsing and error handling a request
      def response(method, resource, options = {})
        body = options.delete(:body)

        if body.nil?
          response = resource.send(method, *[options])
        else
          response = resource.send(method, *[JSON.generate(body), options])
        end

        JSON.parse(response)
      rescue => e
        if e.respond_to?(:response)
          JSON.parse(e.response)
        else
          raise e
        end
      end

      # GET (parsed) response from resources
      def get(path, request_options = {}, resource_options = {})
        response(:get, resource(resource_options)[path], request_options)
      end

      # DELETE (parsed) response from resources
      def delete(path, request_options = {}, resource_options = {})
        response(:delete, resource(resource_options)[path], request_options)
      end

      # POST (parsed) response from resources
      def post(path, request_options = {}, resource_options = {})
        response(:post, resource(resource_options)[path], request_options)
      end

      # PUT (parsed) response from resources
      def put(path, request_options = {}, resource_options = {})
        response(:put, resource(resource_options)[path], request_options)
      end
    end
  end
end