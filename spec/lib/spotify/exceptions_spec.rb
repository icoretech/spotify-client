require 'open3'

describe 'Spotify exceptions' do
  it "loads the public gem entrypoint through Ruby's require path" do
    lib_dir = File.expand_path('../../../lib', __dir__)
    command = [
      RbConfig.ruby,
      '-I', lib_dir,
      '-e', "require 'spotify-client'; abort('missing client') unless defined?(Spotify::Client)"
    ]

    stdout, stderr, status = Open3.capture3(*command)

    expect(status.success?).to eq(true), "stdout: #{stdout}\nstderr: #{stderr}"
  end

  it 'loads the underscore entrypoint shim without changing the public client constant' do
    expect { load File.expand_path('../../../lib/spotify_client.rb', __dir__) }.not_to raise_error
    expect(Spotify::Client).to be_a(Class)
  end

  it 'keeps implementation-level exceptions separate from API/runtime errors' do
    expect(Spotify::ImplementationError.superclass).to eq(StandardError)
    expect(Spotify::EndpointUnavailableInDevelopmentMode.superclass).to eq(Spotify::ImplementationError)
    expect(Spotify::Error.superclass).to eq(StandardError)
  end

  it 'maps API-facing errors under Spotify::Error' do
    expect(Spotify::AuthenticationError.superclass).to eq(Spotify::Error)
    expect(Spotify::HTTPError.superclass).to eq(Spotify::Error)
    expect(Spotify::InsufficientClientScopeError.superclass).to eq(Spotify::Error)
    expect(Spotify::BadRequest.superclass).to eq(Spotify::Error)
    expect(Spotify::ResourceNotFound.superclass).to eq(Spotify::Error)
  end
end
