require "thor"
require "ruby-debug"

module Schop
  class CLI < Thor

=begin
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
=end
    desc "start [name]", ""
    def start(name=nil)
      schopd.start
    end

    desc "stop", ""
    def stop
      schopd.stop
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
      schopd = Schopd.new(configs.map(&:ssh))
      schopd.start
    end

    desc "test2", ""
    def test2
      schopd = Schopd.new(configs.map(&:ssh))
      schopd.stop
    end

    protected
    def config
      @config ||= begin
        c = Configfile.config
        c.empty? ? abort("Please add a new config with `schop add`") : c
      end
    end

    def schopd
      @schopd = begin
        s = Schopd.new
        config["gateways"].each do |name, gateway|
          ssh = Ssh.new(name, gateway)
          s.sshs << ssh
        end
        s
      end
    end
  end
end
