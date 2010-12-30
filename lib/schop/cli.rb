require "thor"

module Schop
  class CLI < Thor

    desc "start", "Start a schop"
    method_option :verbose, :type => :boolean, :aliases => "-v", :banner => "Enable verbose output"
    def start
      highline = HighLine.new
      highline.choose do |menu|
        menu.choices(*configs) do |choice|
          choice.verbose = options.verbose?
          choice.ssh.run
        end
      end
    end

    desc "stop", ""
    def stop
      configs.each do |config|
        config.ssh.kill
      end
    end

    desc "list", "List your schop configs"
    def list
      configs.each_with_index do |c, i|
        puts "#{i+1}. #{c}"
      end
    end

    desc "add", "Add a new schop config"
    def add
      highline = HighLine.new
      puts "Adding a new schop config"

      conf = Config.new
      conf.name         = highline.ask("Gateway name: ")
      conf.gateway_host = highline.ask("Gateway host: ")
      conf.ssh_port     = highline.ask("SSH port:     ") { |q| q.default = "22" }
      conf.gateway_user = highline.ask("Gateway user: ") { |q| q.default = ENV['USER'] }
      conf.dynamic_port = highline.ask("Dynamic port: ") { |q| q.default = "1080" }

      Configfile.add(conf)
    end

    desc "test", ""
    def test
      p Pathname(__FILE__).join("../../../tmp")
    end

    protected
    def configs
      @configs ||= begin
        c = Configfile.configs
        c.empty? ? abort("Please add a new config with `schop add`") : c
      end
    end
  end
end
