module Courier
  @@models = []

  def self.models=(models)
    @@models = models
  end

  def self.models
    @@models
  end
end
