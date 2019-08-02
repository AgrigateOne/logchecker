# frozen_string_literal: true

module LogcheckApp
  class Rails1LogRepo < BaseRepo
    build_for_select :rails1_logs,
                     label: :log_file,
                     value: :id,
                     no_active_check: true,
                     order_by: :log_file

    crud_calls_for :rails1_logs, name: :rails1_log, wrapper: Rails1Log
  end
end
