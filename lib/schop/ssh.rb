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
        say "#{@name}: already running", :red
        return false
      end
      unless gateway_alive?
        say "#{@name}: couldn't reach gateway", :red
        return false
      end
      say command
      io = IO.popen(command, "r")
      pid.pid = io.pid
      say "#{@name} pid: #{pid.pid}", :yellow
      if pid.running?
        say "#{@name}: started", :green
        Growl.notify "#{@name}: started"
        return true
      else
        say "#{@name}: couldn't be started", :red
        Growl.notify "#{@name}: couldn't be started", :red
        return false
      end
    end

    def stop
      unless pid.exist?
        say "#{@name}: #{pid.filename} doesn't exist", :red
        return true
      end
      if pid.running?
        Process.kill("TERM", pid.pid)
      end
      delete_pid_files
      3.times do |i|
        unless pid.running?
          say "#{@name}: killed #{pid.pid}", :green
          Growl.notify "#{@name}: stopped"
          return true
        end
        sleep 1
      end
      say "#{@name}: couldn't killed #{pid.pid}", :red
      return false
    end

    def restart
      if stop
        sleep 1
        start
      end
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
      @command ||= "ssh -p %s -D %s -qnNT %s@%s 2>&1 1>/dev/null" %
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
