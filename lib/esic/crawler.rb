require 'mechanize'

module ESIC
  class Crawler
    LOGIN_URL = 'http://www.acessoainformacao.gov.br/sistema/Login/Loginframes.aspx'
    attr_reader :username, :password

    def initialize(username, password)
      @username = username
      @password = password
      login!
    end

    private
    def login!
      form = agent.get(LOGIN_URL).form
      form.field_with(name: 'txtUsuario').value = @username
      form.field_with(name: 'txtSenha').value = @password
      form.add_button_to_query form.button
      agent.submit form
      raise LoginFailedException unless logged_in?
    end

    def logged_in?
      agent.cookie_jar.cookies.find { |x| x.name == 'AcbrasilFormsAuthCookie' }
    end

    def agent
      @agent ||= Mechanize.new do |agent|
        agent.user_agent_alias = 'Android'
      end
    end
  end
end
