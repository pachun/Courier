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
      @json_to_local = mapping
    end

    def self.individual_path
      @individual_path
    end

    def self.collection_path
      @collection_path
    end

    def self.json_to_local
      @json_to_local
    end

    def individual_url
      handle =
        true_class.individual_path.split("/").map do |peice|
          if peice[0] == ":"
            self.send(peice[1..-1].to_sym)
          else
            peice
          end
        end.join("/")
        [Courier.instance.url, handle].join("/")
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
  end
end
