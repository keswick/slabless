class Waypoint
  include Mongoid::Document
  field :latitude
  field :longitude
  field :name
  field :comment
  field :description
  field :link
  field :loc
  embedded_in :route, :inverse_of => :waypoints
  index [[ :loc, Mongo::GEO2D ]]
  
  def selector
    id = latitude + 'BREAK' + longitude
    return id.gsub(/\./, "_")
  end
end
