require 'trollop'

module ESIC
  class Console
    SUB_COMMANDS = %w(requests public_bodies)

    def self.run!
      opts = Trollop::options do
        opt :username, 'Your username', type: String, required: true
        opt :password, 'Your password', type: String, required: true
        stop_on SUB_COMMANDS
      end

      command = ARGV.shift
      Trollop::die "unknown command #{command}" unless SUB_COMMANDS.include? command

      crawler = ESIC::Crawler.new(opts[:username], opts[:password])

      case command
      when 'requests'
        puts crawler.requests.inspect
      when 'public_bodies'
        puts crawler.public_bodies.inspect
      end
    end
  end
end
