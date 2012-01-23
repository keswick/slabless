class ItnFile
  include Mongoid::Document
  include Mongoid::Timestamps
  field :content, :type => String
  embedded_in :route
  
  before_create :groom
  after_create :create_waypoints
  
  protected
  
  def groom
    unless self.route.itn_file.nil?
      self.route.itn_file.destroy
      self.route.waypoints.each { |w| w.destroy }
    end
  end
  
  def create_waypoints
    self.content.each_line do |w|
      w_split = w.split('|')
      waypoint = Waypoint.new
      waypoint.latitude = w_split[1].insert(3, ".")
      waypoint.longitude = w_split[0].insert(3, ".")
      waypoint.name = w_split[2]
      waypoint.loc = [waypoint.latitude.to_f, waypoint.longitude.to_f]
      self.route.waypoints << waypoint
    end
  end
  
end
