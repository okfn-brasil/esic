require 'mechanize'
require 'json'

module ESIC
  class Crawler
    BASE_URL = 'http://www.acessoainformacao.gov.br/sistema'
    LOGIN_URL = "#{BASE_URL}/Login/Loginframes.aspx"
    MAIN_URL = "#{BASE_URL}/Principal.aspx"
    REQUEST_LIST_URL = "#{BASE_URL}/Pedido/ConsultaPedido.aspx"
    PUBLIC_BODY_LIST_URL = "#{BASE_URL}/Utilidade/WSAjax.asmx/ConsultaOrgaosComSIC"

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

    def request(protocol)
      form = agent.get(REQUEST_LIST_URL).form
      form.radiobuttons[0].check
      form.add_button_to_query form.button
      form.field_with(id: 'ConteudoGeral_ConteudoFormComAjax_txtProtocolo').value = protocol
      requests_page = agent.submit form
      request = parse_requests_page(requests_page).find { |r| r.protocol == protocol }
      if request
        request_details_page = agent.get(request.request_details_url)
        request.text = request_details_page.at('#ConteudoGeral_ConteudoFormComAjax_tabGeral_tabDadosPedido_txtDescricaoSolicitacao').text.strip
        response = request_details_page.at('#ConteudoGeral_ConteudoFormComAjax_tabGeral_tabDadosResposta_txtResposta')
        request.response_text = response.text.strip if response
      end
      request
    end

    def public_bodies
      result = agent.post(PUBLIC_BODY_LIST_URL,
                          '{ idOrgaoSuperiorLimitado: 0, nomeOrgao: \'\', isBloqueados: true }',
                          'Content-Type' => 'application/json')

      parse_public_bodies_page(result)
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
        request_details_url = row.at('a').attributes['href'].value
        details = row.search('span').map(&:text).map(&:strip)
        protocol, entity, _, created_at, expired_at, state = *details
        results << Request.new(request_details_url, protocol, entity, created_at, expired_at, state)
      end

      results
    end

    def is_requests_page?(page)
      !!page.at('//table[@id="ConteudoGeral_ConteudoFormComAjax_gvPedidos"]')
    end

    def parse_public_bodies_page(page)
      raise PublicBodiesPageException unless is_public_bodies_page?(page)

      json = JSON.load(JSON.load(page.body)['d'])
      public_bodies = {}

      json.each do |public_body|
        id = public_body['IdOrgaoSiorg']
        name = public_body['NomeOrgaoVinculado']
        superior_id = public_body['IdOrgaoSiorgSuperior']
        superior_name = public_body['NomeOrgaoSuperior']
        public_bodies[superior_id] ||= PublicBody.new(superior_id, superior_name)
        public_bodies[id] ||= PublicBody.new(id, name, public_bodies[superior_id])
      end

      public_bodies.values
    end

    def is_public_bodies_page?(page)
      JSON.load(page.body)
      true
    rescue JSON::ParserError
      false
    end
  end
end
