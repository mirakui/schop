require "highline"
require "yaml"
require "daemons"

module Schop
  autoload :CLI, "schop/cli"
  autoload :Configfile, "schop/configfile"
  autoload :Config, "schop/config"

  def self.start(conf)
    puts "Starting #{conf}"
    puts "--> #{conf.ssh_command}"
    io = IO.popen(conf.ssh_command, "r")
    puts io.pid
  end
end
