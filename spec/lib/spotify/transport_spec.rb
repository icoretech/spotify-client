# frozen_string_literal: true

require 'socket'
require 'timeout'

describe Spotify::Client, 'HTTP transport' do
  let(:client) { described_class.new(access_token: 'sample-token', read_timeout: 2, write_timeout: 2) }

  around do |example|
    defaults = Excon.defaults.dup
    Excon.defaults.merge!(mock: false, disable_proxy: true)
    @server = TCPServer.new('127.0.0.1', 0)
    example.run
  ensure
    @server_thread&.kill&.join
    @server&.close
    Excon.defaults.replace(defaults)
  end

  before do
    stub_const('Spotify::Client::BASE_URI', "http://127.0.0.1:#{@server.addr[1]}")
  end

  after do
    client.close_connection
  end

  def serve_response(status:, body:, headers: {})
    response_headers = headers.map { |name, value| "#{name}: #{value}\r\n" }.join
    @server_thread = Thread.new do
      Thread.current.report_on_exception = false
      Timeout.timeout(5) do
        socket = @server.accept
        method, target = socket.gets("\r\n").split
        headers = {}
        while (line = socket.gets("\r\n")) != "\r\n"
          name, value = line.split(':', 2)
          headers[name.downcase] = value.strip
        end
        request_body = socket.read(Integer(headers.fetch('content-length', '0')))
        socket.write("HTTP/1.1 #{status}\r\nContent-Type: application/json\r\n" \
                     "Content-Length: #{body.bytesize}\r\n#{response_headers}Connection: close\r\n\r\n#{body}")
        { method: method, target: target, headers: headers, body: request_body }
      ensure
        socket&.close
      end
    end
  end

  it 'encodes query parameters and sends authentication and user agent headers over HTTP' do
    server = serve_response(status: '200 OK', body: '{"items":[]}')

    result = client.request!(:get, '/v1/search', [200], q: 'sample artist', limit: 2)

    request = server.value
    expect(result).to eq('items' => [])
    expect(request[:method]).to eq('GET')
    uri = URI.parse(request[:target])
    expect(uri.path).to eq('/v1/search')
    expect(URI.decode_www_form(uri.query).to_h).to eq('q' => 'sample artist', 'limit' => '2')
    expect(request[:headers]).to include('authorization' => 'Bearer sample-token',
                                         'user-agent' => "spotify-client/#{Spotify::VERSION} (Ruby)")
  end

  it 'sends hash payloads as JSON bodies over HTTP' do
    server = serve_response(status: '201 Created', body: '{"id":"sample-playlist"}')

    result = client.request!(:post, '/v1/me/playlists', [201], { name: 'sample playlist', public: false }, false)

    request = server.value
    expect(result).to eq('id' => 'sample-playlist')
    expect(request).to include(method: 'POST', target: '/v1/me/playlists')
    expect(request[:headers]['content-type']).to eq('application/json')
    expect(JSON.parse(request[:body])).to eq('name' => 'sample playlist', 'public' => false)
  end

  it 'maps a real unauthorized HTTP response to an authentication error' do
    server = serve_response(status: '401 Unauthorized', body: '{"error":{"status":401}}')

    expect { client.request!(:get, '/v1/me') }.to raise_error(Spotify::AuthenticationError)

    server.value
  end

  it 'exposes the quota reason and retry header from a real HTTP 429 response' do
    server = serve_response(status: '429 Too Many Requests',
                            body: '{"error":{"status":429,"message":"Too many requests","reason":"QUOTA_EXCEEDED"}}',
                            headers: { 'retry-after' => '120' })

    expect { client.request!(:get, '/v1/me') }.to raise_error(Spotify::HTTPError) { |error|
      expect(error).to be_a(Spotify::RateLimitError)
      expect(error.reason).to eq('QUOTA_EXCEEDED')
      expect(error.retry_after).to eq('120')
    }

    server.value
  end

  {
    'ordinary rate limit' => '{"error":{"status":429,"message":"Too many requests"}}',
    'malformed body' => '<html>Too many requests</html>',
    'empty body' => '',
    'unexpected JSON shape' => '{"error":"Too many requests"}'
  }.each do |description, body|
    it "preserves the rate limit error for a response with #{description}" do
      server = serve_response(status: '429 Too Many Requests', body: body)

      expect { client.request!(:get, '/v1/me') }.to raise_error(Spotify::RateLimitError) { |error|
        expect(error.reason).to be_nil
        expect(error.retry_after).to be_nil
      }

      server.value
    end
  end

  it 'returns false for a nonbang request when the server rate limits it' do
    server = serve_response(status: '429 Too Many Requests', body: '{"error":{"reason":"QUOTA_EXCEEDED"}}')

    expect(client.me).to eq(false)

    server.value
  end

  it 'sends playlist cover images with their media type over HTTP' do
    server = serve_response(status: '202 Accepted', body: '')

    expect(client.upload_playlist_cover_image('sample-playlist', 'c2FtcGxlLWltYWdl')).to eq({})

    request = server.value
    expect(request).to include(method: 'PUT', target: '/v1/playlists/sample-playlist/images', body: 'c2FtcGxlLWltYWdl')
    expect(request[:headers]).to include('content-type' => 'image/jpeg', 'authorization' => 'Bearer sample-token')
  end
end
