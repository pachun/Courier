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

    def self.and(*predicates)
      NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
    end

    def self.or(*predicates)
      NSCompoundPredicate.orPredicateWithSubpredicates(predicates)
    end

    def self.inverse(predicate)
      NSCompoundPredicate.notPredicateWithSubpredicate(predicate)
    end
  end
end
