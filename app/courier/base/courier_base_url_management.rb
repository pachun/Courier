module Courier
  class Base < CoreData::Model
    @individual_path = ""
    @collection_path = ""
    @json_to_local = ""

    def self.individual_path=(path)
      @individual_path = path
    end

    def self.collection_path=(path)
      @collection_path = path
    end

    def self.json_to_local=(mapping)
      @json_to_local = default_json_to_local
      @json_to_local.delete_if{ |_,v| mapping.has_value?(v) }
      @json_to_local.merge!(mapping)
    end

    def self.individual_path
      @individual_path
    end

    def self.collection_path
      @collection_path
    end

    def self.json_to_local
      @json_to_local || default_json_to_local
    end

    def self.default_json_to_local
      properties.map(&:name).inject({}){ |h, a| h[a.to_sym] = a.to_sym; h }
    end

    def individual_url(args = {})
      handle = true_class.individual_path.split("/").map do |peice|
                process(peice, args)
              end.join("/")
      Courier.instance.url + "/" + handle
    end

    def self.collection_url
      [Courier.instance.url, collection_path].join("/")
    end

    # self.json_to_local = {id: :id, userId: :user_id, title: :title, body: :body}#@json_to_local_hash

    def post_parameters
      {}.tap do |params|
        true_class.json_to_local.keys.map do |json_key|
          local_key = true_class.json_to_local[json_key]
          attribute_value = send("#{local_key}")
          params[json_key] = attribute_value unless attribute_value.nil?
        end
      end
    end

    private

    def process(peice, args)
      if peice[0] == ":"

        replacable =peice[1..-1].to_sym
        if args.has_key?(replacable)
          args[replacable]
        else
          self.send(replacable)
        end

      else
        peice
      end
    end
  end
end
