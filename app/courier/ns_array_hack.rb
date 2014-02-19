# Had to pollute NSArray here for chaining scoped calls
class NSArray < NSObject
  def where(scope)
    fetch = NSFetchRequest.fetchRequestWithEntityName(first.true_class.to_s)
    fetch.setPredicate(scope)
    error = Pointer.new(:object)
    results = filteredArrayUsingPredicate(scope)
    puts "Error searching for #{scope.predicateFormat}: #{error[0]}" unless error[0].nil?
    results
  end
end
