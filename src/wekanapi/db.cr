module Wekanapi extend self

  private def database
    cfg = CONFIG["database"] as Hash
    client = Mongo::Client.new "mongodb://#{cfg["user"]}:#{cfg["password"]}@#{cfg["host"]}:#{cfg["port"]}/#{cfg["name"]}?authSource=admin"
    (client["wekan"] as Mongo::Database).not_nil!
  end

  def collection(db, name)
    db[name]
  end

  def collection_find(db, name, query, &block)
    collection(db, name).find(query) do |doc|
      yield doc
    end
  end

  def collection_find(db, name, query)
    reply = [] of BSON
    collection_find(db, name, query) do |doc|
      reply.push doc
    end
    reply
  end

  def collection_all(db, name, &block)
    collection_find(db, name, {} of String => String) do |doc|
      yield doc
    end
  end

  def collection_all(db, name)
    collection_find db, name, {} of String => String
  end
end
