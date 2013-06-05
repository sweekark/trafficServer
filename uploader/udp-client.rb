require 'socket.so'

class UDPClient
  def initialize(host, port)
    @host = host
    @port = port
  end

  def start
    @socket = UDPSocket.open
    @socket.connect(@host, @port)
    while true
      puts "sending packet to #{@host} port {@port}"
      @socket.send("otiro", 0, @host, @port)
      sleep 2
    end
  end
end

client = UDPClient.new("localhost", 4321) # 10.10.129.139 is the IP of UDP server
#client = UDPClient.new("54.251.169.128", 49152) # 10.10.129.139 is the IP of UDP server
client.start
