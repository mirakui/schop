require "thor/actions"
require "daemons/pidfile"
require "pathname"
require "timeout"

module Schop
  class Ssh
    include Thor::Shell
    PID_NAME_PREFIX = "schop-ssh-"
    ALIVE_TIMEOUT = 5

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
      say command
      @io = IO.popen(command, "r+")
      pid.pid = @io.pid
      say "#{@name}: pid=#{pid.pid}", :yellow
      if gateway_alive? && pid.running?
        say "#{@name}: started", :green
        Growl.notify "#{@name}: started"
        return true
      else
        say "#{@name}: could not be started", :red
        return false
      end
    end

    def stop
      unless pid.exist?
        say "#{@name}: #{pid.filename} does not exist", :red
        return true
      end
      if pid.running?
        say "#{name}: #{pid.pid} running"
        Process.kill("TERM", pid.pid)
      end
      delete_pid_files
      1.times do |i|
        unless pid.running?
          say "#{@name}: killed #{pid.pid}", :green
          return true
        end
        #sleep 1
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
      @command ||= "ssh -p %s -D %s %s -T %s@%s" %
      [ @config["ssh_port"],
        @config["dynamic_port"],
        @config["local_ports"] ? @config["local_ports"].map{|l|"-L #{l}"}.join(" ") : "",
        @config["gateway_user"],
        @config["gateway_host"] ]
    end

    def gateway_alive?
      return false if !@io || @io.closed?
      msg = "hello"
      received = nil
      timeout(ALIVE_TIMEOUT) do
        @io.puts "echo #{msg}"
        @io.flush
        received = @io.gets
        received.chomp! if received
      end
      alive = received == msg
      alive
    rescue TimeoutError
      say "#{@name}: timeout", :red
      Growl.notify "#{@name}: timeout"
      false
    rescue Errno::EPIPE
      @io.close
      say "#{@name}: pipe error", :red
      false
    end
  end
end
