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
    @socket.bind(nil, @port) # is nil OK here?
    while true
      puts "listening at port #{@port}"
      data,sender = @socket.recvfrom(1024)
      puts data
      populate = PopulateDB.new()
      populate.pushData(data)
    end
  end
end
