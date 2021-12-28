require_relative 'spec_helper'

describe 'OpenURI.open_uri' do
  before do
    OpenURI::Cache.cache_path = cache_dir
    FileUtils.rm_r OpenURI::Cache.cache_path, force: true, secure: true
  end

  it 'should cache calls to OpenURI.open_uri for binary file' do
    actual = with_local_webserver do |base_url, thr|
      url = %(#{base_url}/square.png)
      expect(OpenURI::Cache.get url).to be_nil
      contents = OpenURI.open_uri(url) {|fd| fd.read }
      expect(OpenURI.open_uri(url) {|fd| fd.read }).to eql contents
      expect(thr[:requests].length).to eql 1
      contents
    end
    expected = File.read(fixture_file('square.png'), mode: 'rb')
    expect(actual).to eql expected
  end

  it 'should cache calls to OpenURI.open_uri for text file' do
    actual = with_local_webserver do |base_url, thr|
      url = %(#{base_url}/square.svg)
      expect(OpenURI::Cache.get url).to be_nil
      contents = OpenURI.open_uri(url) {|fd| fd.read }
      expect(OpenURI.open_uri(url) {|fd| fd.read }).to eql contents
      expect(thr[:requests].length).to eql 1
      contents
    end
    expected = File.read(fixture_file('square.svg'), mode: 'rb')
    expect(actual).to eql expected
  end

  it 'should allow cached URL to be invalidated immediately' do
    actual = with_local_webserver do |base_url, thr|
      url = %(#{base_url}/square.png)
      contents = OpenURI.open_uri(url) {|fd| fd.read }
      OpenURI::Cache.invalidate url
      expect(OpenURI.open_uri(url) {|fd| fd.read }).to eql contents
      expect(thr[:requests].length).to eql 2
      contents
    end
    expected = File.read(fixture_file('square.png'), mode: 'rb')
    expect(actual).to eql expected
  end
end
