# frozen_string_literal: true

require 'uri'

module Spotify
  class Client
    module Transport
      EXCON_ERROR_MAP = {
        Excon::Errors::NotFound => ResourceNotFound,
        Excon::Errors::BadRequest => BadRequest,
        Excon::Errors::Forbidden => InsufficientClientScopeError,
        Excon::Errors::Unauthorized => AuthenticationError
      }.freeze

      protected

      def run(verb, path, expected_status_codes, params = {}, idempotent = true)
        run!(verb, path, expected_status_codes, params, idempotent)
      rescue Error => e
        handle_nonbang_error(e)
      end

      def run!(verb, path, expected_status_codes, params_or_body = nil, idempotent = true)
        response = @connection.request(
          build_request_packet(
            verb: verb,
            path: path,
            expected_status_codes: expected_status_codes,
            params_or_body: params_or_body,
            idempotent: idempotent
          )
        )
        parse_response_body(response)
      rescue Excon::Errors::Error => e
        raise map_transport_error(e)
      end

      def build_request_packet(verb:, path:, expected_status_codes:, params_or_body:, idempotent:)
        packet = {
          idempotent: idempotent,
          expects: expected_status_codes,
          method: verb,
          path: path,
          read_timeout: @read_timeout,
          write_timeout: @write_timeout,
          retry_limit: @retries,
          headers: {
            'Content-Type' => 'application/json',
            'User-Agent' => "spotify-client/#{Spotify::VERSION} (Ruby)"
          }
        }
        apply_request_payload(packet, params_or_body)

        packet[:headers].merge!('Authorization' => "Bearer #{@access_token}") if !@access_token.nil? && @access_token != ''
        packet
      end

      def apply_request_payload(packet, params_or_body)
        if params_or_body.is_a?(Hash)
          packet[:query] = params_or_body
        else
          packet[:body] = params_or_body
        end
      end

      def parse_response_body(response)
        return {} if response.body.nil? || response.body.empty?

        ::JSON.parse(response.body)
      rescue JSON::ParserError => e
        raise(HTTPError, "Error: #{e.message}")
      end

      def next_page_request(next_url)
        return [nil, {}] if next_url.nil? || next_url.empty?

        uri = URI.parse(next_url)
        [uri.query ? "#{uri.path}?#{uri.query}" : uri.path, {}]
      end

      def handle_nonbang_error(error)
        raise error if @raise_errors

        false
      end

      def map_transport_error(error)
        error_class = EXCON_ERROR_MAP.find do |transport_error, _client_error|
          error.is_a?(transport_error)
        end&.last || HTTPError

        error_class.new("Error: #{error.message}")
      end
    end
  end
end
