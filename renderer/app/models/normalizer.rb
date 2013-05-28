class Normalizer
  include MongoMapper::Document
  def logger
    RAILS_DEFAULT_LOGGER
  end
  one :junction

  key :from, String, :required => true
  key :to, String, :required => true
  def self.test
    return Normalizer.all()
  end
end
