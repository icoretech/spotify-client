require 'excon'
require 'json'

require "#{File.dirname(__FILE__)}/spotify/exceptions"

module Spotify
  class Client
    BASE_URI = 'https://api.spotify.com'.freeze

    attr_accessor :access_token

    # Initialize the client.
    #
    # @example
    #   client = Spotify::Client.new(:access_token => 'longtoken', retries: 0, raise_errors: true)
    #
    # @param [Hash] configuration.
    def initialize(config = {})
      @access_token  = config[:access_token]
      @raise_errors  = config[:raise_errors] || false
      @retries       = config[:retries] || 0
      @read_timeout  = config[:read_timeout] || 10
      @write_timeout = config[:write_timeout] || 10
      @connection    = Excon.new(BASE_URI, persistent: config[:persistent] || false)
    end

    def inspect
      vars = instance_variables.map { |v| "#{v}=#{instance_variable_get(v).inspect}" }.join(', ')
      "<#{self.class}: #{vars}>"
    end

    # Closes the connection underlying socket.
    # Use when you employ persistent connections and are done with your requests.
    def close_connection
      @connection.reset
    end

    def me
      run(:get, '/v1/me', [200])
    end

    def me_tracks
      run(:get, '/v1/me/tracks', [200])
    end

    # params:
    # - type: Required, The ID type, currently only 'artist' is supported
    # - limit: Optional. The maximum number of items to return. Default: 20. Minimum: 1. Maximum: 50.
    # - after: Optional. The last artist ID retrieved from the previous request.
    def me_following(params = {})
      params = params.merge(type: 'artist')
      run(:get, '/v1/me/following', [200], params)
    end

    def user(user_id)
      run(:get, "/v1/users/#{user_id}", [200])
    end

    def user_playlists(_user_id = nil)
      run(:get, '/v1/me/playlists', [200])
    end

    def user_playlist(_user_id, playlist_id)
      run(:get, "/v1/playlists/#{playlist_id}", [200])
    end

    def user_playlist_tracks(_user_id, playlist_id, params = {})
      tracks = { 'items' => [] }
      path = "/v1/playlists/#{playlist_id}/tracks"

      while path
        response = run(:get, path, [200], params)
        tracks['items'].concat(response.delete('items'))
        tracks.merge!(response)

        path = response['next']&.gsub(BASE_URI, '')
      end

      tracks
    end

    # Create a playlist for a Spotify user. The playlist will be empty until you add tracks.
    #
    # Requires playlist-modify-public for a public playlist.
    # Requires playlist-modify-private for a private playlist.
    def create_user_playlist(_user_id, name, is_public = true)
      run(:post, '/v1/me/playlists', [201], JSON.dump(name: name, public: is_public), false)
    end

    # Add an Array of track uris to an existing playlist.
    #
    # Adding tracks to a user's public playlist requires authorization of the playlist-modify-public scope;
    # adding tracks to a private playlist requires the playlist-modify-private scope.
    #
    # client.add_user_tracks_to_playlist(
    #   '1181346016', '7i3thJWDtmX04dJhFwYb0x', %w(spotify:track:... spotify:track:...)
    # )
    def add_user_tracks_to_playlist(_user_id, playlist_id, uris = [], position = nil)
      params = { uris: Array(uris)[0..99].join(',') }
      params.merge!(position: position) if position
      run(:post, "/v1/playlists/#{playlist_id}/items", [200, 201], JSON.dump(params), false)
    end

    # Removes tracks from playlist
    #
    # client.remove_user_tracks_from_playlist(
    #   '1181346016', '7i3thJWDtmX04dJhFwYb0x', [{ uri: 'spotify:track:...', positions: [0] }]
    # )
    def remove_user_tracks_from_playlist(_user_id, playlist_id, tracks)
      run(:delete, "/v1/playlists/#{playlist_id}/tracks", [200], JSON.dump(tracks: tracks))
    end

    # Replaces all occurrences of tracks with what's in the playlist
    #
    # client.replace_user_tracks_in_playlist(
    #   '1181346016', '7i3thJWDtmX04dJhFwYb0x', %w(spotify:track:... spotify:track:...)
    # )
    def replace_user_tracks_in_playlist(_user_id, playlist_id, tracks)
      run(:put, "/v1/playlists/#{playlist_id}/tracks", [200, 201], JSON.dump(uris: tracks))
    end

    # Removes all tracks in playlist
    #
    # client.truncate_user_playlist('1181346016', '7i3thJWDtmX04dJhFwYb0x')
    def truncate_user_playlist(user_id, playlist_id)
      replace_user_tracks_in_playlist(user_id, playlist_id, [])
    end

    def album(album_id)
      run(:get, "/v1/albums/#{album_id}", [200])
    end

    def album_tracks(album_id)
      run(:get, "/v1/albums/#{album_id}/tracks", [200])
    end

    def albums(album_ids)
      params = { ids: Array(album_ids).join(',') }
      run(:get, '/v1/albums', [200], params)
    end

    def track(track_id)
      run(:get, "/v1/tracks/#{track_id}", [200])
    end

    def tracks(track_ids)
      params = { ids: Array(track_ids).join(',') }
      run(:get, '/v1/tracks', [200], params)
    end

    def artist(artist_id)
      run(:get, "/v1/artists/#{artist_id}", [200])
    end

    def artists(artist_ids)
      params = { ids: Array(artist_ids).join(',') }
      run(:get, '/v1/artists', [200], params)
    end

    def artist_albums(artist_id)
      run(:get, "/v1/artists/#{artist_id}/albums", [200])
    end

    def search(entity, term, options = {})
      unless %i[artist album track].include?(entity.to_sym)
        raise(ImplementationError, "entity needs to be either artist, album or track, got: #{entity}")
      end

      params = {
        q: term.to_s,
        type: entity
      }.merge(options)
      run(:get, '/v1/search', [200], params)
    end

    # Get Spotify catalog information about an artist's top 10 tracks by country.
    #
    # +country_id+ is required. An ISO 3166-1 alpha-2 country code.
    def artist_top_tracks(artist_id, country_id)
      run(:get, "/v1/artists/#{artist_id}/top-songs", [200], market: country_id)
    end

    def related_artists(artist_id)
      run(:get, "/v1/artists/#{artist_id}/related-artists", [200])
    end

    # Follow artists or users
    #
    # client.follow('artist', ['0BvkDsjIUla7X0k6CSWh1I'])
    def follow(type, ids)
      _type = type # kept for backward-compatible signature
      params = { ids: Array(ids).join(',') }
      run(:put, '/v1/me/library', [200, 204], params)
    end

    # Follow a playlist
    #
    # client.follow_playlist('lukebryan', '0obRj9nNySESpFelMCLSya')
    def follow_playlist(_user_id, playlist_id, is_public = true)
      run(:put, "/v1/playlists/#{playlist_id}/followers", [200, 204], { public: is_public })
    end

    # Generic API helper for forward compatibility with newly added endpoints.
    def request(verb, path, expected_status_codes = [200], params_or_body = {}, idempotent = true)
      run(verb.to_sym, path, Array(expected_status_codes), params_or_body, idempotent)
    end

    # Bang variant that propagates mapped API errors.
    def request!(verb, path, expected_status_codes = [200], params_or_body = {}, idempotent = true)
      run!(verb.to_sym, path, Array(expected_status_codes), params_or_body, idempotent)
    end

    protected

    def run(verb, path, expected_status_codes, params = {}, idempotent = true)
      run!(verb, path, expected_status_codes, params, idempotent)
    rescue Error => e
      raise e if @raise_errors

      false
    end

    def run!(verb, path, expected_status_codes, params_or_body = nil, idempotent = true)
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
          'User-Agent' => 'Spotify Ruby Client'
        }
      }
      if params_or_body.is_a?(Hash)
        packet.merge!(query: params_or_body)
      else
        packet.merge!(body: params_or_body)
      end

      packet[:headers].merge!('Authorization' => "Bearer #{@access_token}") if !@access_token.nil? && @access_token != ''

      # puts "\033[31m [Spotify] HTTP Request: #{verb.upcase} #{BASE_URI}#{path} #{packet[:headers].inspect} \e[0m"
      response = @connection.request(packet)
      return {} if response.body.nil? || response.body.empty?

      ::JSON.parse(response.body)
    rescue Excon::Errors::NotFound => e
      raise(ResourceNotFound, "Error: #{e.message}")
    rescue Excon::Errors::BadRequest => e
      raise(BadRequest, "Error: #{e.message}")
    rescue Excon::Errors::Forbidden => e
      raise(InsufficientClientScopeError, "Error: #{e.message}")
    rescue Excon::Errors::Unauthorized => e
      raise(AuthenticationError, "Error: #{e.message}")
    rescue Excon::Errors::Error => e
      # Catch all others errors. Samples:
      #
      # <Excon::Errors::SocketError: Connection refused - connect(2) (Errno::ECONNREFUSED)>
      # <Excon::Errors::InternalServerError: Expected([200, 204, 404]) <=> Actual(500 InternalServerError)>
      # <Excon::Errors::Timeout: read timeout reached>
      # <Excon::Errors::BadGateway: Expected([200]) <=> Actual(502 Bad Gateway)>
      raise(HTTPError, "Error: #{e.message}")
    end
  end
end
