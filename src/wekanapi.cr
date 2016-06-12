require "kemal"
require "./mongo.cr"
require "./wekanapi/*"
require "./config.cr"

module Wekanapi extend self

  macro reply_json(data, diag = 200)
    env.response.content_type = "application/json"
    env.response.status_code = {{diag}}
    {{data}}.to_json
  end

  macro reply_one(data)
    if {{data}}.empty?
      [] of BSON
    else
      {{data}}[0]
    end
  end

  macro url_param(name)
    URI.unescape(env.params.url[{{name}}] as String, true)
  end

  db = database

  get "/boards" do |env|
    collection_all db, "boards"
  end

  get "/board/:name" do |env|
    reply_one collection_find db, "boards", {"title" => url_param "name"}
  end

  get "/board/:name/lists" do |env|
    board = collection_find db, "boards", {"title" => url_param "name"}
    if board.empty?
      [] of BSON
    else
      collection_find db, "lists", {"boardId" => board[0]["_id"]}
    end
  end

  get "/board/:name/list/:list_name" do |env|
    board = collection_find db, "boards", {"title" => url_param "name"}
    if board.empty?
      [] of BSON
    else
      reply_one collection_find db, "lists", {"boardId" => board[0]["_id"], "title" => url_param "list_name"}
    end
  end

  get "/board/:name/list/:list_name/cards" do |env|
    board = collection_find db, "boards", {"title" => url_param "name"}
    if board.empty?
      [] of BSON
    else
      list = collection_find db, "lists", {"boardId" => board[0]["_id"], "title" => url_param "list_name"}
      if list.empty?
        [] of BSON
      else
        collection_find db, "cards", {"listId" => list[0]["_id"]}
      end
    end
  end

  get "/board/:name/list/:list_name/card/:card_name" do |env|
    board = collection_find db, "boards", {"title" => url_param "name"}
    if board.empty?
      [] of BSON
    else
      list = collection_find db, "lists", {"boardId" => board[0]["_id"], "title" => url_param "list_name"}
      if list.empty?
        [] of BSON
      else
        reply_one collection_find db, "cards", {"listId" => list[0]["_id"], "title" => url_param "card_name"}
      end
    end
  end

  get "/users" do |env|
    collection_all db, "users"
  end

  get "/user/:name" do |env|
    collection_find db, "users", {"username" => url_param "name"}
  end

  get "/user/:name/boards" do |env|
    user = collection_find db, "users", {"username" => url_param "name"}
    if user.empty?
      [] of BSON
    else
      user_id = user[0]["_id"]
      # Right now, embedded documents cause BSON to crash
      # collection_find db, "boards", {"members" => {"userId" => user_id}}
      reply = [] of BSON
      collection_all db, "boards" do |doc|
        (doc["members"] as BSON).each do |member|
          board_user_id = (member.value as BSON)["userId"]
          reply.push doc if user_id == board_user_id
        end
      end
      reply
    end
  end

  get "/user/:name/board/:board_name" do |env|
    user = collection_find db, "users", {"username" => url_param "name"}
    if user.empty?
      [] of BSON
    else
      user_id = user[0]["_id"]
      # Right now, embedded documents cause BSON to crash
      # collection_find db, "boards", {"members" => {"userId" => user_id}}
      reply = [] of BSON
      collection_find db, "boards", {"title" => url_param "board_name"} do |doc|
        (doc["members"] as BSON).each do |member|
          board_user_id = (member.value as BSON)["userId"]
          reply.push doc if user_id == board_user_id
        end
      end
      reply_one reply
    end
  end

end

Kemal.run
