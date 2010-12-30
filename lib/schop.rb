require "highline"
require "yaml"
require "daemons"
require "daemons/pidfile"
require "pathname"

module Schop
  autoload :CLI, "schop/cli"
  autoload :Configfile, "schop/configfile"
  autoload :Config, "schop/config"
  autoload :Ssh, "schop/ssh"
  autoload :Schopd, "schop/schopd"
  PID_DIR = Pathname("/tmp")
end
