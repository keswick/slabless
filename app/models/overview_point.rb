class OverviewPoint
  include Mongoid::Document
  include Mongoid::Spacial::Document
  
  field :latlng, :type => Array, :spacial => true
  
  spacial_index :latlng
end
