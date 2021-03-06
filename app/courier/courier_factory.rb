module Courier
  class Factory
    def self.create(class_as_symbol, opts={})
      class_as_string = class_as_symbol.to_s
      capitalized_class_as_string = class_as_string.capitalize_first
      capitalized_class_as_string.constantize.create.tap do |o|
        opts.each do |k, v|
          if o.respond_to?("#{k}=")
            o.public_send("#{k}=", v)
          end
        end
      end
    end
  end
end
