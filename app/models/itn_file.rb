class ItnFile
  include Mongoid::Document
  include Mongoid::Timestamps
  field :content, :type => String
  embedded_in :route, :inverse_of => :itn_file
  
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
  
end
