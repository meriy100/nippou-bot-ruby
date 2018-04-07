require 'active_record'
class User < ActiveRecord::Base
  validates :slack_user, uniqueness: true
end
