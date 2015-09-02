require 'lshw/system'

module Lshw
  class System
    VENDOR_PATH = '/list/node/vendor'
    SERIAL_PATH = '/list/node/serial'

    def vendor
      @hw.search(VENDOR_PATH).text
    end

    def serial
      @hw.search(SERIAL_PATH).text
    end
  end
end
