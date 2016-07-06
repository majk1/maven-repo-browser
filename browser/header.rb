module Browser

  class Header

    def initialize(method, path, protocol)
      @method = method
      @path = path
      @protocol = protocol
      @header = {}
    end

    def add_header(key, value)
      @header[key.to_sym] = value
    end

    def get_method
      @method
    end

    def get_path
      @path
    end

    def get_protocol
      @protocol
    end

    def get_header(key)
      @header[key.to_sym]
    end

  end

end
