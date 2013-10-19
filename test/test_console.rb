require 'helper'

class TestConsole < Test::Unit::TestCase
  should 'login successfully when called with valid credentials' do
    VCR.use_cassette('console_login_successful') do
      assert_nothing_raised ESIC::LoginFailedException do
        ESIC::Crawler.new('vitorbaptista', 'correct-password')
      end
    end
  end

  should 'fails login when called with invalid credentials' do
    VCR.use_cassette('console_login_failure') do
      assert_raise ESIC::LoginFailedException do
        ESIC::Crawler.new('vitorbaptista', 'wrong-password')
      end
    end
  end
end
