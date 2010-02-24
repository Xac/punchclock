class Category < ActiveRecord::Base
  has_many :ins
  has_many :outs
  
  validates_uniqueness_of :name
  
  def name_with_id
    "#{id.to_s.rjust(3,"0")}: #{name}"
  end
end
