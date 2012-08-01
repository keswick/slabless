class RouteAuthorizer < ApplicationAuthorizer
  def self.creatable_by?(user)
    # must be logged in to create records
    user.signed_in?
  end

  def deletable_by?(user)
    resource.owner_id == user.id
  end

  def readable_by?(user)
    resource.visibility == "private" ? resource.owner_id == user.id : true
  end  
  
  def updatable_by?(user)
    resource.owner_id == user.id
  end
  
  def self.default(adjective, user)
    # 'Whitelist' strategy for security: anything not explicitly allowed is
    # considered forbidden.
    debugger
    false
  end  
  
end