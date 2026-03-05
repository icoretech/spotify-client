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

    it 'supports generic request helper' do
      expect(client).to receive(:run).with(:get, '/v1/me', [200], {}, true)
      client.request('get', '/v1/me')
    end

    it 'supports generic request! helper' do
      expect(client).to receive(:run!).with(:post, '/v1/custom', [201], { foo: 'bar' }, false)
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
