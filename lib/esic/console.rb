require 'trollop'

module ESIC
  class Console
    SUB_COMMANDS = %w(requests)

    def self.run!
      opts = Trollop::options do
        opt :username, 'Your username', type: String, required: true
        opt :password, 'Your password', type: String, required: true
        stop_on SUB_COMMANDS
      end
      puts opts.inspect
      puts ARGV.shift
    end
  end
end
