require 'pstore'

class Base
  DB_FILE = File.expand_path("../../../db.pstore", __FILE__)


  module ClassMethods
    def find(id)
      db.transaction(true) do
        db[derive_db_id(self.name, id)]
      end

    end

    def all
      db.transaction(true) do
        ids = extract_model_ids(db)
        ids.map { |key| db[key] }
      end
    end

    def save(object)
      db_id = derive_db_id(object.class.name, object.id)
      db.transaction do
        db[db_id] = object
      end
    end

    def next_available_id
      last_id = all_ids.map do |key|
        key.sub("#{self.name}_", "").to_i
      end.max.to_i

      last_id + 1
    end
    
    private

    def db
      @db ||= PStore.new(DB_FILE)
    end
    
    def derive_db_id(model_name, obj_id)
      "#{model_name}_#{obj_id}"
    end

    def all_ids
      db.transaction(true) do |db|
        extract_model_ids(db)
      end
    end

    def extract_model_ids(store)
      store.roots.select do |key|
        key.start_with?(self.name)
      end
    end

  end
  extend ClassMethods

  def save
    ensure_presence_of_id
    self.class.save(self)
  end

  private

  def ensure_presence_of_id
    self.id ||= self.class.next_available_id
  end
end