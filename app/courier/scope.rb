module Courier
  module Scope
    def self.where(attribute, is: value)
      NSPredicate.predicateWithFormat("#{attribute} == #{value}")
    end

    def self.where(attribute, is_greater_than: value)
      NSPredicate.predicateWithFormat("#{attribute} > #{value}")
    end

    def self.where(attribute, is_greater_than_or_equal_to: value)
      NSPredicate.predicateWithFormat("#{attribute} >= #{value}")
    end

    def self.where(attribute, is_less_than: value)
      NSPredicate.predicateWithFormat("#{attribute} < #{value}")
    end

    def self.where(attribute, is_less_than_or_equal_to: value)
      NSPredicate.predicateWithFormat("#{attribute} <= #{value}")
    end

    def self.where(attribute, isnt: value)
      NSPredicate.predicateWithFormat("#{attribute} != #{value}")
    end

    def self.where(attribute, is_in: range)
      range = "{" + range.join(", ") + "}"
      NSPredicate.predicateWithFormat("#{attribute} BETWEEN #{range}")
    end

    def self.where(attribute, begins_with: value)
      NSPredicate.predicateWithFormat("#{attribute} BEGINSWITH \"#{value}\"")
    end

    def self.where(attribute, ends_with: value)
      NSPredicate.predicateWithFormat("#{attribute} ENDSWITH \"#{value}\"")
    end

    def self.where(attribute, contains: value)
      NSPredicate.predicateWithFormat("#{attribute} CONTAINS \"#{value}\"")
    end

    def self.where(attribute, is_similar_to: value)
      NSPredicate.predicateWithFormat("#{attribute} LIKE \"#{value}\"")
    end

    def self.where(attribute, fits: value)
      NSPredicate.predicateWithFormat("#{attribute} MATCHES \"#{value}\"")
    end

    def self.where(attribute, is_any_of: options)
      options = "{" + options.map{ |o| '"' + o + '"' }.join(',') + "}"
      NSPredicate.predicateWithFormat("#{attribute} IN #{options}")
    end

    def self.and(predicates)
      NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
    end

    def self.or(predicates)
      NSCompoundPredicate.orPredicateWithSubpredicates(predicates)
    end

    def self.inverse(predicate)
      NSCompoundPredicate.notPredicateWithSubpredicate(predicate)
    end

    def self.from_string(s)
      parts = s.split(" ")
      attribute = parts[0]
      comparison = parts[1]
      value = parts[2..-1].join(" ")
      case(comparison)
      when "is"
        self.where(attribute, is:value)
      when ">"
        self.where(attribute, is_greater_than:value)
      when ">="
        self.where(attribute, is_greater_than_or_equal_to:value)
      when "<"
        self.where(attribute, is_less_than:value)
      when "<="
        self.where(attribute, is_less_than_or_equal_to:value)
      when "isnt"
        self.where(attribute, isnt:value)
      when "is_in"
        range = value[1..-2].split(",")
        self.where(attribute, is_in:range)
      when "begins_with"
        self.where(attribute, begins_with:value)
      when "ends_with"
        self.where(attribute, ends_with:value)
      when "contains"
        self.where(attribute, contains:value)
      when "is_similar_to"
        self.where(attribute, is_similar_to:value)
      when "fits"
        self.where(attribute, fits:value)
      when "is_any_of"
        options = value[1..-2].split(",")
        # options.map!{ |o| o = o[1,-2] } if options.first.class == String
        self.where(attribute, is_any_of:options)
      end
    end

    def self.from_structure(s)
      if s.class.to_s[0..1] == "NS"
        return s
      elsif s.class == String
        return self.from_string(s)
      elsif s.class == {}.class
        if s.keys.first == :and
          subpredicates = s[:and].map{ |p| self.from_structure(p) }
          return self.and( subpredicates )
        elsif s.keys.first == :or
          return self.or( s[:or].map{ |p| self.from_structure(p)} )
        elsif s.keys.first == :inverse
          return self.inverse( self.from_structure(s[:inverse]) )
        end
      end
    end
  end
end
