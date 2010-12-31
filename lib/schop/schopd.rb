require "daemons"
require "thor/shell"

module Schop
  class Schopd
    include Thor::Shell
    WAIT = 5
    DAEMON_NAME = "schopd"

    attr_accessor :sshs
 
    def initialize(sshs=[])
      @sshs = sshs
    end

    def start
      if app.pid.running?
        say "#{DAEMON_NAME}: already running", :red
        return
      end
      group.start_all
    end

    def stop
      group.stop_all
      @sshs.each do |ssh|
        ssh.stop
      end
    end

    def app
      group.applications.first
    end

    def group
      @group ||= begin
        grp = Daemons::ApplicationGroup.new(DAEMON_NAME, daemon_options)
        grp.setup
        grp.new_application(daemon_options) if grp.applications.empty?
        grp
      end
    end

    private
    def check
      @sshs.each do |ssh|
        say "#{ssh.name}: running:#{ssh.pid.running?} alive:#{ssh.gateway_alive?}", :yellow
        unless ssh.pid.running? && ssh.gateway_alive?
          say "#{ssh.name}: dying", :red
          ssh.restart
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
