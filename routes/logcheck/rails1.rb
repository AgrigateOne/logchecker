# frozen_string_literal: true

class LogCheck < Roda
  route 'rails1', 'logcheck' do |r|
    # RAILS1 LOGS
    # --------------------------------------------------------------------------
    r.on 'rails1_logs', Integer do |id|
      interactor = LogcheckApp::Rails1LogInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:rails1_logs, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('rails1', 'edit')
        interactor.assert_permission!(:edit, id)
        show_partial { Logcheck::Rails1::Rails1Log::Edit.call(id) }
      end

      # r.on 'complete' do
      #   r.get do
      #     check_auth!('rails1', 'edit')
      #     interactor.assert_permission!(:complete, id)
      #     show_partial { Logcheck::Rails1::Rails1Log::Complete.call(id) }
      #   end

      #   r.post do
      #     res = interactor.complete_a_rails1_log(id, params[:rails1_log])
      #     if res.success
      #       flash[:notice] = res.message
      #       redirect_to_last_grid(r)
      #     else
      #       re_show_form(r, res) { Logcheck::Rails1::Rails1Log::Complete.call(id, params[:rails1_log], res.errors) }
      #     end
      #   end
      # end

      # r.on 'approve' do
      #   r.get do
      #     check_auth!('rails1', 'approve')
      #     interactor.assert_permission!(:approve, id)
      #     show_partial { Logcheck::Rails1::Rails1Log::Approve.call(id) }
      #   end

      #   r.post do
      #     res = interactor.approve_or_reject_a_rails1_log(id, params[:rails1_log])
      #     if res.success
      #       flash[:notice] = res.message
      #       redirect_to_last_grid(r)
      #     else
      #       re_show_form(r, res) { Logcheck::Rails1::Rails1Log::Approve.call(id, params[:rails1_log], res.errors) }
      #     end
      #   end
      # end

      # r.on 'reopen' do
      #   r.get do
      #     check_auth!('rails1', 'edit')
      #     interactor.assert_permission!(:reopen, id)
      #     show_partial { Logcheck::Rails1::Rails1Log::Reopen.call(id) }
      #   end

      #   r.post do
      #     res = interactor.reopen_a_rails1_log(id, params[:rails1_log])
      #     if res.success
      #       flash[:notice] = res.message
      #       redirect_to_last_grid(r)
      #     else
      #       re_show_form(r, res) { Logcheck::Rails1::Rails1Log::Reopen.call(id, params[:rails1_log], res.errors) }
      #     end
      #   end
      # end

      r.is do
        r.get do       # SHOW
          check_auth!('rails1', 'read')
          show_partial { Logcheck::Rails1::Rails1Log::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_rails1_log(id, params[:rails1_log])
          if res.success
            row_keys = %i[
              approximate_time
              log_file
              line_no
              duration_in_ms
              duration_in_secs
              duration_in_minutes
              approximate_end_time
              render_time_ms
              render_time_secs
              render_time_minutes
              render_percent
              db_time_ms
              db_time_secs
              db_time_minutes
              db_percent
              status
              host
              functional_area
              controller
              action
              params
              queryparams
              sessionid
            ]
            update_grid_row(id, changes: select_attributes(res.instance, row_keys), notice: res.message)
          else
            re_show_form(r, res) { Logcheck::Rails1::Rails1Log::Edit.call(id, form_values: params[:rails1_log], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('rails1', 'delete')
          interactor.assert_permission!(:delete, id)
          res = interactor.delete_rails1_log(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end

    r.on 'rails1_logs' do
      interactor = LogcheckApp::Rails1LogInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do    # NEW
        check_auth!('rails1', 'new')
        show_partial_or_page(r) { Logcheck::Rails1::Rails1Log::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_rails1_log(params[:rails1_log])
        if res.success
          row_keys = %i[
            id
            approximate_time
            log_file
            line_no
            duration_in_ms
            duration_in_secs
            duration_in_minutes
            approximate_end_time
            render_time_ms
            render_time_secs
            render_time_minutes
            render_percent
            db_time_ms
            db_time_secs
            db_time_minutes
            db_percent
            status
            host
            functional_area
            controller
            action
            params
            queryparams
            sessionid
          ]
          add_grid_row(attrs: select_attributes(res.instance, row_keys),
                       notice: res.message)
        else
          re_show_form(r, res, url: '/logcheck/rails1/rails1_logs/new') do
            Logcheck::Rails1::Rails1Log::New.call(form_values: params[:rails1_log],
                                                  form_errors: res.errors,
                                                  remote: fetch?(r))
          end
        end
      end
    end
  end
end
