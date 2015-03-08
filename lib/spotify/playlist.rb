module Spotify
  class Playlist

    FIELDS = %w{ collaborative description external_urls href id name owner
                 public snapshot_id type uri }

    FIELDS.each do |f|
      attr_accessor f.to_sym
    end
    attr_accessor :client

    def initialize(client, options={})
      @client = client

      attributes(options)
    end

    def attributes(options)
      options.each do |key, val|
        key = key.to_s if key.is_a?(Symbol)
        next unless FIELDS.include?(key)
        send("#{key}=", val)
      end
    end

    def user_id
      @user_id ||= client.me['id']
    end

    def fetch
      if id
        response =
          client.run(:get, "/v1/users/#{user_id}/playlists/#{id}", [200])

        attributes(response)
      end
    end

    # Create a playlist for a Spotify user. The playlist will be empty until you add tracks.
    #
    # Requires playlist-modify-public for a public playlist.
    # Requires playlist-modify-private for a private playlist.
    def self.create(client, name, is_public = true)
      user_id = client.me['id']
      response =
        client.run(:post, "/v1/users/#{user_id}/playlists", [201], JSON.dump(name: name, public: is_public), false)
      new(client, response)
    end

    # Add an Array of track uris to an existing playlist.
    #
    # Adding tracks to a user's public playlist requires authorization of the playlist-modify-public scope;
    # adding tracks to a private playlist requires the playlist-modify-private scope.
    #
    # playlist.add_tracks(%w(spotify:track:4iV5W9uYEdYUVa79Axb7Rh spotify:track:2lzEz3A3XIFyhMDqzMdcss))
    def add_tracks(uris=[], position=nil)
      params = { uris: Array.wrap(uris)[0..99].join(',') }
      if position
        params.merge!(position: position)
      end
      client.run(:post, "/v1/users/#{user_id}/playlists/#{id}/tracks", [201], params, false)
    end

    # Replaces all occurrences of tracks with what's in the playlist
    #
    # playlist.replace_tracks(%w(spotify:track:4iV5W9uYEdYUVa79Axb7Rh spotify:track:2lzEz3A3XIFyhMDqzMdcss))
    def replace_tracks(tracks)
      client.run(:put, "/v1/users/#{user_id}/playlists/#{id}/tracks", [201], JSON.dump(uris: tracks))
    end

    # Removes all tracks in playlist
    #
    # playlist.truncate
    def truncate
      replace_tracks([])
    end
  end
end
