# encoding: utf-8

require 'helper'

class TestCrawler < Test::Unit::TestCase
  context 'valid credentials' do
    setup { VCR.insert_cassette('console_valid_credentials') }
    teardown { VCR.eject_cassette('console_valid_credentials') }

    should 'login successfully' do
      assert_nothing_raised ESIC::LoginFailedException do
        ESIC::Crawler.new(USERNAME, PASSWORD)
      end
    end

    context 'requests' do
      should 'list' do
        crawler = ESIC::Crawler.new(USERNAME, PASSWORD)
        requests = crawler.requests
        assert requests.length == 4, "Should have 4 requests #{requests.length}"
      end
    end

    context 'request' do
      should 'get the request\'s and response\'s text' do
        crawler = ESIC::Crawler.new(USERNAME, PASSWORD)
        request = crawler.request('08850001191201270')
        assert request.text =~ /violência contra a mulher/, request.text
        assert request.response_text =~ /Prezado Cidadão/, request.response_text
      end

      should 'work even if the public body haven\'t answered yet' do
        crawler = ESIC::Crawler.new(USERNAME, PASSWORD)
        request = crawler.request('00075001505201341')
        assert request.response_text.nil?, 'Response text should be nil'
      end
    end

    context 'public bodies' do
      should 'list' do
        crawler = ESIC::Crawler.new(USERNAME, PASSWORD)
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
        ESIC::Crawler.new(USERNAME, 'wrong-password')
      end
    end
  end
end
