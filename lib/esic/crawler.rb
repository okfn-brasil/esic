require 'mechanize'

module ESIC
  class Crawler
    BASE_URL = 'http://www.acessoainformacao.gov.br/sistema'
    LOGIN_URL = "#{BASE_URL}/Login/Loginframes.aspx"
    MAIN_URL = "#{BASE_URL}/Principal.aspx"
    REQUEST_LIST_URL = "#{BASE_URL}/Pedido/ConsultaPedido.aspx"

    attr_reader :username, :password

    def initialize(username, password)
      @username = username
      @password = password
      login!
    end

    def requests
      form = agent.get(REQUEST_LIST_URL).form
      form.radiobuttons[0].check
      form.add_button_to_query form.button
      requests_page = agent.submit form
      parse_requests_page(requests_page)
    end

    private
    def login!
      form = agent.get(LOGIN_URL).form
      form.field_with(name: 'txtUsuario').value = @username
      form.field_with(name: 'txtSenha').value = @password
      form.add_button_to_query form.button
      agent.submit form
      raise LoginFailedException unless logged_in?
      agent.get(MAIN_URL)
      true
    end

    def logged_in?
      agent.cookie_jar.cookies.find { |x| x.name == 'AcbrasilFormsAuthCookie' }
    end

    def agent
      @agent ||= Mechanize.new do |agent|
        agent.user_agent = 'Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/28.0.1500.71 Chrome/28.0.1500.71 Safari/537.36'
      end
    end

    def parse_requests_page(page)
      raise RequestsPageException unless is_requests_page?(page)
      results = []
      rows = page.search('//tr')
      rows.shift # Ignore header

      rows.each do |row|
        url = row.at('a').attributes['href'].value
        details = row.search('span').map(&:text).map(&:strip)
        results << [url] + details
      end

      results
    end

    def is_requests_page?(page)
      !!page.at('//table[@id="ConteudoGeral_ConteudoFormComAjax_gvPedidos"]')
    end
  end
end
