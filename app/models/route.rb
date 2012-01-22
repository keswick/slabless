class Route
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name
  field :destination
  field :jumps
  embeds_many :ratings
  embeds_many :waypoints
  embeds_many :overview_points
  embeds_one :itn_file
  validates_presence_of :name, :destination
  
  #git test - update from desktop
  #git test - update from mbp

  def empty?
    waypoints.size == 0    
  end
  
  def confirmed?
    jumps.nil? ? false : jumps.length != 0
  end
  
end
