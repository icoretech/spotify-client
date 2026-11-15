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

Ruby `3.3` or newer is required. The CI matrix runs against Ruby `3.3`, `3.4`, `4.0`, and `ruby-head`, with both released Excon and its development branch.

## Usage

```ruby
config = {
  access_token: 'tk',
  app_mode: :development, # optional; opt into guards for restricted Development Mode endpoints
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
client.request(:get, '/v1/me', [200], { market: 'IT' }) # GET-style hash payloads become query params
client.request!(:post, '/v1/some-endpoint', [201], payload, false) # non-GET hash payloads are JSON encoded
```

## Spotify API Compatibility

The API contracts were checked against Spotify's official documentation on November 15, 2026. The latest listed Web API changelog is July 2026.

| Change | Client behavior |
| --- | --- |
| [February: Development Mode migration](https://developer.spotify.com/documentation/web-api/references/changes/february-2026) | Playlist helpers use `/v1/me/playlists` and `/v1/playlists/{id}/items`. Library helpers and legacy follow helpers use `/v1/me/library`. |
| [March: restored external IDs](https://developer.spotify.com/documentation/web-api/references/changes/march-2026) | Album and track responses retain `external_ids` unchanged. |
| [May: stable account identifier](https://developer.spotify.com/documentation/web-api/references/changes/may-2026) | `me` retains `account_id`. Use this immutable identifier when linking accounts to your service. |
| [June: refresh-token expiration](https://developer.spotify.com/blog/2026-06-18-refresh-token-expiration) | OAuth remains the caller's responsibility. Refresh tokens expire six months after the original authorization; refreshing does not extend their lifetime. Handle `invalid_grant` by asking the user to authorize again. The change applied to existing apps from July 20, 2026. |
| [July: shared development quotas](https://developer.spotify.com/documentation/web-api/references/changes/july-2026) | HTTP 429 raises `Spotify::RateLimitError` when errors are enabled, exposing `reason` and `retry_after`. Development Mode Client IDs share their developer account's quota. |

Response JSON is returned without filtering fields. Account permissions, quota mode, scopes, and playlist ownership still determine which data Spotify returns.

`app_mode: :development` opts into the restricted endpoint contract: `user`, `artist_top_tracks`, and `related_artists` fail before sending a request. Omit this option for integrations that retain access to those endpoints. Spotify [postponed the endpoint-access migration for existing Development Mode integrations](https://developer.spotify.com/blog/2026-02-06-update-on-developer-access-and-platform-security); the February changes do not apply to Extended Quota Mode. `related_artists` is deprecated and only remains usable by eligible integrations.

Library save/remove calls follow the [current endpoint reference](https://developer.spotify.com/documentation/web-api/reference/save-library-items): comma-separated `uris` in the query, with at most 40 items per call. Spotify's February migration guide also shows a JSON-body example. Playlist additions accept at most 100 URI strings as a JSON array. Oversized batches raise `Spotify::ImplementationError`; split them into multiple calls.

### Rate and quota errors

Enable `raise_errors: true` or use `request!` to inspect errors. With the default `raise_errors: false`, non-bang methods continue to return `false` on HTTP errors.

```ruby
begin
  client.request!(:get, '/v1/me')
rescue Spotify::RateLimitError => error
  error.reason      # "QUOTA_EXCEEDED" for the July quota response, otherwise nil
  error.retry_after # Spotify's Retry-After header as a string, or nil
end
```

`RateLimitError` inherits from `HTTPError`, so existing rescues still work. With the default `retries: 0`, a 429 response is returned immediately. Configured Excon retries can retry idempotent requests before exposing the final error. The client does not schedule retries from `Retry-After`; callers decide how to handle the supplied reason and retry interval.

## Development

Use the Ruby version in `.ruby-version`, install dependencies, and run checks:

```bash
bundle install
bundle exec rake
```

The suite enables Ruby warnings and requires 100% line coverage overall and per file.

## Release

The gem version is defined in `lib/spotify/version.rb`. Push a matching `v`-prefixed tag to trigger the release workflow and publish the gem.

## License

MIT. See [LICENSE](LICENSE).
