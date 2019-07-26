# frozen_string_literal: true

module LogcheckApp
  class SqlLogRepo < BaseRepo
    build_for_select :sql_logs,
                     label: :action_type,
                     value: :id,
                     no_active_check: true,
                     order_by: :action_type

    crud_calls_for :sql_logs, name: :sql_log, wrapper: SqlLog
  end
end
