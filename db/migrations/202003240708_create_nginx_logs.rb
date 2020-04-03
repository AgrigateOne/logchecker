Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:nginx_logs, ignore_index_errors: true) do
      primary_key :id
      String :remote_addr, null: false
      String :remote_user
      Time :time_local, null: false
      String :method, null: false
      String :request, null: false
      String :http_version, null: false
      Integer :status, null: false
      Integer :bytes, null: false
      String :http_referer
      String :http_user_agent
      Decimal :request_time_in_ms
      Decimal :request_time_in_secs
      Decimal :request_time_in_minutes
      String :base_url
      String :params
      String :device
      Boolean :mobile, default: false
      Boolean :java_robot, default: false
      String :func_area
      String :prog_area
      String :dm_key
      String :url_fingerprint
      # 2533:192.168.9.56 - - [19/Mar/2020:08:59:04 +0200] "GET /messcada/rmt/bin_tipping/weighing?bin_number=SK122258559&gross_weight=398.0&measurement_unit=Kg&device=BTM-03 HTTP/1.1" 200 336 "-" "Java/1.8.0_144"

      # log_format combine_ext '$remote_addr - $remote_user [$time_local] '
      #                        '"$request" $status $body_bytes_sent '
      #                        '"$http_referer" "$http_user_agent"'
      #                        ' $request_time';
      # index [:code], name: :nginx_logs_unique_code, unique: true
    end
  end

  down do
    drop_table(:nginx_logs)
  end
end
