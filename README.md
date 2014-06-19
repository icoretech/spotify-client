# spotify-client

Ruby Client for Spotify Web API.

## Installation

Add this line to your application's Gemfile:

    gem 'spotify-client'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spotify-client

## Usage / Notes

This gem is pretty new and it should not be used in production environments yet.
It has been tested on Ruby 2.1+ only.

```ruby
client = Spotify::Client.new(:access_token => 'longtoken', retries: 0, raise_errors: true)
# or accepts the defaults
client = Spotify::Client.new

client.me
client.user(user_id)
client.user_playlists(user_id)
client.user_playlist(user_id, playlist_id)
client.user_playlist_tracks(user_id, playlist_id)
client.create_user_playlist(user_id, name, is_public = true)
client.add_user_tracks_to_playlist(user_id, playlist_id, uris = [], position = nil)
client.album(album_id)
client.album_tracks(album_id)
client.albums(album_ids)
client.track(track_id)
client.tracks(track_ids)
client.artist(artist_id)
client.artists(artist_ids)
client.artist_albums(artist_id)
client.search(entity, term)
client.artist_top_tracks(artist_id, country_id)
```

Please also refer to the source file [spotify_client.rb](https://github.com/icoretech/spotify-client/blob/master/lib/spotify_client.rb).
Other initialization options:

```ruby
:access_token  # initializes the client with an access token for authenticated calls
:raise_errors  # choose between returning false or raising a proper exception when API calls fails
```

Connection properties:

```ruby
:retries       # automatically retry a certain number of times before returning errors/false
:read_timeout  # set longer read_timeout, default is 10 seconds
:write_timeout # set longer write_timeout, default is 10 seconds
:persistent    # if true, make multiple requests calls using a single persistent connection. Use +close_connection+ method on the client to manually clean up sockets
```

More documentation will follow.

## License

Please refer to [LICENSE.md](https://github.com/icoretech/spotify-client/blob/master/LICENSE).
