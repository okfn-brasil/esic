require 'trollop'

module ESIC
  class Console
    def self.run!
      opts = Trollop::options do
        opt :username, 'Your username', type: String, required: true
        opt :password, 'Your password', type: String, required: true
      end
    end
  end
end
