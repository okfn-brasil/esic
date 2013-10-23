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

    context 'public bodies' do
      should 'list' do
        crawler = ESIC::Crawler.new('vitorbaptista', 'correct-password')
        requests = crawler.public_bodies
        ministerio_da_saude = requests.find { |body| body.id == 304 }
        assert ministerio_da_saude, 'Ministério da Saúde should exist'
        assert requests.length == 117, "Should have 117 public bodies #{requests.length}"
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
