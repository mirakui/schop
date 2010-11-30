require "ostruct"

module Schop
  class Config < OpenStruct

    def to_yaml(opts={})
      @table.to_yaml(opts)
    end

    def to_s
      "[ %s ] %s:%s -> 0.0.0.0:%s" %
      [ name, gateway_host, ssh_port, dynamic_port ]
    end

    def ssh_command
      "ssh -p %s -D %s -nNT %s@%s" %
      [ ssh_port, dynamic_port, gateway_user, gateway_host ]
    end

    def verbose_flag
      self.verbose ? '-v' : ''
    end
  end
end
