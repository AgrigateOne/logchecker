# frozen_string_literal: true

module LogcheckApp
  class NginxLogRepo < BaseRepo
    build_for_select :nginx_logs,
                     label: :remote_addr,
                     value: :id,
                     no_active_check: true,
                     order_by: :remote_addr

    crud_calls_for :nginx_logs, name: :nginx_log, wrapper: NginxLog

    def truncate(table_name)
      DB[table_name].truncate
    end
  end
end
