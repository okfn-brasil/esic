module ESIC
  class PublicBody
    attr_reader :id, :name, :superior_public_body

    def initialize(id, name, superior_public_body=nil)
      @id = id
      @name = name
      @superior_public_body = superior_public_body
    end
  end
end
