require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'
require 'vcr'

USERNAME = ENV['ESIC_USERNAME']
PASSWORD = ENV['ESIC_PASSWORD']

VCR.configure do |c|
  c.cassette_library_dir = 'test/vcr_cassettes'
  c.hook_into :webmock
  c.filter_sensitive_data('<USERNAME>') { USERNAME }
  c.filter_sensitive_data('<PASSWORD>') { PASSWORD }
  c.filter_sensitive_data('<AUTH_COOKIE>') do |interaction|
    cookies = interaction.request.headers['Cookie'] || []
    set_cookies = interaction.response.headers['Set-Cookie'] || []
    auth_cookie = (cookies + set_cookies).find { |cookie| cookie =~ /AcbrasilFormsAuthCookie/ }
    auth_cookie[/AcbrasilFormsAuthCookie=([^ ;]*)/, 1] if auth_cookie
  end
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'esic'

class Test::Unit::TestCase
end
