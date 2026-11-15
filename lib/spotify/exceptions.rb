module Spotify
  class ImplementationError < StandardError; end
  class EndpointUnavailableInDevelopmentMode < ImplementationError; end
  class Error < StandardError; end
  class AuthenticationError < Error; end
  class HTTPError < Error; end

  class RateLimitError < HTTPError
    attr_reader :reason, :retry_after

    def initialize(message, reason: nil, retry_after: nil)
      super(message)
      @reason = reason
      @retry_after = retry_after
    end
  end

  class InsufficientClientScopeError < Error; end
  class BadRequest < Error; end
  class ResourceNotFound < Error; end
end
