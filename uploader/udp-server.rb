require 'socket.so'
require_relative 'PopulateDB'

class UDPServer
  def initialize(port)
    @port = port
  end

  def start
=begin
      populate = PopulateDB.new()
      populate.pushData("a")
      exit
=end
    @socket = UDPSocket.new
    @socket.bind('', @port) # is nil OK here?
    while true
      puts "listening at port #{@port}"
      data,sender = @socket.recvfrom(1024)
      puts "data received : #{data}"
      populate = PopulateDB.new()
    ########### sample data to test
#      data = '{ "tag": "general", "agency": "free to air", "trafficInfo":[{"timestamp":1371282904,"junctionid":"91:560078:1", "location":{ "lat":"12.911335", "long":"77.585705"},"uvid":"54:9B:12:09:B4:C9"}]}'
    ##################################
      populate.pushData(data)
    end
  end
end
