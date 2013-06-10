require_relative 'udp-server'

server = UDPServer.new(49152)
server.start
