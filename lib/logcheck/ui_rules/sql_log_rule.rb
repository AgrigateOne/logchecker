# frozen_string_literal: true

module UiRules
  class SqlLogRule < Base
    def generate_rules
      @repo = LogcheckApp::SqlLogRepo.new
      make_form_object

      set_show_fields

      form_name 'sql_log'
    end

    def set_show_fields # rubocop:disable Metrics/AbcSize
      fields[:action_type] = { renderer: :label }
      fields[:duration_in_ms] = { renderer: :label, with_value: UtilityFunctions.delimited_number(@form_object.duration_in_ms, no_decimals: 3) }
      fields[:duration_in_secs] = { renderer: :label, with_value: UtilityFunctions.delimited_number(@form_object.duration_in_secs) }
      fields[:duration_in_minutes] = { renderer: :label, with_value: UtilityFunctions.delimited_number(@form_object.duration_in_minutes) }
      fields[:csv_row_no] = { renderer: :label }
      fields[:sql_query] = { renderer: :label } # text, SQL
      fields[:query_fingerprint] = { renderer: :label }
      fields[:log_message] = { renderer: :label }
      fields[:waiting_process_id] = { renderer: :label }
      fields[:holding_process_id] = { renderer: :label }
      fields[:holding_transaction_id] = { renderer: :label }
      fields[:lock_wait_duration] = { renderer: :label }
      fields[:lock_acquired] = { renderer: :label, as_boolean: true }
      fields[:lock_waiting] = { renderer: :label, as_boolean: true }
      fields[:start_time] = { renderer: :label }
      fields[:time_stamp] = { renderer: :label }
      fields[:user_name] = { renderer: :label }
      fields[:database_name] = { renderer: :label }
      fields[:process_id] = { renderer: :label }
      fields[:host_port] = { renderer: :label }
      fields[:session_id] = { renderer: :label }
      fields[:line_no] = { renderer: :label }
      fields[:command_tag] = { renderer: :label }
      fields[:session_start_time] = { renderer: :label }
      fields[:virtual_transaction_id] = { renderer: :label }
      fields[:regular_transaction_id] = { renderer: :label }
      fields[:error_severity] = { renderer: :label }
      fields[:sqlstate_code] = { renderer: :label }
      fields[:error_message] = { renderer: :label }
      fields[:error_message_detail] = { renderer: :label }
      fields[:hint] = { renderer: :label }
      fields[:internal_query] = { renderer: :label }
      fields[:char_cnt_int_query] = { renderer: :label }
      fields[:error_context] = { renderer: :label }
      fields[:user_query] = { renderer: :label }
      fields[:char_cnt_usr_query] = { renderer: :label }
      fields[:pg_err_loc] = { renderer: :label }
      fields[:application_name] = { renderer: :label }
    end

    def make_form_object
      @form_object = @repo.find_sql_log(@options[:id])
    end
  end
end
