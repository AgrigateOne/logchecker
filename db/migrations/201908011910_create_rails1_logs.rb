Sequel.migration do
  up do
    create_table(:rails1_logs, ignore_index_errors: true) do
      primary_key :id
      Time :approximate_time
      String :log_file
      String :line_no
      Decimal :duration_in_ms
      Decimal :duration_in_secs
      Decimal :duration_in_minutes
      Time :approximate_end_time
      Decimal :render_time_ms
      Decimal :render_time_secs
      Decimal :render_time_minutes
      Integer :render_percent
      Decimal :db_time_ms
      Decimal :db_time_secs
      Decimal :db_time_minutes
      Integer :db_percent
      String :status
      String :host
      String :functional_area
      String :controller
      String :action
      String :params
      String :queryparams
      String :sessionid
      #
      # index [:code], name: :rails1_logs_unique_code, unique: true
    end
  end

  down do
    drop_table(:rails1_logs)
  end
end
