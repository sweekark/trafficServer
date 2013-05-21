require_relative 'udp-server'

server = UDPServer.new(4321)
server.start
