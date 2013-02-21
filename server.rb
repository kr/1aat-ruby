require 'socket'
require 'timeout'

$stdout.sync = true

body = "Hello World\r\n"

$port = (ENV['PORT'] || 8080).to_i

def open_server
    puts "Listening on #{$port} ..."
    server = TCPServer.new($port)

    server.setsockopt(Socket::SOL_SOCKET,Socket::SO_REUSEADDR, true)

    linger = [1, 0].pack('ii')
    server.setsockopt(Socket::SOL_SOCKET, Socket::SO_LINGER, linger)
    return server
end

server = open_server

loop do
  client = server.accept

  # Ignore dyno health checks. They only connect; there is no request.
  is_http = !!timeout(0.9) do
    client.gets["HTTP"]
  end rescue false

  if is_http
    server.close
    puts "Client reading headers ..."
    loop do
      if client.gets == "\r\n"
        break
      end
    end
    puts "Client waiting ..."
    sleep 3
    client.write "HTTP/1.1 200 OK\r\n"
    client.write "Content-Length: #{body.bytesize}\r\n"
    client.write "Content-Type: text/plain\r\n"
    client.write "Connection: close\r\n"
    client.write "\r\n"
    client.write body
    sleep 0.5
  end
  client.close
  puts "Client done."

  if is_http
    server = open_server
  end
end
