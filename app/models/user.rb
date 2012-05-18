class User
  include Mongoid::Document
  include Mongoid::Timestamps
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
  
end
