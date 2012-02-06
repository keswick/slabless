class OverviewPoint
  include Mongoid::Document
  include Mongoid::Spacial::Document
  
  field :latlng, :type => Array, :spacial => true
  embedded_in :route, :inverse_of => :overview_points
  
end
