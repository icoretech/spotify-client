#--
# Copyright (c) 2009-2014 iCoreTech, Inc.
#
# This file is part of the AudioBox.fm project.
#++

# Author::    Claudio Poli (mailto:claudio@icorete.ch)
# Copyright:: Copyright (c) 2009-2014 iCoreTech, Inc.
# License::   iCoreTech, Inc. Private License

module RequestFixturesHelper
  def request_fixture(name)
    File.read("spec/fixtures/#{name}.json")
  end
end
