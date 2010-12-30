require "daemons"
require "thor/shell"

module Schop
  class Schopd
    include Thor::Shell
    WAIT = 10
    DAEMON_NAME = "schopd"

    attr_accessor :sshs
 
    def initialize(sshs=[])
      @sshs = sshs
    end

    def start
      @sshs.each do |ssh|
        ssh.start
        say "started: #{ssh.name}", :green
      end
      group.start_all
    end

    def stop
      group.stop_all
      @sshs.each do |ssh|
        ssh.stop
        say "stopped: #{ssh.name}", :green
      end
    end

    private
    def app
      group.applications.first
    end

    def group
      @group ||= begin
        grp = Daemons::ApplicationGroup.new(DAEMON_NAME, daemon_options)
        app = grp.new_application(daemon_options)
        grp
      end
    end

    def check
      @sshs.each do |ssh|
        unless ssh.pid.running?
          say "#{ssh.name}: dead", :red
        else
          say "#{ssh.name}: alive", :green
        end
      end
    end

    def run
      loop do
        check
        sleep WAIT
      end
    end

    def daemon_options
      @daemon_options ||= {
        :app_name   => DAEMON_NAME,
        :proc       => self.method(:run).to_proc,
        :mode       => :proc,
        :dir_mode   => :normal,
        :dir        => PID_DIR,
        :multiple   => false,
        :backtrace  => true,
        :log_output => true
      }
    end
  end
end
