# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength
class LogCheck < Roda
  route 'sql', 'logcheck' do |r|
    # SQL LOGS
    # --------------------------------------------------------------------------
    r.on 'sql_logs', Integer do |id|
      interactor = LogcheckApp::SqlLogInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:sql_logs, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('sql', 'edit')
        interactor.assert_permission!(:edit, id)
        show_partial { Logcheck::Sql::SqlLog::Edit.call(id) }
      end

      r.is do
        r.get do       # SHOW
          check_auth!('sql', 'read')
          show_partial { Logcheck::Sql::SqlLog::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_sql_log(id, params[:sql_log])
          if res.success
            row_keys = %i[
              action_type
              duration_in_ms
              duration_in_minutes
              csv_row_no
              sql_query
              log_message
              waiting_process_id
              holding_transaction_id
              lock_wait_duration
              lock_aquired
              lock_waiting
              time_stamp
              user_name
              database_name
              process_id
              host_port
              session_id
              line_no
              command_tag
              session_start_time
              virtual_transaction_id
              regular_transaction_id
              error_severity
              sqlstate_code
              error_message
              error_message_detail
              hint
              internal_query
              char_cnt_int_query
              error_context
              user_query
              char_cnt_usr_query
              pg_err_loc
              application_name
            ]
            update_grid_row(id, changes: select_attributes(res.instance, row_keys), notice: res.message)
          else
            re_show_form(r, res) { Logcheck::Sql::SqlLog::Edit.call(id, form_values: params[:sql_log], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('sql', 'delete')
          interactor.assert_permission!(:delete, id)
          res = interactor.delete_sql_log(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end

    r.on 'sql_logs' do
      interactor = LogcheckApp::SqlLogInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do    # NEW
        check_auth!('sql', 'new')
        show_partial_or_page(r) { Logcheck::Sql::SqlLog::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_sql_log(params[:sql_log])
        if res.success
          row_keys = %i[
            id
            action_type
            duration_in_ms
            duration_in_minutes
            csv_row_no
            sql_query
            log_message
            waiting_process_id
            holding_transaction_id
            lock_wait_duration
            lock_aquired
            lock_waiting
            time_stamp
            user_name
            database_name
            process_id
            host_port
            session_id
            line_no
            command_tag
            session_start_time
            virtual_transaction_id
            regular_transaction_id
            error_severity
            sqlstate_code
            error_message
            error_message_detail
            hint
            internal_query
            char_cnt_int_query
            error_context
            user_query
            char_cnt_usr_query
            pg_err_loc
            application_name
          ]
          add_grid_row(attrs: select_attributes(res.instance, row_keys),
                       notice: res.message)
        else
          re_show_form(r, res, url: '/logcheck/sql/sql_logs/new') do
            Logcheck::Sql::SqlLog::New.call(form_values: params[:sql_log],
                                            form_errors: res.errors,
                                            remote: fetch?(r))
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/BlockLength
