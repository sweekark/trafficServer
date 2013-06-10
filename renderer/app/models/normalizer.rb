class Normalizer
  include MongoMapper::Document
  def logger
    RAILS_DEFAULT_LOGGER
  end
  one :junction

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
end
