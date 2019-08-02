# frozen_string_literal: true

module LogcheckApp
  class Rails1Log < Dry::Struct
    attribute :id, Types::Integer
    attribute :approximate_time, Types::DateTime
    attribute :log_file, Types::String
    attribute :line_no, Types::String
    attribute :duration_in_ms, Types::Decimal
    attribute :duration_in_secs, Types::Decimal
    attribute :duration_in_minutes, Types::Decimal
    attribute :approximate_end_time, Types::DateTime
    attribute :render_time_ms, Types::Decimal
    attribute :render_time_secs, Types::Decimal
    attribute :render_time_minutes, Types::Decimal
    attribute :render_percent, Types::Integer
    attribute :db_time_ms, Types::Decimal
    attribute :db_time_secs, Types::Decimal
    attribute :db_time_minutes, Types::Decimal
    attribute :db_percent, Types::Integer
    attribute :status, Types::String
    attribute :host, Types::String
    attribute :functional_area, Types::String
    attribute :controller, Types::String
    attribute :action, Types::String
    attribute :params, Types::String
    attribute :queryparams, Types::String
    attribute :sessionid, Types::String
  end
end
