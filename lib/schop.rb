require "highline"
require "yaml"

module Schop
  autoload :CLI, "schop/cli"
  autoload :Configfile, "schop/configfile"
  autoload :Config, "schop/config"

  def self.start(conf)
    puts "Starting #{conf}"
    puts "--> #{conf.ssh_command}"
    system conf.ssh_command
  end
end
