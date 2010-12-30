require "highline"
require "yaml"
require "daemons"
require "daemons/pidfile"

module Schop
  autoload :CLI, "schop/cli"
  autoload :Configfile, "schop/configfile"
  autoload :Config, "schop/config"
  autoload :Ssh, "schop/ssh"
end
