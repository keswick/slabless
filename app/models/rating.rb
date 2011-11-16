class Rating
  include Mongoid::Document
  field :comment
  field :overall, :type => Integer
  embedded_in :route, :inverse_of => :ratings
end
