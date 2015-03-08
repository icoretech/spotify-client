require './lib/spotify/playlist'

describe Spotify::Playlist do
  let(:client) { double(:client, me: { 'id' => 123 }) }

  describe '#initialize' do
    let(:fixture) { request_fixture('playlist') }

    it "returns value of valid attribute" do
      data = JSON.parse(fixture)
      playlist = Spotify::Playlist.new(client, data)
      expect(playlist.collaborative).to eq data["collaborative"]
      expect(playlist.public).to eq data["public"]
      expect(playlist.name).to eq data["name"]
    end

    it "raises an error on invalid field" do
      playlist = Spotify::Playlist.new(client, xxx: 'xxx')
      expect(playlist.respond_to?(:xxx)).to eq false
    end
  end

  describe ".create" do
    let(:fixture) { request_fixture('playlist') }

    before do
      allow(client).to receive(:run).and_return JSON.parse(fixture)
    end

    subject { Spotify::Playlist.create(client, 'Mola test') }
    it "returns playlist instance" do
      expect(subject).to be_instance_of(Spotify::Playlist)
    end
  end
end
