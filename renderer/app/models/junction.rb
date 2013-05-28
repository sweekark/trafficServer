class Junction
  include MongoMapper::EmbeddedDocument
  def logger
    RAILS_DEFAULT_LOGGER
  end

  key :junctionId, String, :required => true
  key :name, String, :required => true
end
