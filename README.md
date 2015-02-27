# spotify-client

Ruby Client for the [Spotify Web API](https://developer.spotify.com/web-api/).

[![Gem Version](https://badge.fury.io/rb/spotify-client.svg)](http://badge.fury.io/rb/spotify-client)

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'spotify-client'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install spotify-client
```

## Features and Goals

* Optional persistent connections
* Ease of use
* Extremely light footprint, memory is always a concern.
* Be future-proof.

## Usage / Notes

This gem is pretty new and it should not be used in production environments yet.

It has been tested on Ruby 2.1+ only. Feel free to play around with it.

```ruby
# Sample configuration:
config = {
  :access_token => 'tk',  # initialize the client with an access token to perform authenticated calls
  :raise_errors => true,  # choose between returning false or raising a proper exception when API calls fails

  # Connection properties
  :retries       => 0,    # automatically retry a certain number of times before returning
  :read_timeout  => 10,   # set longer read_timeout, default is 10 seconds
  :write_timeout => 10,   # set longer write_timeout, default is 10 seconds
  :persistent    => false # when true, make multiple requests calls using a single persistent connection. Use +close_connection+ method on the client to manually clean up sockets
}
client = Spotify::Client.new(config)
# or with default options:
client = Spotify::Client.new
```

If you want to perform authenticated calls include `access_token` during initialization.
Note that there are particular calls that not only requires authentication but the correct scopes.

Read more about scopes [here](https://developer.spotify.com/web-api/using-scopes/).

```ruby
# Current methods' signatures
client.me
client.user(user_id)
client.user_playlists(user_id)
client.user_playlist(user_id, playlist_id)
client.user_playlist_tracks(user_id, playlist_id, params = {})
client.create_user_playlist(user_id, name, is_public = true)
client.add_user_tracks_to_playlist(user_id, playlist_id, uris = [], position = nil)
client.remove_user_tracks_from_playlist(user_id, playlist_id, tracks)
client.replace_user_tracks_in_playlist(user_id, playlist_id, tracks)
client.truncate_user_playlist(user_id, playlist_id)
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
client.related_artists(artist_id)
client.follow(type, ids)
client.follow_playlist(user_id, playlist_id, is_public = true)
```

Please also refer to the source file [spotify_client.rb](https://github.com/icoretech/spotify-client/blob/master/lib/spotify_client.rb).

More documentation will follow soon.

## Authentication

In order to use authenticated features you need to obtain access tokens.
This feature is not supported (yet) by this gem, but if you'd like to let users authenticate against Spotify in a Rails/OmniAuth app you can use [icoretech/omniauth-spotify](https://github.com/icoretech/omniauth-spotify).

## TODO

* Finish the spec suite and start implementing VCR instead of single response mocks, which doesn't add much value.
* More OAuth2 features?
* Modeling / Hashie / Indifferent Access response encapsulation?
* CI setup

## License

Please refer to [LICENSE.md](https://github.com/icoretech/spotify-client/blob/master/LICENSE).
