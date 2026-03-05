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
# User
client.me

# Library
client.me_albums(params = {})
client.me_audiobooks(params = {})
client.me_episodes(params = {})
client.me_following
client.me_shows(params = {})
client.me_tracks
client.add_to_library(uris)
client.remove_from_library(uris)
client.user_playlists(user_id = nil) # backward-compatible signature; requests /v1/me/playlists
client.create_user_playlist(user_id, name, is_public = true)
client.change_playlist_details(user_id, playlist_id, attributes = {})

# Playlist
client.playlist(playlist_id)
client.playlist_cover_image(playlist_id)
client.upload_playlist_cover_image(playlist_id, image_base64_jpeg)

# Backward-compatible playlist helpers
client.user_playlist(user_id, playlist_id) # delegates to playlist(playlist_id)
client.user_playlist_tracks(user_id, playlist_id, params = {})
client.add_user_tracks_to_playlist(user_id, playlist_id, uris = [], position = nil)
client.remove_user_tracks_from_playlist(user_id, playlist_id, tracks)
client.replace_user_tracks_in_playlist(user_id, playlist_id, tracks)
client.truncate_user_playlist(user_id, playlist_id)

# Metadata
client.album(album_id)
client.album_tracks(album_id)
client.albums(album_ids)
client.artist(artist_id)
client.artists(artist_ids)
client.artist_albums(artist_id)
client.artist_top_tracks(artist_id, country_id)
client.audiobook(audiobook_id, params = {})
client.audiobook_chapters(audiobook_id, params = {})
client.chapter(chapter_id, params = {})
client.episode(episode_id, params = {})
client.show(show_id, params = {})
client.show_episodes(show_id, params = {})
client.track(track_id)
client.tracks(track_ids)

# Personalisation
client.me_top(type, params = {}) # type: "artists" or "tracks"

# Player
client.currently_playing(params = {})
client.recently_played(params = {})
client.playback_state(params = {})
client.available_devices
client.transfer_playback(device_ids, play = nil)
client.start_or_resume_playback(payload = {})
client.pause_playback(params = {})
client.skip_to_next(params = {})
client.skip_to_previous(params = {})
client.seek_to_position(position_ms, params = {})
client.set_repeat_mode(state, params = {})
client.set_playback_volume(volume_percent, params = {})
client.set_shuffle(state, params = {})
client.playback_queue(params = {})
client.add_to_playback_queue(uri, params = {})

# Search
client.search(entity, term, options = {}) # entity: :artist, :album, :track

# Legacy helpers kept for compatibility
client.user(user_id)
client.related_artists(artist_id)
client.follow(type, ids)
client.follow_playlist(user_id, playlist_id, is_public = true)

# Generic helpers for forward compatibility
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
