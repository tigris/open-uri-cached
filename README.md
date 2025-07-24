# OpenURI with caching

Carelessly make OpenURI requests without getting hate mail.

## Usage

Require the library

```ruby
    require 'open-uri/cached'
    open('http://www.someone-that-hates-being-scraped.com').read
```

## Configuring

If you're not super pumped about reading files from `/tmp`, you can configure the cache path:

```ruby
  OpenURI::Cache.cache_path = '/tmp/open-uri'
```

## Invalidating

They say cache invalidation is hard, but not really:

```ruby
  # Invalidate a single URL
  OpenURI::Cache.invalidate('https://example.com/')

  # Invalidate everything
  OpenURI::Cache.invalidate_all!
```
