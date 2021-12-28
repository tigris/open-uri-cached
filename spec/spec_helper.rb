# frozen_string_literal: true

$LOAD_PATH << File.expand_path('../lib', __dir__)

# We'll be messing with loaded libraries a lot, so need to suppress the warnings
# about re-initializing constants
$VERBOSE = nil

require 'webmock/rspec'

RSpec.configure do |config|
  config.order = :random
  Kernel.srand config.seed

  config.before do
    WebMock.disable_net_connect!

    stub_request(:get, 'https://rubygems.org/').to_return(
      status: 200,
      body: File.read(File.expand_path('support/fixtures/rubygems.org.html', __dir__)),
      headers: {}
    )
  end
end

