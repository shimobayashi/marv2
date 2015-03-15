require 'mongoid'
require 'json'

class Settings
  include Mongoid::Document
  include Mongoid::Timestamps

  field :command, type: String
  field :threshold_low, type: Float
  field :threshold_high, type: Float

  scope :recent, ->{ desc(:created_at) }

  def to_hash
    {
      command: self.command,
      threshold: {
        low: self.threshold_low,
        high: self.threshold_high
      }
    }
  end

  def to_json
    JSON.generate(self.to_hash)
  end
end
