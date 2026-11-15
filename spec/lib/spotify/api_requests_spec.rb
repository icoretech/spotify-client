# frozen_string_literal: true

describe Spotify::Client, 'Spotify request contracts' do
  let(:client) { described_class.new(access_token: 'sample-token', raise_errors: true) }

  it 'uses the market query parameter for artist top tracks' do
    Excon.stub(
      { method: :get, path: '/v1/artists/sample-artist/top-tracks', query: { market: 'ES' } },
      { status: 200, body: '{"tracks":[]}' }
    )

    expect(client.artist_top_tracks('sample-artist', 'ES')).to eq('tracks' => [])
  end

  it 'adds playlist items as a JSON array with the requested insertion position' do
    uris = ['spotify:track:sample-track', 'spotify:episode:sample-episode']
    Excon.stub(
      { method: :post, path: '/v1/playlists/sample-playlist/items', body: JSON.dump(uris: uris, position: 0) },
      { status: 201, body: '{"snapshot_id":"sample-snapshot"}' }
    )

    expect(client.add_user_tracks_to_playlist(nil, 'sample-playlist', uris, 0)).to eq('snapshot_id' => 'sample-snapshot')
  end

  it 'accepts all 100 playlist items without dropping the last item' do
    uris = Array.new(100) { |index| "spotify:track:sample-#{index}" }
    Excon.stub(
      { method: :post, path: '/v1/playlists/sample-playlist/items', body: JSON.dump(uris: uris) },
      { status: 201, body: '{"snapshot_id":"sample-snapshot"}' }
    )

    expect(client.add_user_tracks_to_playlist(nil, 'sample-playlist', uris)).to eq('snapshot_id' => 'sample-snapshot')
  end

  it 'rejects more than 100 playlist items before sending a request' do
    uris = Array.new(101) { |index| "spotify:track:sample-#{index}" }

    expect { client.add_user_tracks_to_playlist(nil, 'sample-playlist', uris) }.to raise_error(Spotify::ImplementationError)
  end

  it 'returns an empty object when playback state has no active player' do
    Excon.stub({ method: :get, path: '/v1/me/player' }, { status: 204, body: '' })

    expect(client.playback_state).to eq({})
  end

  { add_to_library: :put, remove_from_library: :delete }.each do |method, verb|
    it "sends all 40 library URIs as query parameters for #{method}" do
      uris = Array.new(40) { |index| "spotify:track:sample-#{index}" }
      Excon.stub(
        { method: verb, path: '/v1/me/library', query: { uris: uris.join(',') }, body: nil },
        { status: 200, body: '' }
      )

      expect(client.public_send(method, uris)).to eq({})
    end

    it "rejects more than 40 library URIs before sending a request for #{method}" do
      uris = Array.new(41) { |index| "spotify:track:sample-#{index}" }

      expect { client.public_send(method, uris) }.to raise_error(Spotify::ImplementationError)
    end
  end

  it 'rejects related artist lookups when the restricted development contract is selected' do
    development_client = described_class.new(app_mode: :development)

    expect { development_client.related_artists('sample-artist') }.to raise_error(Spotify::EndpointUnavailableInDevelopmentMode)
  end

  [
    [:album, ['sample-album'], '/v1/albums/sample-album', { 'external_ids' => { 'upc' => '000000000000' } }],
    [:track, ['sample-track'], '/v1/tracks/sample-track', { 'external_ids' => { 'isrc' => 'XXAAA0000000' } }],
    [:me, [], '/v1/me', { 'id' => 'sample-user', 'account_id' => 'sample-stable-account' }]
  ].each do |method, arguments, path, payload|
    it "preserves current Spotify response fields from #{method}" do
      Excon.stub({ method: :get, path: path }, { status: 200, body: JSON.dump(payload) })

      expect(client.public_send(method, *arguments)).to eq(payload)
    end
  end
end
