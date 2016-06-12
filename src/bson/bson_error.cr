class BSON
  class BSONError < Exception
    getter domain, code, detail

    def initialize(bson_error)
      @domain = bson_error.value.domain as UInt32
      @code = bson_error.value.code as UInt32
      @detail = String.new bson_error.value.message.to_unsafe
      super("Domain: #{@domain}, code: #{@code}, #{@detail}")
    end
  end
end
