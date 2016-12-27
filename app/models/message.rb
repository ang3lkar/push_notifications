class Message < ApplicationRecord
  validates_presence_of :title, :text

  attr_accessor :key
  attr_accessor :value
end
