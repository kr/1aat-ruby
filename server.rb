require 'socket'
require 'timeout'

$stdout.sync = true

port = (ENV['PORT'] || 8080).to_i

is_http = true

loop do
  if is_http
    puts "Listening on #{port} ..."
    server = TCPServer.new(port)

    server.setsockopt(Socket::SOL_SOCKET,Socket::SO_REUSEADDR, true)

    linger = [1, 0].pack('ii')
    server.setsockopt(Socket::SOL_SOCKET, Socket::SO_LINGER, linger)
  end

  client = server.accept

  is_http = !!timeout(0.1) do
    client.gets["HTTP"]
  end

  if is_http
    server.close
    puts "Client waiting ..."
    sleep 3
    client.puts "HTTP 200 OK\r\n"
    client.puts "\r\n"
    client.puts "Hello World"
  end
  client.close
  puts "Client done."
end
