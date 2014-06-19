module RequestFixturesHelper
  def request_fixture(name)
    File.read("spec/fixtures/#{name}.json")
  end
end
