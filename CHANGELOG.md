# Changelog

# 1.0.0

* Add support for ruby 3.1 and above
* Add `OpenURI::Cache.invalidate_all!` for easily invalidating the entire cache

# 0.0.5

* Add `OpenURI::Cache.invalidate(url)` for invalidating a specific URL from the cache
* Add ability to configure the cache path via `OpenURI::Cache.cache_path=(path)`
* Suffix default cache path with `Process.uid` to avoid collisions in shared environments

# 0.0.4

* Fix caching of URLs that return binary content

# 0.0.3

* Add caching of more than just the content (e.g. status codes, content types etc)

# 0.0.1

* Initial release
