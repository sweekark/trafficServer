require 'rubygems'
require 'mongo'
require 'json'
include Mongo

string = '{"trafficInfo" : [ { "uvid":"abcd","junctionId" : "9:7:1","location":{"long":"93","lat":"45"},"timestamp":45125125412},{ "uvid":"abcd","junctionId" : "92:7:1","location":{"long":"93","lat":"45"},"timestamp":45125125412} ] }'
parsed = JSON.parse(string) # returns a hash

array_of_hashes = []
parsed["trafficInfo"].each do |trafficInfo|
newPost = {:uvid=>trafficInfo["uvid"],:junctionId => trafficInfo["junctionId"],:location => trafficInfo["location"],:timestamp => Time.now ,:update => 0} 
array_of_hashes << newPost
end

@client = MongoClient.new('localhost', 27017)
@db     = @client['sample-db']
@coll   = @db['uploader']
  @coll.remove
@coll.insert(array_of_hashes)
  @coll.find({"update"=>0}).each { 
    |endPoint|
      @coll.find(
          {"uvid" => endPoint["uvid"],
          "junctionId"=> {"$ne" => endPoint["junctionId"]}}
          ).each { 
        |startPoint|
          timeDiff = endPoint["timestamp"] - startPoint["timestamp"]
          if (@coll.find(:from=>startPoint["junctionId"],:to => endPoint["junctionId"]).count == 0) then
            @coll.insert(:from=>startPoint["junctionId"],:to => endPoint["junctionId"],:timeTaken => [{:value => timeDiff,:timestamp => endPoint["timestamp"] } ] )
              end

              if (@coll.find(:from=>startPoint["junctionId"],:to => endPoint["junctionId"]).count != 0) then
                @coll.update({:from=>startPoint["junctionId"],:to => endPoint["junctionId"]},{"$push" => {:timeTaken => {:value => 31}}})
                  end
      }
  }
