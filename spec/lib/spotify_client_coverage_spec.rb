describe Spotify::Client do
  let(:client) { described_class.new(access_token: 'token', raise_errors: true) }

  describe 'utility methods' do
    it 'renders inspect output with ivars' do
      output = client.inspect
      expect(output).to include('Spotify::Client')
      expect(output).to include('@access_token="token"')
    end

    it 'closes persistent connection' do
      connection = client.instance_variable_get(:@connection)
      expect(connection).to receive(:reset)
      client.close_connection
    end
  end

  describe 'wrapper methods' do
    it 'calls me_albums endpoint' do
      expect(client).to receive(:run).with(:get, '/v1/me/albums', [200], {})
      client.me_albums
    end

    it 'calls me_audiobooks endpoint' do
      expect(client).to receive(:run).with(:get, '/v1/me/audiobooks', [200], {})
      client.me_audiobooks
    end

    it 'calls me_episodes endpoint' do
      expect(client).to receive(:run).with(:get, '/v1/me/episodes', [200], {})
      client.me_episodes
    end

    it 'calls me_shows endpoint' do
      expect(client).to receive(:run).with(:get, '/v1/me/shows', [200], {})
      client.me_shows
    end

    it 'calls add_to_library endpoint' do
      expect(client).to receive(:run).with(:put, '/v1/me/library', [200, 204], '{"uris":["spotify:track:t1"]}', false)
      client.add_to_library(['spotify:track:t1'])
    end

    it 'calls remove_from_library endpoint' do
      expect(client).to receive(:run).with(:delete, '/v1/me/library', [200, 204], '{"uris":["spotify:track:t1"]}', false)
      client.remove_from_library(['spotify:track:t1'])
    end

    it 'calls change_playlist_details endpoint' do
      expect(client).to receive(:run).with(:put, '/v1/playlists/p1', [200, 204], '{"description":"desc","public":false}', false)
      client.change_playlist_details('u1', 'p1', description: 'desc', public: false)
    end

    it 'calls audiobook endpoint' do
      expect(client).to receive(:run).with(:get, '/v1/audiobooks/ab1', [200], {})
      client.audiobook('ab1')
    end

    it 'calls audiobook_chapters endpoint' do
      expect(client).to receive(:run).with(:get, '/v1/audiobooks/ab1/chapters', [200], {})
      client.audiobook_chapters('ab1')
    end

    it 'calls chapter endpoint' do
      expect(client).to receive(:run).with(:get, '/v1/chapters/ch1', [200], {})
      client.chapter('ch1')
    end

    it 'calls episode endpoint' do
      expect(client).to receive(:run).with(:get, '/v1/episodes/ep1', [200], {})
      client.episode('ep1')
    end

    it 'calls show endpoint' do
      expect(client).to receive(:run).with(:get, '/v1/shows/sh1', [200], {})
      client.show('sh1')
    end

    it 'calls show_episodes endpoint' do
      expect(client).to receive(:run).with(:get, '/v1/shows/sh1/episodes', [200], {})
      client.show_episodes('sh1')
    end

    it 'calls me_top endpoint' do
      expect(client).to receive(:run).with(:get, '/v1/me/top/artists', [200], { limit: 5 })
      client.me_top('artists', limit: 5)
    end

    it 'raises on invalid me_top type' do
      expect { client.me_top('albums') }.to raise_error(Spotify::ImplementationError)
    end

    it 'calls currently_playing endpoint' do
      expect(client).to receive(:run).with(:get, '/v1/me/player/currently-playing', [200], {})
      client.currently_playing
    end

    it 'calls recently_played endpoint' do
      expect(client).to receive(:run).with(:get, '/v1/me/player/recently-played', [200], {})
      client.recently_played
    end

    it 'calls playback_state endpoint' do
      expect(client).to receive(:run).with(:get, '/v1/me/player', [200], {})
      client.playback_state
    end

    it 'calls available_devices endpoint' do
      expect(client).to receive(:run).with(:get, '/v1/me/player/devices', [200], {})
      client.available_devices
    end

    it 'calls transfer_playback endpoint' do
      expect(client).to receive(:run).with(:put, '/v1/me/player', [200, 204], '{"device_ids":["d1"],"play":true}', false)
      client.transfer_playback(['d1'], true)
    end

    it 'calls start_or_resume_playback endpoint' do
      expect(client).to receive(:run).with(:put, '/v1/me/player/play', [200, 204], '{"context_uri":"spotify:album:a1"}', false)
      client.start_or_resume_playback(context_uri: 'spotify:album:a1')
    end

    it 'calls pause_playback endpoint' do
      expect(client).to receive(:run).with(:put, '/v1/me/player/pause', [200, 204], {}, false)
      client.pause_playback
    end

    it 'calls skip_to_next endpoint' do
      expect(client).to receive(:run).with(:post, '/v1/me/player/next', [200, 204], {}, false)
      client.skip_to_next
    end

    it 'calls skip_to_previous endpoint' do
      expect(client).to receive(:run).with(:post, '/v1/me/player/previous', [200, 204], {}, false)
      client.skip_to_previous
    end

    it 'calls seek_to_position endpoint' do
      expect(client).to receive(:run).with(:put, '/v1/me/player/seek', [200, 204], { position_ms: 12_000 }, false)
      client.seek_to_position(12_000)
    end

    it 'calls set_repeat_mode endpoint' do
      expect(client).to receive(:run).with(:put, '/v1/me/player/repeat', [200, 204], { state: 'context' }, false)
      client.set_repeat_mode('context')
    end

    it 'calls set_playback_volume endpoint' do
      expect(client).to receive(:run).with(:put, '/v1/me/player/volume', [200, 204], { volume_percent: 30 }, false)
      client.set_playback_volume(30)
    end

    it 'calls set_shuffle endpoint' do
      expect(client).to receive(:run).with(:put, '/v1/me/player/shuffle', [200, 204], { state: true }, false)
      client.set_shuffle(true)
    end

    it 'calls playback_queue endpoint' do
      expect(client).to receive(:run).with(:get, '/v1/me/player/queue', [200], {})
      client.playback_queue
    end

    it 'calls add_to_playback_queue endpoint' do
      expect(client).to receive(:run).with(:post, '/v1/me/player/queue', [200, 204], { uri: 'spotify:track:t1' }, false)
      client.add_to_playback_queue('spotify:track:t1')
    end

    it 'calls playlist endpoint' do
      expect(client).to receive(:run).with(:get, '/v1/playlists/p1', [200])
      client.playlist('p1')
    end

    it 'calls playlist_cover_image endpoint' do
      expect(client).to receive(:run).with(:get, '/v1/playlists/p1/images', [200], {})
      client.playlist_cover_image('p1')
    end

    it 'calls upload_playlist_cover_image endpoint' do
      expect(client).to receive(:run).with(:put, '/v1/playlists/p1/images', [200, 202, 204], 'abc', false)
      client.upload_playlist_cover_image('p1', 'abc')
    end

    it 'calls remove_user_tracks_from_playlist endpoint' do
      expect(client).to receive(:run)
        .with(:delete, '/v1/playlists/p1/items', [200], '{"items":[{"uri":"spotify:track:1"}]}')
      client.remove_user_tracks_from_playlist('u1', 'p1', [{ uri: 'spotify:track:1' }])
    end

    it 'calls replace_user_tracks_in_playlist endpoint' do
      expect(client).to receive(:run)
        .with(:put, '/v1/playlists/p1/items', [200, 201], '{"uris":["spotify:track:1"]}')
      client.replace_user_tracks_in_playlist('u1', 'p1', ['spotify:track:1'])
    end

    it 'truncates playlist by replacing with empty list' do
      expect(client).to receive(:replace_user_tracks_in_playlist).with('u1', 'p1', [])
      client.truncate_user_playlist('u1', 'p1')
    end

    it 'calls album endpoint' do
      expect(client).to receive(:run).with(:get, '/v1/albums/a1', [200])
      client.album('a1')
    end

    it 'calls album_tracks endpoint' do
      expect(client).to receive(:run).with(:get, '/v1/albums/a1/tracks', [200])
      client.album_tracks('a1')
    end

    it 'calls albums endpoint with joined ids' do
      expect(client).to receive(:album).with('a1').and_return({ 'id' => 'a1' })
      expect(client).to receive(:album).with('a2').and_return({ 'id' => 'a2' })
      expect(client.albums(%w[a1 a2])).to eq({ 'albums' => [{ 'id' => 'a1' }, { 'id' => 'a2' }] })
    end

    it 'calls track endpoint' do
      expect(client).to receive(:run).with(:get, '/v1/tracks/t1', [200])
      client.track('t1')
    end

    it 'calls tracks endpoint with joined ids' do
      expect(client).to receive(:track).with('t1').and_return({ 'id' => 't1' })
      expect(client).to receive(:track).with('t2').and_return({ 'id' => 't2' })
      expect(client.tracks(%w[t1 t2])).to eq({ 'tracks' => [{ 'id' => 't1' }, { 'id' => 't2' }] })
    end

    it 'calls artist endpoint' do
      expect(client).to receive(:run).with(:get, '/v1/artists/ar1', [200])
      client.artist('ar1')
    end

    it 'calls artists endpoint with joined ids' do
      expect(client).to receive(:artist).with('ar1').and_return({ 'id' => 'ar1' })
      expect(client).to receive(:artist).with('ar2').and_return({ 'id' => 'ar2' })
      expect(client.artists(%w[ar1 ar2])).to eq({ 'artists' => [{ 'id' => 'ar1' }, { 'id' => 'ar2' }] })
    end

    it 'calls artist_albums endpoint' do
      expect(client).to receive(:run).with(:get, '/v1/artists/ar1/albums', [200])
      client.artist_albums('ar1')
    end

    it 'calls artist_top_tracks endpoint with market' do
      expect(client).to receive(:run).with(:get, '/v1/artists/ar1/top-tracks', [200], country: 'IT')
      client.artist_top_tracks('ar1', 'IT')
    end

    it 'calls related_artists endpoint' do
      expect(client).to receive(:run).with(:get, '/v1/artists/ar1/related-artists', [200])
      client.related_artists('ar1')
    end

    it 'calls follow endpoint using library uris payload' do
      expect(client).to receive(:run).with(:put, '/v1/me/library', [200, 204], '{"uris":["spotify:artist:ar1"]}', false)
      client.follow('artist', ['ar1'])
    end

    it 'calls follow_playlist endpoint' do
      expect(client).to receive(:run).with(:put, '/v1/me/library', [200, 204], '{"uris":["spotify:playlist:p1"]}', false)
      client.follow_playlist('u1', 'p1', false)
    end

    it 'raises on invalid search entity' do
      expect { client.search(:podcast, 'term') }.to raise_error(Spotify::ImplementationError)
    end

    it 'supports generic request helper for query params' do
      expect(client).to receive(:run).with(:get, '/v1/me', [200], { market: 'IT' }, true)
      client.request('get', '/v1/me', [200], { market: 'IT' })
    end

    it 'serializes generic request! hash payloads for write verbs' do
      expect(client).to receive(:run!).with(:post, '/v1/custom', [201], '{"foo":"bar"}', false)
      client.request!('post', '/v1/custom', [201], { foo: 'bar' }, false)
    end
  end

  describe 'error mapping' do
    def build_error_client
      described_class.new(access_token: 'token', raise_errors: true)
    end

    it 'maps NotFound to ResourceNotFound' do
      c = build_error_client
      allow(c.instance_variable_get(:@connection)).to receive(:request).and_raise(Excon::Errors::NotFound.new('missing'))
      expect { c.me }.to raise_error(Spotify::ResourceNotFound)
    end

    it 'maps BadRequest to BadRequest' do
      c = build_error_client
      allow(c.instance_variable_get(:@connection)).to receive(:request).and_raise(Excon::Errors::BadRequest.new('bad'))
      expect { c.me }.to raise_error(Spotify::BadRequest)
    end

    it 'maps Forbidden to InsufficientClientScopeError' do
      c = build_error_client
      allow(c.instance_variable_get(:@connection)).to receive(:request).and_raise(Excon::Errors::Forbidden.new('forbidden'))
      expect { c.me }.to raise_error(Spotify::InsufficientClientScopeError)
    end

    it 'maps generic Excon errors to HTTPError' do
      c = build_error_client
      allow(c.instance_variable_get(:@connection)).to receive(:request).and_raise(Excon::Errors::Timeout.new('timeout'))
      expect { c.me }.to raise_error(Spotify::HTTPError)
    end

    it 'maps malformed JSON responses to HTTPError' do
      c = build_error_client
      allow(c.instance_variable_get(:@connection)).to receive(:request).and_return(double(body: '{'))

      expect { c.me }.to raise_error(Spotify::HTTPError)
    end

    it 'returns false when raise_errors is false' do
      c = described_class.new(access_token: 'token', raise_errors: false)
      allow(c.instance_variable_get(:@connection)).to receive(:request).and_raise(Excon::Errors::Unauthorized.new('nope'))
      expect(c.me).to eq(false)
    end
  end

  describe 'development mode restrictions' do
    let(:development_client) { described_class.new(access_token: 'token', raise_errors: true, app_mode: :development) }

    it 'raises for user endpoint' do
      expect { development_client.user('u1') }.to raise_error(Spotify::EndpointUnavailableInDevelopmentMode)
    end

    it 'raises for artist_top_tracks endpoint' do
      expect { development_client.artist_top_tracks('ar1', 'IT') }.to raise_error(Spotify::EndpointUnavailableInDevelopmentMode)
    end
  end
end
