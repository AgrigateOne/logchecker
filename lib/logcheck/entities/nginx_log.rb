# frozen_string_literal: true

module LogcheckApp
  class NginxLog < Dry::Struct
    attribute :id, Types::Integer
    attribute :remote_addr, Types::String
    attribute :remote_user, Types::String
    attribute :time_local, Types::DateTime
    attribute :method, Types::String
    attribute :request, Types::String
    attribute :http_version, Types::String
    attribute :status, Types::Integer
    attribute :bytes, Types::Integer
    attribute :http_referer, Types::String
    attribute :http_user_agent, Types::String
    attribute :request_time_in_ms, Types::Decimal
    attribute :request_time_in_secs, Types::Decimal
    attribute :request_time_in_minutes, Types::Decimal
    attribute :base_url, Types::String
    attribute :params, Types::String
    attribute :mobile, Types::Bool
    attribute :java_robot, Types::Bool
  end
end
