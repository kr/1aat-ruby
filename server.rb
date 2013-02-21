require 'socket'
require 'timeout'

$stdout.sync = true

body = "Hello World\r\n"

$port = (ENV['PORT'] || 8080).to_i

def open_it
    puts "Listening on #{$port} ..."
    server = TCPServer.new($port)

    server.setsockopt(Socket::SOL_SOCKET,Socket::SO_REUSEADDR, true)

    linger = [1, 0].pack('ii')
    server.setsockopt(Socket::SOL_SOCKET, Socket::SO_LINGER, linger)
    return server
end

is_http = true

server = open_it

loop do
  client = server.accept

  is_http = !!timeout(0.9) do
    client.gets["HTTP"]
  end rescue false

  if is_http
    server.close
    puts "Client reading headers ..."
    loop do
      s = client.gets
      if s == "\r\n"
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
    server = open_it
  end
  client.close
  puts "Client done."
end
