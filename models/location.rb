class Location < ActiveRecord::Base
  scope :day, -> (date) { where("moment >= ? and moment < ?",
                                date.to_time, date.to_time.tomorrow) }
  scope :today, -> { day(Date.today) }
end
