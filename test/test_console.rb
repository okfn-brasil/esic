require 'helper'

class TestConsole < Test::Unit::TestCase
  should 'login successfully when called with valid credentials' do
    assert_nothing_raised ESIC::LoginFailedException do
      ESIC::Crawler.new('vitorbaptista', 'the-real-password')
    end
  end

  should 'fails login when called with invalid credentials' do
    assert_raise ESIC::LoginFailedException do
      ESIC::Crawler.new('vitorbaptista', 'wrong-password')
    end
  end
end
