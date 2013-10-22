module ESIC
  class Request
    attr_reader :request_details_url,
                :protocol,
                :entity,
                :created_at,
                :expired_at,
                :state

    def initialize(request_details_url, protocol, entity, created_at, expired_at, state)
      @request_details_url = request_details_url
      @protocol = protocol
      @entity = entity
      @created_at = created_at
      @expired_at = expired_at
      @state = state
    end

    def to_s
      "#{protocol},#{entity},#{created_at},#{expired_at},#{state},#{request_details_url}"
    end
  end
end
