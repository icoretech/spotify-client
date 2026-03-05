# spotify-client

Ruby client for the [Spotify Web API](https://developer.spotify.com/documentation/web-api).

[![Test](https://github.com/icoretech/spotify-client/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/icoretech/spotify-client/actions/workflows/test.yml?query=branch%3Amain)
[![Gem Version](https://badge.fury.io/rb/spotify-client.svg)](https://badge.fury.io/rb/spotify-client)

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'spotify-client'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install spotify-client
```

## Supported Ruby Versions

The CI matrix runs this gem against Ruby `3.2`, `3.3`, `3.4`, `4.0`, and `ruby-head`.

## Usage

```ruby
config = {
  access_token: 'tk',
  app_mode: :development, # optional; use :development to fail fast on dev-mode restricted endpoints
  raise_errors: true,
  retries: 0,
  read_timeout: 10,
  write_timeout: 10,
  persistent: false
}

client = Spotify::Client.new(config)
```

## Public API

```ruby
client.me
client.me_tracks
client.me_following
client.user(user_id)
client.user_playlists(user_id) # user_id kept for backward compatibility; requests /v1/me/playlists
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
client.search(entity, term, options = {})
client.artist_top_tracks(artist_id, country_id)
client.related_artists(artist_id)
client.follow(type, ids)
client.follow_playlist(user_id, playlist_id, is_public = true)
client.request(:get, '/v1/me') # generic helper for newer endpoints
client.request!(:post, '/v1/some-endpoint', [201], payload, false)
```

## Spotify API Migration Notes

Spotify's Web API changed and removed several legacy endpoints in 2026. This gem now uses current routes while keeping backward-compatible method signatures:

- Playlist reads/writes use `/v1/me/playlists` and `/v1/playlists/{playlist_id}/*`.
- `follow(type, ids)` now targets `/v1/me/library` using Spotify URIs (`spotify:{type}:{id}`), while still accepting prebuilt URIs.
- `artist_top_tracks` uses `/v1/artists/{id}/top-tracks`.
- `user(user_id)` and `artist_top_tracks` rely on endpoints that Spotify marks unavailable for Development Mode apps (still usable for Extended Quota Mode apps).
- If initialized with `app_mode: :development`, `user(user_id)` and `artist_top_tracks` raise `Spotify::EndpointUnavailableInDevelopmentMode` before making the HTTP request.

- February 2026 changes: [Spotify Web API Changes](https://developer.spotify.com/documentation/web-api/references/changes/february-2026)

## Development

Install dependencies and run checks:

```bash
bundle install
bundle exec rake
```

## Release

Pushing a tag matching `v*` triggers the release workflow that builds and publishes the gem.

## License

MIT. See [LICENSE](LICENSE).
