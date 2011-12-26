class Route
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name
  field :destination
  embeds_many :ratings
  embeds_many :waypoints
  embeds_one :itn_file
  embeds_many :jumps
  validates_presence_of :name, :destination
end
