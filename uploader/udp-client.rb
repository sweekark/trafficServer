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
      puts "sending packet to #{@host} port #{@port}"
      data = '{ "tag": "general", "agency": "free to air", "trafficInfo":[{"timestamp":1371282904,"junctionid":"91:560078:1", "location":{ "lat":"12.911335", "long":"77.585705"},"uvid":"54:9B:12:09:B4:C9"}]}'
      data = '{ "tag": "general", "agency": "free to air"}'

      @socket.send(data, 0, @host, @port)
      sleep 2
    end
  end
end

#client = UDPClient.new("54.251.169.128", 49152) # 10.10.129.139 is the IP of UDP server
client = UDPClient.new("localhost", 49152) # 10.10.129.139 is the IP of UDP server
client.start
