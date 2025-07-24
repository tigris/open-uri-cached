# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = 'open-uri-cached'
  s.version = '2.0.0'
  s.email = 'danial.pearce@gmail.com'
  s.homepage = 'https://github.com/tigris/open-uri-cached'
  s.description = 'OpenURI with transparent disk caching'
  s.authors = ['Danial Pearce']
  s.summary = %Q(Do a lot of site scraping but take lots of attempts at parsing the content before reaching your end result? This gem is for you. But wait, there's more... Ok, no there isn't.)
  s.files = %w(README.md LICENSE lib/open-uri/cached.rb)

  s.add_development_dependency 'rspec', '~> 3.10'
  s.add_development_dependency 'webmock', '~> 3.14'
end
