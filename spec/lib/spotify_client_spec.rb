describe Spotify::Client do
  let(:authenticated_client) { described_class.new(access_token: 'test', raise_errors: true) }
  let(:anonymous_client) { described_class.new(raise_errors: true) }

  describe "BASE_URI" do
    it "should have correct value" do
      expect(Spotify::Client::BASE_URI).to eq('https://api.spotify.com')
    end
  end

  describe ".me" do
    let(:fixture) { request_fixture('me') }

    it "should raise error as authenticated client" do
      Excon.stub({ :method => :get, :path => '/v1/me', :headers => { 'Authorization' => "Bearer test" } }, { :status => 401 })
      expect {authenticated_client.me}.to raise_error(Spotify::AuthenticationError)
    end
    it "should raise error as anonymous client" do
      Excon.stub({ :method => :get, :path => '/v1/me' }, { :status => 401 })
      expect {anonymous_client.me}.to raise_error(Spotify::AuthenticationError)
    end
    it "should get response" do
      Excon.stub({ :method => :get, :path => '/v1/me', :headers => { 'Authorization' => "Bearer test" } }, { :status => 200, :body => fixture })
      response = authenticated_client.me
      expect(response.keys.count).to eq(8)
      expect(response['id']).to eq('some_random_user')
      expect(response['display_name']).to eq('Some Random User')
    end
  end

  describe ".me_tracks" do
    let(:fixture) { request_fixture('me_tracks') }

    it "should raise error as authenticated client" do
      Excon.stub({ :method => :get, :path => '/v1/me/tracks', :headers => { 'Authorization' => "Bearer test" } }, { :status => 401 })
      expect {authenticated_client.me_tracks}.to raise_error(Spotify::AuthenticationError)
    end
    it "should raise error as anonymous client" do
      Excon.stub({ :method => :get, :path => '/v1/me/tracks' }, { :status => 401 })
      expect {anonymous_client.me_tracks}.to raise_error(Spotify::AuthenticationError)
    end
    it "should get response" do
      Excon.stub({ :method => :get, :path => '/v1/me/tracks', :headers => { 'Authorization' => "Bearer test" } }, { :status => 200, :body => fixture })
      response = authenticated_client.me_tracks

      expect(response.keys.count).to eq(7)
      expect(response['href']).to match(/http/)
      expect(response['total']).to be_a(Integer)
      expect(response['items']).to be_a(Array)
    end
  end

  describe ".me_following" do
    let(:fixture) { request_fixture('me_following') }

    it "should rails error as authenticated client" do
      Excon.stub({ :method => :get, :path => '/v1/me/following', :headers => { 'Authorization' => "Bearer test" } }, { :status => 401 })
      expect {authenticated_client.me_following}.to raise_error(Spotify::AuthenticationError)
    end
    it "should raise error as anonymous client" do
      Excon.stub({ :method => :get, :path => '/v1/me/following' }, { :status => 401 })
      expect {anonymous_client.me_following}.to raise_error(Spotify::AuthenticationError)
    end
    it "should get response" do
      Excon.stub({ :method => :get, :path => '/v1/me/following', :headers => { 'Authorization' => "Bearer test" } }, { :status => 200, :body => fixture })
      response = authenticated_client.me_following

      expect(response['artists']).to be_a(Hash)
      expect(response['artists'].keys.count).to eq(5)
      expect(response['artists']['items']).to be_a(Array)
      expect(response['artists']['total']).to be_a(Integer)
      expect(response['artists']['limit']).to eq(20)
      expect(response['artists']).to have_key('next')
      expect(response['artists']['cursors']).to be_a(Hash)
      expect(response['artists']['cursors']).to have_key("after")
    end
  end

  describe ".user" do
    let(:fixture) { request_fixture('user') }

    it "should raise error as authenticated client" do
      Excon.stub({ :method => :get, :path => "/v1/users/masterkain", :headers => { 'Authorization' => "Bearer test" } }, { :status => 401 })
      expect {authenticated_client.user('masterkain')}.to raise_error(Spotify::AuthenticationError)
    end
    it "should raise error as anonymous client" do
      Excon.stub({ :method => :get, :path => "/v1/users/masterkain" }, { :status => 401 })
      expect {anonymous_client.user('masterkain')}.to raise_error(Spotify::AuthenticationError)
    end
    it "should get response" do
      Excon.stub({ :method => :get, :path => "/v1/users/masterkain", :headers => { 'Authorization' => "Bearer test" } }, { :status => 200, :body => fixture })
      response = authenticated_client.user('masterkain')
      expect(response.keys.count).to eq(5)
      expect(response['id']).to eq('masterkain')
      expect(response['type']).to eq('user')
    end
  end

  describe ".user_playlists" do
    let(:fixture) { request_fixture('user_playlists') }

    it "should raise error as authenticated client" do
      Excon.stub({ :method => :get, :path => "/v1/me/playlists", :headers => { 'Authorization' => "Bearer test" } }, { :status => 401 })
      expect {authenticated_client.user_playlists('masterkain')}.to raise_error(Spotify::AuthenticationError)
    end
    it "should raise error as anonymous client" do
      Excon.stub({ :method => :get, :path => "/v1/me/playlists" }, { :status => 401 })
      expect {anonymous_client.user_playlists('masterkain')}.to raise_error(Spotify::AuthenticationError)
    end
    it "should get response" do
      Excon.stub({ :method => :get, :path => "/v1/me/playlists", :headers => { 'Authorization' => "Bearer test" } }, { :status => 200, :body => fixture })
      response = authenticated_client.user_playlists('masterkain')
      expect(response.keys.count).to eq(3)
      expect(response['href']).to match(/http/)
      expect(response['total']).to be_a(Integer)
      expect(response['items']).to be_a(Array)
    end
  end

  describe ".user_playlist_tracks" do
    let(:fixture) { request_fixture('user_playlist_tracks') }
    let(:next_fixture) { request_fixture('user_playlist_tracks_next') }

    it "should raise error as authenticated client" do
      Excon.stub({ :method => :get, :path => "/v1/playlists/my/items", :headers => { 'Authorization' => "Bearer test" } }, { :status => 401 })
      expect {authenticated_client.user_playlist_tracks('masterkain', 'my')}.to raise_error(Spotify::AuthenticationError)
    end
    it "should raise error as anonymous client" do
      Excon.stub({ :method => :get, :path => "/v1/playlists/my/items" }, { :status => 401 })
      expect {anonymous_client.user_playlist_tracks('masterkain', 'my')}.to raise_error(Spotify::AuthenticationError)
    end
    it "should get response" do
      Excon.stub({ :method => :get, :path => "/v1/playlists/my/items", :headers => { 'Authorization' => "Bearer test" } }, { :status => 200, :body => fixture })
      Excon.stub({ :method => :get, :path => "/v1/playlists/6Df19VKaShrdWrAnHinwVO/items?offset=1&limit=1", :headers => { 'Authorization' => "Bearer test" } }, { :status => 200, :body => next_fixture })
      response = authenticated_client.user_playlist_tracks('masterkain', 'my')
      expect(response.keys.count).to eq(7)
      expect(response['items']).to be_a(Array)
      expect(response['items'].count).to eq(2)
    end

    it "returns false when the client is configured for non-raising errors" do
      tolerant_client = described_class.new(access_token: 'test', raise_errors: false)

      Excon.stub(
        { :method => :get, :path => "/v1/playlists/my/items", :headers => { 'Authorization' => "Bearer test" } },
        { :status => 401 }
      )

      expect(tolerant_client.user_playlist_tracks('masterkain', 'my')).to eq(false)
    end
  end

  describe ".create_user_playlist" do
    let(:fixture) { request_fixture('create_user_playlist') }

    it "should raise error as authenticated client" do
      Excon.stub({ :method => :post, :path => "/v1/me/playlists", :headers => { 'Authorization' => "Bearer test" } }, { :status => 401 })
      expect {authenticated_client.create_user_playlist('masterkain', 'my')}.to raise_error(Spotify::AuthenticationError)
    end
    it "should raise error as anonymous client" do
      Excon.stub({ :method => :post, :path => "/v1/me/playlists" }, { :status => 401 })
      expect {anonymous_client.create_user_playlist('masterkain', 'my')}.to raise_error(Spotify::AuthenticationError)
    end
    it "should get response" do
      Excon.stub({ :method => :post, :path => "/v1/me/playlists", :headers => { 'Authorization' => "Bearer test" } }, { :status => 201, :body => fixture })
      response = authenticated_client.create_user_playlist('masterkain', 'my')
      expect(response.keys.count).to eq(13)
      # expect(response['tracks']).to be_a(Array)
    end
  end

  describe ".user_playlist" do
    let(:fixture) { request_fixture('playlist') }

    it "should use the modern playlist endpoint" do
      Excon.stub({ :method => :get, :path => "/v1/playlists/my", :headers => { 'Authorization' => "Bearer test" } }, { :status => 200, :body => fixture })
      response = authenticated_client.user_playlist("masterkain", "my")
      expect(response['id']).to eq("4vHIKV7j4QcZwgzGQcZg1x")
    end
  end

  describe ".add_user_tracks_to_playlist" do
    let(:fixture) { '{"snapshot_id":"snapshot"}' }

    it "should use the modern add-items endpoint" do
      Excon.stub({ :method => :post, :path => "/v1/playlists/my/items", :headers => { 'Authorization' => "Bearer test" } }, { :status => 201, :body => fixture })
      response = authenticated_client.add_user_tracks_to_playlist("masterkain", "my", ["spotify:track:4iV5W9uYEdYUVa79Axb7Rh"])
      expect(response['snapshot_id']).to eq("snapshot")
    end
  end

  describe ".follow" do
    it "should return empty hash for no-content responses" do
      Excon.stub({ :method => :put, :path => "/v1/me/library", :headers => { 'Authorization' => "Bearer test" } }, { :status => 204, :body => '' })
      expect(authenticated_client.follow('artist', ['0BvkDsjIUla7X0k6CSWh1I'])).to eq({})
    end
  end

  describe ".search" do
    it "should cap limit at 10" do
      expect(authenticated_client).to receive(:run).with(any_args, hash_including(q: "bob", limit: 10))
      authenticated_client.search(:artist, "bob", limit: 99)
    end

    it "should pass additional options as search parameters" do
      Excon.stub({ :method => :get, :path => "/v1/search" }, { :status => 200 })
      expect(authenticated_client).to receive(:run).with(any_args, hash_including(q: "bob", limit: 5))
      authenticated_client.search(:artist, "bob", limit: 5)
    end
  end
end
