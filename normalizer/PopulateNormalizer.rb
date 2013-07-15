#######################################################
=begin
  use the start point and end point from the uploader
  insert it into the normalizer
  create a new entry
  insert time stamps into normaliser untill time taken mas
  update the time taken max array based on latest index
=end
######################################################
class PopulateNormalizer

  def calculateAvgTime(startPoint,endPoint)
puts "calculating avg time"
    avgTimeTaken = 0

    if ( normalizerEntry = @normalizer.find_one(@findOneQuery) 
       ) then
       timeTakenArray = normalizerEntry["timeTaken"]
       timeTakenCount =  normalizerEntry["timeTaken"].count
       puts timeTakenArray
       timeTakenArray.each do |timeTaken| 
         avgTimeTaken = avgTimeTaken + timeTaken["value"]
       end
    avgTimeTaken = avgTimeTaken/timeTakenCount
    puts "avgTimeTaken for points between is #{avgTimeTaken}"
    @normalizer.update(
      @findOneQuery,
      {"$set" => {"avgTimeTaken"=>avgTimeTaken}
    }
    )
    end
  end

  def updateTimeTaken(startPoint,endPoint,lastIndex,timeDiff)
	puts " updating time taken ################"
    presentIndex = (@lastIndex + 1)% @timeTakenMax
    puts " updating time taken on index #{presentIndex}"
    @normalizerE = @normalizer.update(
      @findOneQuery,
      {"$set" => 
        {"timeTaken.#{presentIndex}" =>  
        @timeTakenQuery,
            "presentIndex" => presentIndex 
        }
    }
    )
    calculateAvgTime(startPoint,endPoint)
  end

  def CreateNew(startPoint,endPoint,lastIndex,timeDiff)
    presentIndex = (@lastIndex + 1)% @timeTakenMax
      puts " pushing new entry for time taken at index #{presentIndex}"
    @normalizer.update(
      {:"from.junction"=>@junction.find_one(id:startPoint["junctionId"]),
        :"to.junction" => @junction.find_one(:id=>endPoint["junctionId"])},
      {
      "$push" => {:timeTaken =>  
        @timeTakenQuery
    },"$set" => {:presentIndex => presentIndex}},
      {
      :upsert => true
    })
    calculateAvgTime(startPoint,endPoint)
  end

  def initialize(startPoint,endPoint,timeDiff)
    @client = MongoClient.new('localhost', 27017)
    @db     = @client['traffic2']
    @coll   = @db['uploader']
    @normalizer = @db['normalizers']
    @junction = @db['junctions']
    @findOneQuery = {
      :"from.junction.id"=>startPoint["junctionId"],
      :"to.junction.id" => endPoint["junctionId"]
    }
    @timeTakenQuery = 
          {:value => timeDiff,
            :timestamp => endPoint["timestamp"] 
          }
    #@normalizer.remove


    ## control the no of time taken entried in the bucket
    ## this will be the latest entries
    @timeTakenMax = 10
    @timeTakenCount = 0
    @lastIndex = -1 # when no entry present for the start n end point
    if ( @normalizerEntry = @normalizer.find_one(@findOneQuery) 
       ) then
       @timeTakenArray = @normalizerEntry["timeTaken"]
       @timeTakenCount =  @normalizerEntry["timeTaken"].count
       @lastIndex =  @normalizerEntry["presentIndex"]
       puts " entry exists for start point #{startPoint["junctionId"]} endpoint #{endPoint["junctionId"]} in nomralizer"
       puts "time taken count is #{@timeTakenCount}"
    end
    ## if the entry for the uvid is not present 
    ## in normalizer create new
    ## if present just push the value to the array 
    ## upsert => true option will handle this
    #  calculateNextBuffer()
    if @timeTakenCount < @timeTakenMax then 
      puts "##########################################################"
	puts " creating new entry for junctions  #{startPoint["junctionId"]} endpoint #{endPoint["junctionId"]} in nomralizer "
      CreateNew(startPoint,endPoint,@lastIndex,timeDiff)
    else
      updateTimeTaken(startPoint,endPoint,@lastIndex,timeDiff)
      puts "##########################################################"
    end
  end
end
