class OverviewPoint
  include Mongoid::Document
  include Mongoid::Spacial::Document
  
  field :latlng, :type => Array, :spatial => true
  
  spatial_index :latlng
end
