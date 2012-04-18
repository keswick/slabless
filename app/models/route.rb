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
  accepts_nested_attributes_for :itn_file
  
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
  
  def groom_waypoints
    unless self.route.itn_file.nil?
      self.route.itn_file.destroy
      self.route.waypoints.each { |w| w.destroy }
    end
  end
  
  def parse_itn
    self.content.each_line do |w|
      w_split = w.strip.split('|')
      if w_split.size == 4 && w_split[0].length > 4 && w_split[1].length > 0
        waypoint = Waypoint.new
        waypoint.latitude = w_split[1][0] =~ /[\+\-]/ ? w_split[1].insert(3, ".") : w_split[1].insert(2, ".")
        waypoint.longitude = w_split[0][0] =~ /[\+\-]/ ? w_split[0].insert(3, ".") : w_split[0].insert(2, ".")
        waypoint.name = w_split[2]
        waypoint.loc = [waypoint.latitude.to_f, waypoint.longitude.to_f]
        self.route.waypoints << waypoint
      end
    end
  end
  
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
