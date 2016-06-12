class BSON
  struct ArrayAppender
    def initialize(@bson : BSON)
      @count = 0
    end

    def <<(value)
      @bson[@count.to_s] = value
      @count += 1
      self
    end
  end
end
