# frozen_string_literal: true

$LOAD_PATH << File.expand_path('../lib', __dir__)

# We'll be messing with loaded libraries a lot, so need to suppress the warnings
# about re-initializing constants
$VERBOSE = nil

require 'open-uri/cached'
require 'fileutils' unless defined? FileUtils
require 'socket'
require 'webmock/rspec'

RSpec.configure do |config|
  config.order = :random
  Kernel.srand config.seed
  
  config.before(:each) do
    WebMock.disable_net_connect!

    stub_request(:get, 'https://rubygems.org/').to_return(
      status: 200,
      body: File.read(File.expand_path('support/fixtures/rubygems.org.html', __dir__)),
      headers: {}
    )
  end
  
  config.before :suite do
    FileUtils.rm_r cache_dir, force: true, secure: true
  end

  config.after :suite do
    FileUtils.rm_r cache_dir, force: true, secure: true
  end

  def cache_dir
    File.join __dir__, 'cache'
  end

  def fixtures_dir
    File.join __dir__, 'fixtures'
  end

  def fixture_file path
    File.join fixtures_dir, path
  end

  def with_local_webserver host = resolve_localhost, port = 9876
    base_dir = fixtures_dir
    server = TCPServer.new host, port
    server_thread = Thread.start do
      Thread.current[:requests] = requests = []
      while (session = server.accept)
        requests << (request = session.gets)
        if %r/^GET (\S+) HTTP\/1\.1$/ =~ request.chomp
          resource = (resource = $1) == '' ? '.' : resource
        else
          session.print %(HTTP/1.1 405 Method Not Allowed\r\nContent-Type: text/plain\r\n\r\n)
          session.print %(405 - Method not allowed\r\n)
          session.close
          next
        end
        resource, _query = resource.split '?', 2 if resource.include? '?'
        if File.file? (resource_file = (File.join base_dir, resource))
          if (ext = (File.extname resource_file)[1..-1])
            mimetype = %(image/#{ext})
          else
            mimetype = 'text/plain'
          end
          session.print %(HTTP/1.1 200 OK\r\nContent-Type: #{mimetype}\r\n\r\n)
          File.open resource_file, 'rb:utf-8:utf-8' do |fd|
            session.write fd.read 256 until fd.eof?
          end
        else
          session.print %(HTTP/1.1 404 Not Found\r\nContent-Type: text/plain\r\n\r\n)
          session.print %(404 - Resource not found.\r\n)
        end
        session.close
      end
    end
    begin
      yield %(http://#{host}:#{port}), server_thread
    ensure
      server_thread.exit
      server_thread.value
      server.close
    end
  end

  def resolve_localhost
    Socket.ip_address_list.find(&:ipv4?).ip_address
  end
end
