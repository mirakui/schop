require "thor"
require "ruby-debug"

module Schop
  class CLI < Thor

    desc "start", "Start schopd and sshs"
    def start()
      schopd.start
    end

    desc "stop", "Stop all sshs and schopd"
    def stop
      schopd.stop
    end

    desc "status", "Show daemons' status"
    def status
      #say_status schopd.app.pid.running?, "hoge" 
      print_table [
        ["schopd", schopd.app.pid.running? ? "running" : "not running"],
        *schopd.sshs.map{|ssh| ["(ssh)#{ssh.name}", "#{ssh.pid.running? ? "running" : "not running"}"]}
      ]
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
