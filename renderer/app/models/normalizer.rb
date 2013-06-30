class Normalizer
include MongoMapper::Document
def logger
RAILS_DEFAULT_LOGGER
end

def self.get(params)
  @data = params[:data]
  @from = @data[:from] 
  @to = @data[:to] 
  Rails.logger.debug("from : #{@from}")
  Rails.logger.debug("to : #{@to}")
## max distance is specified in radians
## one radian begin 111.12 kms
## a polypoint should be within 500 mtrs of a junction 
  maxDistanceForJunction =  0.5/111.12
  normalizer = Normalizer.where(
      :"from.junction.loc" => 
      {
      "$near" => [
      @from[:loc][:lon], @from[:loc][:lat]
      ],
      "$maxDistance" => maxDistanceForJunction 
      },
      :"to.junction.loc" => 
      {
      "$near" => [
      @to[:loc][:lon], @to[:loc][:lat]
      ],
      "$maxDistance" => maxDistanceForJunction 
      }
      ).fields(:from,:to,:avgTimeTaken).first
  return normalizer
  end

def self.getJunctions(params)
# for params[:from] get the first junction point 
#from the normalizer db

  @junctions = Array.new;
  @firstPoint = self.getFirstJunction(params)
  @junctions.push(@firstPoint)
  Rails.logger.debug("this is the first point : #{@firstPoint.inspect}")
  Rails.logger.debug("########################################");

  @lastPoint = self.getLastJunction(params)
  Rails.logger.debug("this is the last point : #{@lastPoint.inspect}")
  Rails.logger.debug("########################################");

  nextPointHash = self.getNextJunction(@firstPoint)
  @nextPoint = nextPointHash["junction"]
  @avgTimeTaken = nextPointHash["avgTimeTaken"]
  @junctions.push(nextPointHash)
  Rails.logger.debug("this is the next point : #{@nextPoint.inspect}")
  Rails.logger.debug("########################################");

  #@nextPoint[:to][:avgTimeTaken] = @nextPoint[:avgTimeTaken]
    count = 0;
  while @nextPoint["id"] != @lastPoint["id"] do 
    nextPointHash = self.getNextJunction(@nextPoint)
    @nextPoint = nextPointHash["junction"]
    @avgTimeTaken = @avgTimeTaken + nextPointHash["avgTimeTaken"]
    Rails.logger.debug("in next point ")
    Rails.logger.debug("this is the next point : #{@nextPoint.inspect}")
    Rails.logger.debug("########################################");
    @junctions.push(nextPointHash)
  end

  Rails.logger.debug("junctions : #{@junctions.inspect}")
  @results = Hash.new;
  @data = params[:data]
  @results["from"] = @data[:from] 
  @results["to"] = @data[:to] 
  @results["avgTimeTaken"] = @avgTimeTaken
  @results["junctions"] = @junctions
  return @results;
end


def self.getFirstJunction(params)
  @data = params[:data]
  @from = @data[:from] 
  @to = @data[:to] 
  Rails.logger.debug("from : #{@from}")
  Rails.logger.debug("to : #{@to}")

  maxDistanceForJunction =  0.5/111.12
  @normalizer = Normalizer.where(
      :"from.junction.loc" => 
      {
      "$near" => [
      @from[:loc][:lon], @from[:loc][:lat]
      ],
      "$maxDistance" => maxDistanceForJunction 
      }
      ).first
      return @normalizer[:from]["junction"]
  end
def self.getNextJunction(present)
id = present["_id"]
  normalizer = Normalizer.where(
      :"from.junction._id" => 
     id 
      ).first
      return ({"junction" => normalizer[:to]["junction"],"avgTimeTaken" => normalizer[:avgTimeTaken]})
  end


def self.getLastJunction(params)
  @data = params[:data]
  @from = @data[:from] 
  @to = @data[:to] 
  Rails.logger.debug("from : #{@from}")
  Rails.logger.debug("to : #{@to}")

  maxDistanceForJunction =  0.5/111.12
  normalizer = Normalizer.where(
      :"to.junction.loc" => 
      {
      "$near" => [
      @to[:loc][:lon], @to[:loc][:lat]
      ],
      "$maxDistance" => maxDistanceForJunction 
      }
      ).first
      return normalizer[:to]["junction"]
end
end
