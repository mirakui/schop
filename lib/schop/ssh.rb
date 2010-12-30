require "thor/actions"
require "daemons/pidfile"
require "pathname"

module Schop
  class Ssh
    include Thor::Shell
    PID_NAME_PREFIX = "schop-ssh-"

    attr_reader :name, :config

    def initialize(name, config)
      @name = name
      @config = config
    end

    def start
      if pid.running?
        say "already running", :red
        return
      end
      say command
      io = IO.popen(command, "r")
      pid.pid = io.pid
    end

    def stop
      unless pid.exist?
        say "#{pid.filename} doesn't exist", :red
        return false
      end
      if pid.running?
        Process.kill("TERM", pid.pid)
      end
      3.times do |i|
        unless pid.running?
          say "killed #{pid.pid}", :green
          delete_pid_files
          return true
        end
        sleep 1
      end
      say "couldn't killed #{pid.pid}", :red
      return false
    end

    def pid_name
      "#{PID_NAME_PREFIX}#{@name}"
    end

    def pid
      @pid ||= Daemons::PidFile.new(PID_DIR, pid_name)
    end

    def find_pid_files(delete=false)
      Daemons::PidFile.find_files(PID_DIR, pid_name, delete)
    end

    def delete_pid_files
      find_pid_files(true)
    end

    def command
      @command ||= "ssh -p %s -D %s -nNT %s@%s" %
      [ @config["ssh_port"],
        @config["dynamic_port"],
        @config["gateway_user"],
        @config["gateway_host"] ]
    end

    def gateway_alive?
      cmd = "ssh -p %s %s@%s '%s' 2>&1" %
      [ @config["ssh_port"],
        @config["gateway_user"],
        @config["gateway_host"],
        "echo hello" ]
      result = `#{cmd}`.chomp
      result == "hello"
    end
  end
end
