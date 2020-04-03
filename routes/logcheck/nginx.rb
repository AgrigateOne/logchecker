# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
class LogCheck < Roda
  route 'nginx', 'logcheck' do |r|
    # NGINX LOGS
    # --------------------------------------------------------------------------
    r.on 'nginx_logs', Integer do |id|
      interactor = LogcheckApp::NginxLogInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})

      # Check for notfound:
      r.on !interactor.exists?(:nginx_logs, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('nginx', 'edit')
        interactor.assert_permission!(:edit, id)
        show_partial { Logcheck::Nginx::NginxLog::Edit.call(id) }
      end

      r.is do
        r.get do       # SHOW
          check_auth!('nginx', 'read')
          show_partial { Logcheck::Nginx::NginxLog::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_nginx_log(id, params[:nginx_log])
          if res.success
            row_keys = %i[
              remote_addr
              remote_user
              time_local
              method
              request
              http_version
              status
              bytes
              http_referer
              http_user_agent
              request_time_in_ms
              request_time_in_secs
              request_time_in_minutes
              base_url
              params
              mobile
              java_robot
            ]
            update_grid_row(id, changes: select_attributes(res.instance, row_keys), notice: res.message)
          else
            re_show_form(r, res) { Logcheck::Nginx::NginxLog::Edit.call(id, form_values: params[:nginx_log], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('nginx', 'delete')
          interactor.assert_permission!(:delete, id)
          res = interactor.delete_nginx_log(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end

    r.on 'nginx_logs' do
      interactor = LogcheckApp::NginxLogInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
      r.on 'new' do    # NEW
        check_auth!('nginx', 'new')
        show_partial_or_page(r) { Logcheck::Nginx::NginxLog::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_nginx_log(params[:nginx_log])
        if res.success
          row_keys = %i[
            id
            remote_addr
            remote_user
            time_local
            method
            request
            http_version
            status
            bytes
            http_referer
            http_user_agent
            request_time_in_ms
            request_time_in_secs
            request_time_in_minutes
            base_url
            params
            mobile
            java_robot
          ]
          add_grid_row(attrs: select_attributes(res.instance, row_keys),
                       notice: res.message)
        else
          re_show_form(r, res, url: '/logcheck/nginx/nginx_logs/new') do
            Logcheck::Nginx::NginxLog::New.call(form_values: params[:nginx_log],
                                                form_errors: res.errors,
                                                remote: fetch?(r))
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
