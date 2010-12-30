module Schop
  class Configfile
    class << self

      def config
        @config ||= ( load_from_file || {} )
      end

      def load_from_file
        return false unless config_exists?

        if result = YAML.load_file(configfile)
          result
        else
          puts "Your schop config (~/.schop) is not valid yaml"
        end
      end

      def config_exists?
        File.exist?(configfile)
      end

      def configfile
        File.expand_path("~/.schop")
      end
    end
  end
end
