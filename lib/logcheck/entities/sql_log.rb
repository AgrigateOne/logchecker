# frozen_string_literal: true

module LogcheckApp
  class SqlLog < Dry::Struct
    attribute :id, Types::Integer
    attribute :action_type, Types::String
    attribute :duration_in_ms, Types::Decimal
    attribute :duration_in_secs, Types::Decimal
    attribute :duration_in_minutes, Types::Decimal
    attribute :csv_row_no, Types::Integer
    attribute :sql_query, Types::String
    attribute :query_fingerprint, Types::String
    attribute :log_message, Types::String
    attribute :holding_process_id, Types::Integer
    attribute :waiting_process_id, Types::Integer
    attribute :holding_transaction_id, Types::Integer
    attribute :lock_wait_duration, Types::Decimal
    attribute :lock_acquired, Types::Bool
    attribute :lock_waiting, Types::Bool
    attribute :start_time, Types::DateTime
    attribute :time_stamp, Types::DateTime
    attribute :user_name, Types::String
    attribute :database_name, Types::String
    attribute :process_id, Types::Integer
    attribute :host_port, Types::String
    attribute :session_id, Types::String
    attribute :line_no, Types::Integer
    attribute :command_tag, Types::String
    attribute :session_start_time, Types::DateTime
    attribute :virtual_transaction_id, Types::String
    attribute :regular_transaction_id, Types::Integer
    attribute :error_severity, Types::String
    attribute :sqlstate_code, Types::Integer
    attribute :error_message, Types::String
    attribute :error_message_detail, Types::String
    attribute :hint, Types::String
    attribute :internal_query, Types::String
    attribute :char_cnt_int_query, Types::String
    attribute :error_context, Types::String
    attribute :user_query, Types::String
    attribute :char_cnt_usr_query, Types::String
    attribute :pg_err_loc, Types::String
    attribute :application_name, Types::String
  end
end
