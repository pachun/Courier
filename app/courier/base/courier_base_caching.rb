module Courier
  class Base < CoreData::Model
    def self.cache_policy(keep_time)
      @keep_time = keep_time
    end

    def self.cached_counterpart(args)
      string_scopes = keys.inject([]) do |a, k|
        a << "#{k} is #{args[k]}"
      end
      string_scopes = {and: string_scopes} if string_scopes.count > 1
      counterpart_scope = Scope.from_structure(string_scopes)
      where(counterpart_scope).first
    end

    def self.expired?(cache)
      return true if cache.last_refresh.nil?
      formatter = NSDateFormatter.new
      formatter.dateFormat = "yyyy-MM-dd HH-mm-ss ZZZ"
      expiration_date = formatter.dateFromString(cache.last_refresh) + @keep_time
      if expiration_date > NSDate.new
        false
      else
        true
      end
    end
  end
end
