class Constellation < ActiveRecord::Base
  has_many :hip_stars
  has_many :ngcic_dsos
end
