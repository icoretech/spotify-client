# frozen_string_literal: true

module Spotify
  class Client
    module CompatibilityAPI
      def user(user_id)
        raise_endpoint_unavailable_in_development_mode!(
          endpoint: 'GET /v1/users/{id}',
          replacement: 'GET /v1/me'
        )
        run(:get, "/v1/users/#{user_id}", [200])
      end

      def user_playlists(_user_id = nil)
        run(:get, '/v1/me/playlists', [200])
      end

      def user_playlist(_user_id, playlist_id)
        playlist(playlist_id)
      end

      def user_playlist_tracks(_user_id, playlist_id, params = {})
        tracks = { 'items' => [] }
        path = "/v1/playlists/#{playlist_id}/items"
        query_params = params.dup

        while path
          response = run(:get, path, [200], query_params)
          return false unless response

          tracks['items'].concat(response.fetch('items', []))
          tracks.merge!(response.reject { |key, _value| key == 'items' })
          path, query_params = next_page_request(response['next'])
        end

        tracks
      end

      def create_user_playlist(_user_id, name, is_public = true)
        run(:post, '/v1/me/playlists', [201], JSON.dump(name: name, public: is_public), false)
      end

      def change_playlist_details(_user_id, playlist_id, attributes = {})
        run(:put, "/v1/playlists/#{playlist_id}", [200, 204], JSON.dump(attributes), false)
      end

      def add_user_tracks_to_playlist(_user_id, playlist_id, uris = [], position = nil)
        params = { uris: Array(uris)[0..99].join(',') }
        params.merge!(position: position) if position
        run(:post, "/v1/playlists/#{playlist_id}/items", [200, 201], JSON.dump(params), false)
      end

      def remove_user_tracks_from_playlist(_user_id, playlist_id, tracks)
        run(:delete, "/v1/playlists/#{playlist_id}/items", [200], JSON.dump(items: tracks))
      end

      def replace_user_tracks_in_playlist(_user_id, playlist_id, tracks)
        run(:put, "/v1/playlists/#{playlist_id}/items", [200, 201], JSON.dump(uris: tracks))
      end

      def truncate_user_playlist(user_id, playlist_id)
        replace_user_tracks_in_playlist(user_id, playlist_id, [])
      end

      def follow(type, ids)
        entity_type = type.to_s.strip
        uris = Array(ids).map do |id|
          raw = id.to_s
          next raw if raw.start_with?('spotify:')

          raise(ImplementationError, 'type is required when ids are not full Spotify URIs') if entity_type.empty?

          "spotify:#{entity_type}:#{raw}"
        end
        add_to_library(uris)
      end

      def follow_playlist(_user_id, playlist_id, _is_public = true)
        add_to_library(["spotify:playlist:#{playlist_id}"])
      end
    end
  end
end
