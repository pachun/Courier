module Courier
  class Base < CoreData::Model

    def self.client
      url = Courier.instance.url
      h = headers
      @client ||= AFMotion::Client.build(url) do
        h.each{ |k, v| header "#{k}", "#{v}" }
        response_serializer :json
      end
    end

    def self.headers
      {}
    end

    def self.find_all(&block)
      fetch_location(endpoint:collection_url, &block)
    end

    def self.fetch_location(fetch_params, &block)
      client.get(fetch_params[:endpoint]) do |result|
        if result.success?
          fetch_params[:json] = result.object
          conflicts = curate_conflicts(fetch_params)
          default_merge_group(conflicts)
          block.call(response: result, conflicts: conflicts)
        else
          block.call(response: result)
        end
      end
    end

    def self.default_merge_group(conflicts)
      if @policy == :overwrite_local
        conflicts.each{ |c| c[:foreign].merge! }
      end
    end

    # Deprecated vv
    def self._compare_local_collection_to_fetched_collection(fetch_params, &block)
      block.call( curate_conflicts(fetch_params) )
    end
    # Deprecated ^^

    def self.curate_conflicts(fetch_params)
      conflicts = fetch_params[:json].map do |foreign_resource_json|
        foreign_resource = create_in_new_context
        bind(foreign_resource, to: fetch_params[:owner_instance], as: fetch_params[:relation_name])
        save_json(foreign_resource_json, to: foreign_resource)
        local_resource = foreign_resource.main_context_match
        {local: local_resource, foreign: foreign_resource}
      end
    end

    def self.bind(related_resource, to: owner, as: relation_name)
      unless owner.nil?
        related_resource.merge_relationships << {relation: "#{relation_name}=", relative: owner}
      end
    end

    def self.find(args = {}, &block)
      fetched_resource = create_in_new_context
      individual_url = fetched_resource.individual_url(args)
      client.get(individual_url) do |result|
        if result.success?
          json = result.object
          save_json(json, to:fetched_resource)
          resource = default_merge_single(fetched_resource)
          block.call(response: result, resource: resource)
        else
          block.call(response: result)
        end
      end
    end

    def self.default_merge_single(resource)
      if @policy == :overwrite_local
        resource.merge!
        resource.main_context_match
      else
        resource
      end
    end

    def push(&block)
      AFMotion::Client.shared.post(individual_url, post_parameters) do |result|
        block.call(result)
      end
    end

    def self.save_json(json, to:instance)
      json_to_local.keys.each do |json_key|
        if json.has_key?(json_key.to_s)
          local_key = json_to_local[json_key]
          instance.send("#{local_key}=", json[json_key.to_s])
        end
      end
    end
  end
end
