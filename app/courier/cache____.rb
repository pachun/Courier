class Cache____ < Courier::Base
  property :resource_path, String, required: true, key: true
  property :last_refresh, String

  def self.find_or_create(path)
    scope = Courier::Scope.where(:resource_path, is:path)
    tuple = where(scope).first
    return tuple unless tuple.nil?

    create.tap do |tuple|
      tuple.resource_path = path
      tuple.last_refresh = nil
      tuple.save
    end
  end
end
