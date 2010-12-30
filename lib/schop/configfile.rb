module Schop
  class Configfile
    class << self

      def config
        @config ||= ( load_from_file || {} )
      end

      def load_from_file
        return false unless config_exists?

        if result = YAML.load_file(configfile)
          #result.map { |c| Config.new(c) }
          result
        else
          puts "Your schop config (~/.schop) is not valid yaml"
        end
      end

=begin
      def add(config)
        configs.push(config)
        save
      end

      def save
        File.open(configfile, "w+") do |f|
          f.puts YAML.dump( configs.sort_by { |c| c.name } )
        end
      end
=end

      def config_exists?
        File.exist?(configfile)
      end

      def configfile
        File.expand_path("~/.schop")
      end
    end
  end
end
