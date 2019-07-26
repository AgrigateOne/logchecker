Sequel.migration do
  up do
    create_table(:sql_logs, ignore_index_errors: true) do
      primary_key :id
      # Decorated entries:
      String :action_type
      Decimal :duration_in_ms
      Decimal :duration_in_secs
      Decimal :duration_in_minutes
      Time :start_time
      Integer :csv_row_no
      String :sql_query
      String :log_message
      String :query_fingerprint

      # Sharelock stats
      Integer :waiting_process_id
      Integer :holding_process_id
      Integer :holding_transaction_id
      Decimal :lock_wait_duration
      TrueClass :lock_acquired, default: false
      TrueClass :lock_waiting, default: false

      # PG csv dump:
      Time :time_stamp # headers = ['time stamp with milliseconds',
      String :user_name #            'user name',
      String :database_name #            'database name',
      Integer :process_id #            'process ID',
      String :host_port #            'client host:port number',
      String :session_id #            'session ID',
      Integer :line_no #            'per-session line number',
      String :command_tag #            'command tag',
      Time :session_start_time #            'session start time',
      String :virtual_transaction_id #            'virtual transaction ID',
      Integer :regular_transaction_id #            'regular transaction ID',
      String :error_severity #            'error severity',
      Integer :sqlstate_code #            'SQLSTATE code',
      String :error_message #            'error message',
      String :error_message_detail #            'error message detail',
      String :hint #            'hint',
      String :internal_query #            'internal query that led to the error (if any)',
      String :char_cnt_int_query #            'character count of the error position therein',
      String :error_context #            'error context',
      String :user_query #            'user query that led to the error (if any and enabled by log_min_error_statement)',
      String :char_cnt_usr_query #            'character count of the error position therein',
      String :pg_err_loc #            'location of the error in the PostgreSQL source code (if log_error_verbosity is set to verbose)',
      String :application_name #            'application name']
      #
      # index [:code], name: :sql_logs_unique_code, unique: true
    end
  end

  down do
    drop_table(:sql_logs)
  end
end
