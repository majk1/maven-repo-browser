require 'socket'
require_relative 'header'

module Browser

  class Browser

    attr_accessor :callback, :port, :host

    def self.extract_path(path)
      if path.start_with? '/'
        path = path[1..-1]
      end
      return path.split('/')
    end

    def initialize
      @host = 'localhost'
      @port = 9999
      @callback = nil
    end

    def read_header(socket)
      request = socket.gets

      method, path, protocol = request.split
      header_info = Header.new(method, path, protocol)

      until (line = (socket.gets).strip).empty?
        nothing, key, value = line.split(/(.*): (.*)/)
        value = value.strip
        header_info.add_header(key, value)
      end

      header_info
    end

    def start
      STDOUT.puts("Starting browser on #{@host}:#{@port}...")

      server = TCPServer.new @host, @port
      loop do
        socket = server.accept
        header_info = self.read_header socket

        response = @callback.call(header_info)

        socket.print "HTTP/1.1 200 OK\r\n" +
                         "Content-Type: text/html\r\n" +
                         "Content-Length: #{response.bytesize}\r\n" +
                         "Connection: close\r\n"
        socket.print "\r\n"
        socket.print response
        socket.close
      end
    end

  end

end
