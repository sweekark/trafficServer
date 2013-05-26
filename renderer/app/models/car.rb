class Car
  include MongoMapper::Document

  key :make, String, :required => true
  key :model, String, :required => true
  key :year, Integer
  key :description, String
  timestamps!

end
