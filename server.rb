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

  is_http = !!timeout(0.5) do
    client.gets["HTTP"]
  end rescue false

  if is_http
    server.close
    puts "Client waiting ..."
    sleep 3
    client.puts "HTTP/1.0 200 OK\r\n"
    client.puts "\r\n"
    client.puts body
    server = open_it
  end
  client.close
  puts "Client done."
end
