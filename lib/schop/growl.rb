module Schop
  class Growl
    def self.notify(message)
      `echo #{message} | growlnotify -t Schop`
    end
  end
end
