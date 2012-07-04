class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Authority::UserAbilities
  field :provider, :type => String
  field :uid, :type => String
  field :name, :type => String
  
  def self.create_with_omniauth(auth)
    user = User.new
    user.provider = auth["provider"]
    user.uid = auth["uid"]
    user.name = auth["info"]["name"]
    user.save
    return user
  end
  
  def self.find_by_provider_and_uid(provider, uid)
    User.where(provider: provider).and(uid: uid).first
  end
  
  def signed_in?
    !new_record
  end
  
  def default_coordinates
    # TODO rework based on user attribute
    coordinates = [38.372323, -81.958437, 42.622316, -71.411562]
    @sw_corner = {:lat => coordinates[0], :lng => coordinates[1]}
    @ne_corner = {:lat => coordinates[2], :lng => coordinates[3]}
    return [@sw_corner, @ne_corner]
  end
  
  # accepts bounds and filter arguments
  def find_my_routes(*args)
    bounds = args[0][:bounds].nil? ? default_coordinates : args[0][:bounds].dup
    routes = case args[0][:filter]
    when "recommended"
      Route.where(:"overview_points.latlng".within(:box) => bounds).where(visibility: 'recommended')
    when "liked"
      # TODO need to build this
    else  # 'my' or blank
      Route.where(:"overview_points.latlng".within(:box) => bounds).where(owner_id: id)
    end
  end
  
end
