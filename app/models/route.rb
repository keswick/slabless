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
  
  after_save :parse_jumps, :if => :jumps_changed?
  
  def empty?
    waypoints.size == 0    
  end
  
  def confirmed?
    jumps.nil? ? false : jumps.length != 0
  end
  
  protected
  
  def parse_jumps
    j_split = self.jumps.split(/--BREAK--/)
    j_split.each do |jump|
      json_jump = JSON.parse(jump)
      path = json_jump["routes"][0]["overview_path"]
      path.each do |p| 
        pnt = OverviewPoint.new 
        pnt.latlng = {:lat => p["Oa"], :lng => p["Pa"]}
        self.overview_points << pnt
        # debugger
      end
    end
  end
  
  
end
