# frozen_string_literal: true

require 'spec_helper'

describe 'OpenURI::Cache' do
  before do
    require 'open-uri/cached'
    OpenURI::Cache.cache_path = File.expand_path('../../tmp', __dir__)
  end

  after do
    OpenURI::Cache.invalidate_all!
  end

  context 'initial request' do
    subject { URI.open('https://rubygems.org/') }

    it 'reads the content once' do
      subject
      expect(a_request(:get, 'https://rubygems.org/')).to have_been_made.once
    end

    it 'returns correct metadata on intial request' do
      expect(subject.meta[:base_uri]).to be_kind_of(URI::HTTPS)
      expect(subject.meta[:base_uri].host).to eq('rubygems.org')
    end
  end

  context 'on cached request' do
    subject do
      URI.open('https://rubygems.org/')
      URI.open('https://rubygems.org/')
    end

    it 'only reads the content once' do
      subject
      URI.open('https://rubygems.org/')
      expect(a_request(:get, 'https://rubygems.org/')).to have_been_made.once
    end

    it 'returns correct metadata on intial request' do
      expect(subject.meta[:base_uri]).to be_kind_of(URI::HTTPS)
      expect(subject.meta[:base_uri].host).to eq('rubygems.org')
    end

    it 'invalidates cache correctly' do
      subject
      OpenURI::Cache.invalidate('https://rubygems.org/')
      URI.open('https://rubygems.org/')
      expect(a_request(:get, 'https://rubygems.org/')).to have_been_made.times(2)
    end
  end
end

describe 'OpenURI' do
  before do
    # Force removal of our library so we can test stock behaviour
    $LOADED_FEATURES.reject! { |x| x =~ /open-uri/ }
    require 'open-uri'
  end

  it 'reads the content twice' do
    URI.open('https://rubygems.org/')
    URI.open('https://rubygems.org/')
    expect(a_request(:get, 'https://rubygems.org/')).to have_been_made.times(2)
  end
end
