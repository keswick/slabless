class Route
  include Mongoid::Document
  include Mongoid::Spacial::Document
  include Mongoid::Timestamps
  field :name
  field :destination
  field :jumps
  embeds_many :ratings
  embeds_many :waypoints
  embeds_many :overview_points
  embeds_one :itn_file
  
  spacial_index 'overview_points.latlng'
  
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
    overview_points.each { |p| p.destroy } unless overview_points.nil?
    j_split = self.jumps.split(/--BREAK--/)
    j_split.each do |jump|
      json_jump = JSON.parse(jump)
      path = json_jump["routes"][0]["overview_path"]
      lat_key, lng_key = set_latlng_keys(path[0])
      path.each do |p|
        pnt = OverviewPoint.new
        pnt.latlng = {:lat => p[lat_key], :lng => p[lng_key]}
        self.overview_points << pnt
      end
    end
  end
  
  def set_latlng_keys(p)
    return [p.keys[0], p.keys[1]]
  end
  
end
