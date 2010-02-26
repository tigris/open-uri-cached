require 'open-uri'
require 'digest/sha1'

module OpenURI
  class << self
    alias original_open_uri open_uri #:nodoc:
    def open_uri(uri, *rest, &block)
      response = Cache.get(uri.to_s)

      unless response
        response = original_open_uri(uri, *rest).read
        Cache.set(uri.to_s, response)
      end

      response = StringIO.new(response)

      if block_given?
        begin
          yield response
        ensure
          response.close
        end
      else
        response
      end
    end
  end

  class Cache
    @cache_path = '/tmp/open-uri'

    class << self
      def get(key)
        filename = filename_from_url(key)
        # TODO: head request to determine last_modified vs file modtime
        File.exists?(filename) ? File.read(filename) : nil
      end

      def set(key, value)
        filename = filename_from_url(key)
        mkpath(filename)
        File.open(filename, 'w'){|f| f.write value }
      end

      protected
        def filename_from_url(url)
          uri = URI.parse(url) # TODO: rescue here?
          [ @cache_path, uri.host, Digest::SHA1.hexdigest(url) ].join('/')
        end

        def mkpath(path)
          full = []
          dirs = path.split('/'); dirs.pop
          dirs.each do |dir|
            full.push(dir)
            dir = full.join('/')
            next if dir.to_s == ''
            Dir.mkdir(dir) unless File.exists?(dir)
          end
        end
    end
  end
end
