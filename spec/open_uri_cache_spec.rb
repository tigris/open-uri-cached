require_relative 'spec_helper'

describe 'OpenURI::Cache' do
  subject { OpenURI::Cache }

  it 'should set cache_path to folder in /tmp scoped to uid' do
    expect(subject.cache_path).to eql %(/tmp/open-uri-#{Process.uid})
  end

  it 'should allow cache_path to be changed' do
    old_cache_path = subject.cache_path
    subject.cache_path = '/tmp/open-uri'
    expect(subject.cache_path).to eql '/tmp/open-uri'
  ensure
    subject.cache_path = old_cache_path
  end
end
