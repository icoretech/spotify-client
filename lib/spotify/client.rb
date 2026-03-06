# frozen_string_literal: true

require 'excon'
require 'json'

require 'spotify/exceptions'
require 'spotify/version'
require 'spotify/client/compatibility_api'
require 'spotify/client/transport'

module Spotify
  class Client
    include CompatibilityAPI
    include Transport

    BASE_URI = 'https://api.spotify.com'

    attr_accessor :access_token

    # Initialize the client.
    #
    # @example
    #   client = Spotify::Client.new(:access_token => 'longtoken', retries: 0, raise_errors: true)
    #
    # @param [Hash] configuration.
    def initialize(config = {})
      @access_token = config[:access_token]
      @raise_errors = config[:raise_errors] || false
      @retries = config[:retries] || 0
      @read_timeout = config[:read_timeout] || 10
      @write_timeout = config[:write_timeout] || 10
      @app_mode = config[:app_mode].to_s.strip.downcase
      @connection = Excon.new(BASE_URI, persistent: config[:persistent] || false)
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

    def me_albums(params = {})
      run(:get, '/v1/me/albums', [200], params)
    end

    def me_audiobooks(params = {})
      run(:get, '/v1/me/audiobooks', [200], params)
    end

    def me_episodes(params = {})
      run(:get, '/v1/me/episodes', [200], params)
    end

    def me_shows(params = {})
      run(:get, '/v1/me/shows', [200], params)
    end

    # params:
    # - type: Required, The ID type, currently only 'artist' is supported
    # - limit: Optional. The maximum number of items to return. Default: 20. Minimum: 1. Maximum: 50.
    # - after: Optional. The last artist ID retrieved from the previous request.
    def me_following(params = {})
      params = params.merge(type: 'artist')
      run(:get, '/v1/me/following', [200], params)
    end

    def playlist(playlist_id)
      run(:get, "/v1/playlists/#{playlist_id}", [200])
    end

    def playlist_cover_image(playlist_id)
      run(:get, "/v1/playlists/#{playlist_id}/images", [200], {})
    end

    def upload_playlist_cover_image(playlist_id, image_base64_jpeg)
      run(:put, "/v1/playlists/#{playlist_id}/images", [200, 202, 204], image_base64_jpeg.to_s, false)
    end

    def album(album_id)
      run(:get, "/v1/albums/#{album_id}", [200])
    end

    def album_tracks(album_id)
      run(:get, "/v1/albums/#{album_id}/tracks", [200])
    end

    def albums(album_ids)
      { 'albums' => Array(album_ids).map { |album_id| album(album_id) } }
    end

    def track(track_id)
      run(:get, "/v1/tracks/#{track_id}", [200])
    end

    def tracks(track_ids)
      { 'tracks' => Array(track_ids).map { |track_id| track(track_id) } }
    end

    def artist(artist_id)
      run(:get, "/v1/artists/#{artist_id}", [200])
    end

    def artists(artist_ids)
      { 'artists' => Array(artist_ids).map { |artist_id| artist(artist_id) } }
    end

    def artist_albums(artist_id)
      run(:get, "/v1/artists/#{artist_id}/albums", [200])
    end

    def audiobook(audiobook_id, params = {})
      run(:get, "/v1/audiobooks/#{audiobook_id}", [200], params)
    end

    def audiobook_chapters(audiobook_id, params = {})
      run(:get, "/v1/audiobooks/#{audiobook_id}/chapters", [200], params)
    end

    def chapter(chapter_id, params = {})
      run(:get, "/v1/chapters/#{chapter_id}", [200], params)
    end

    def episode(episode_id, params = {})
      run(:get, "/v1/episodes/#{episode_id}", [200], params)
    end

    def show(show_id, params = {})
      run(:get, "/v1/shows/#{show_id}", [200], params)
    end

    def show_episodes(show_id, params = {})
      run(:get, "/v1/shows/#{show_id}/episodes", [200], params)
    end

    def search(entity, term, options = {})
      unless %i[artist album track].include?(entity.to_sym)
        raise(ImplementationError, "entity needs to be either artist, album or track, got: #{entity}")
      end

      options = options.dup
      options[:limit] = [options[:limit].to_i, 10].min if options.key?(:limit)

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
      raise_endpoint_unavailable_in_development_mode!(endpoint: 'GET /v1/artists/{id}/top-tracks')
      run(:get, "/v1/artists/#{artist_id}/top-tracks", [200], country: country_id)
    end

    def related_artists(artist_id)
      run(:get, "/v1/artists/#{artist_id}/related-artists", [200])
    end

    def me_top(type, params = {})
      valid_types = %w[artists tracks]
      normalized_type = type.to_s
      unless valid_types.include?(normalized_type)
        raise(ImplementationError, "type needs to be one of #{valid_types.join(', ')}, got: #{type}")
      end

      run(:get, "/v1/me/top/#{normalized_type}", [200], params)
    end

    def currently_playing(params = {})
      run(:get, '/v1/me/player/currently-playing', [200], params)
    end

    def recently_played(params = {})
      run(:get, '/v1/me/player/recently-played', [200], params)
    end

    def playback_state(params = {})
      run(:get, '/v1/me/player', [200], params)
    end

    def available_devices
      run(:get, '/v1/me/player/devices', [200], {})
    end

    def transfer_playback(device_ids, play = nil)
      body = { device_ids: Array(device_ids) }
      body[:play] = play unless play.nil?
      run(:put, '/v1/me/player', [200, 204], JSON.dump(body), false)
    end

    def start_or_resume_playback(payload = {})
      run(:put, '/v1/me/player/play', [200, 204], JSON.dump(payload), false)
    end

    def pause_playback(params = {})
      run(:put, '/v1/me/player/pause', [200, 204], params, false)
    end

    def skip_to_next(params = {})
      run(:post, '/v1/me/player/next', [200, 204], params, false)
    end

    def skip_to_previous(params = {})
      run(:post, '/v1/me/player/previous', [200, 204], params, false)
    end

    def seek_to_position(position_ms, params = {})
      run(:put, '/v1/me/player/seek', [200, 204], params.merge(position_ms: position_ms), false)
    end

    def set_repeat_mode(state, params = {})
      run(:put, '/v1/me/player/repeat', [200, 204], params.merge(state: state), false)
    end

    def set_playback_volume(volume_percent, params = {})
      run(:put, '/v1/me/player/volume', [200, 204], params.merge(volume_percent: volume_percent), false)
    end

    def set_shuffle(state, params = {})
      run(:put, '/v1/me/player/shuffle', [200, 204], params.merge(state: state), false)
    end

    def playback_queue(params = {})
      run(:get, '/v1/me/player/queue', [200], params)
    end

    def add_to_playback_queue(uri, params = {})
      run(:post, '/v1/me/player/queue', [200, 204], params.merge(uri: uri), false)
    end

    def add_to_library(uris)
      run(:put, '/v1/me/library', [200, 204], JSON.dump(uris: Array(uris)), false)
    end

    def remove_from_library(uris)
      run(:delete, '/v1/me/library', [200, 204], JSON.dump(uris: Array(uris)), false)
    end

    # Generic API helper for forward compatibility with newly added endpoints.
    def request(verb, path, expected_status_codes = [200], params_or_body = {}, idempotent = true)
      run(
        verb.to_sym,
        path,
        Array(expected_status_codes),
        normalize_generic_request_payload(verb, params_or_body),
        idempotent
      )
    end

    # Bang variant that propagates mapped API errors.
    def request!(verb, path, expected_status_codes = [200], params_or_body = {}, idempotent = true)
      run!(
        verb.to_sym,
        path,
        Array(expected_status_codes),
        normalize_generic_request_payload(verb, params_or_body),
        idempotent
      )
    end

    protected

    def raise_endpoint_unavailable_in_development_mode!(endpoint:, replacement: nil)
      return unless development_mode?

      message = "#{endpoint} is unavailable for Spotify Development Mode apps as of March 9, 2026."
      message += " Use #{replacement} instead." if replacement
      raise(EndpointUnavailableInDevelopmentMode, message)
    end

    def development_mode?
      @app_mode == 'development' || @app_mode == 'development_mode'
    end

    def normalize_generic_request_payload(verb, params_or_body)
      return params_or_body unless params_or_body.is_a?(Hash)

      query_verbs = %i[get head options]
      return params_or_body if query_verbs.include?(verb.to_sym)

      JSON.dump(params_or_body)
    end
  end
end
