class Score < ActiveRecord::Base
  validates_presence_of :processor, :message => "can't be blank"
  validates_presence_of :score, :message => "can't be blank"
  validates_presence_of :relative_time, :message => "can't be blank"
end
