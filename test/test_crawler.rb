require 'helper'

class TestCrawler < Test::Unit::TestCase
  context 'valid credentials' do
    setup { VCR.insert_cassette('console_valid_credentials') }
    teardown { VCR.eject_cassette('console_valid_credentials') }

    should 'login successfully' do
      assert_nothing_raised ESIC::LoginFailedException do
        ESIC::Crawler.new('vitorbaptista', 'correct-password')
      end
    end

    context 'requests' do
      should 'list' do
        crawler = ESIC::Crawler.new('vitorbaptista', 'correct-password')
        requests = crawler.requests
        assert requests.length == 3, 'Should receive 3 requests back'
      end
    end
  end

  should 'fails login when called with invalid credentials' do
    VCR.use_cassette('console_invalid_credentials') do
      assert_raise ESIC::LoginFailedException do
        ESIC::Crawler.new('vitorbaptista', 'wrong-password')
      end
    end
  end
end
