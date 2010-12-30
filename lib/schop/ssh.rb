require "thor/actions"
require "daemons/pidfile"
require "pathname"

module Schop
  class Ssh
    include Thor::Shell
    PID_DIR = Pathname("/tmp")

    def initialize(config)
      @config = config
    end

    def run
      if pid.running?
        say "already running", :red
        return
      end
      say command
      io = IO.popen(command, "r")
      pid.pid = io.pid
    end

    def kill
      unless pid.exist?
        say "#{pid.path} doesn't exist", :red
        return false
      end
      if pid.running?
        Process.kill("TERM", pid.pid)
      end
      3.times do |i|
        unless pid.running?
          say "killed #{pid.pid}", :green
          return true
        end
        sleep 1
      end
      say "couldn't killed #{pid.pid}", :red
      return false
    end

    def pid
      @pid ||= Daemons::PidFile.new(PID_DIR, "schop-ssh")
    end

    def command
      @command ||= "ssh -p %s -D %s -nNT %s@%s" %
      [ @config.ssh_port,
        @config.dynamic_port,
        @config.gateway_user,
        @config.gateway_host ]
    end
  end
end
