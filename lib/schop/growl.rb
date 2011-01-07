module Schop
  class Growl
    GROWLNOTIFY_PATH = "growlnotify"
    class << self
      def enable=(en)
        @enable = !!en
      end
      def enable?
        if @enable.nil?
          @enable = !!(`which #{GROWLNOTIFY_PATH}` =~ /#{GROWLNOTIFY_PATH}/)
        end
        @enable
      end
      def notify(message)
        `echo #{message} | #{GROWLNOTIFY_PATH} -t Schop`
      end
    end
  end
end
