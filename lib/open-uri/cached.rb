require 'open-uri'
require 'digest/sha1'
require 'yaml'

module OpenURI
  class << self
    alias original_open_uri open_uri #:nodoc:
    def open_uri(uri, *rest, &block)
      response = Cache.get(uri.to_s) ||
                 Cache.set(uri.to_s, original_open_uri(uri, *rest))

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
    @cache_path = "/tmp/open-uri-#{Process.uid}"

    class << self
      attr_accessor :cache_path

      ##
      # Retrieve file content and meta data from cache
      # @param [String] key
      # @return [StringIO]
      def get(key)
        filename = filename_from_url(key)
        # TODO: head request to determine last_modified vs file modtime

        # Read metadata, if it exists
        meta = YAML::load(File.read("#{filename}.meta")) if File.exists?("#{filename}.meta")

        f = File.exists?(filename) ? StringIO.new(File.open(filename, "rb") { |f| f.read }) : nil

        # Add meta accessors
        if meta && f
          f.instance_variable_set(:"@meta", meta)

          def f.meta
            @meta
          end
          def f.base_uri
            @meta[:base_uri]
          end
          def f.content_type
            @meta[:content_type]
          end
          def f.charset
            @meta[:charset]
          end
          def f.content_encoding
            @meta[:content_encoding]
          end
          def f.last_modified
            @meta[:last_modified]
          end
          def f.status
            @meta[:status]
          end
        end

        f
      end

      # Cache file content and metadata
      # @param [String] key
      #   URL of content to be cached
      # @param [StringIO] value
      #   value to be cached, typically StringIO returned from `original_open_uri`
      # @return [StringIO]
      #   Returns value
      def set(key, value)
        filename = filename_from_url(key)
        mkpath(filename)

        # Save metadata in a parallel file
        if value.respond_to?(:meta)
          filename_meta = "#{filename}.meta"
          meta = value.meta
          meta[:status] = value.status if value.respond_to?(:status)
          meta[:content_type] = value.content_type if value.respond_to?(:content_type)
          meta[:base_uri] = value.base_uri if value.respond_to?(:base_uri)
          File.open(filename_meta, 'wb') {|f| YAML::dump(meta, f)}
        end

        # Save file contents
        File.open(filename, 'wb'){|f| f.write value.read }
        value.rewind
        value
      end

      # Invalidate cache for a key, optionally if older than time givan
      # @param [String] key
      #   URL of content to be invalidated
      # @param [Time] time
      #   (optional): the maximum age at which the cached value is still acceptable
      # @return
      #   Returns 1 if a cached value was invalidated, false otherwise
      def invalidate(key, time = Time.now)
        filename = filename_from_url(key)
        File.delete(filename) if File.stat(filename).mtime < time
      rescue Errno::ENOENT
        false
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
