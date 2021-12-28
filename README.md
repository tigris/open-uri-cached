# OpenURI with caching

Carelessly make OpenURI requests without getting hate mail.

## Usage

Require the library

    require 'open-uri/cached'
    open('http://www.someone-that-hates-being-scraped.com').read

## Configuring

OpenURI::Cache.cache_path = '/tmp/open-uri'
