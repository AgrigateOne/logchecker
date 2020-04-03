# frozen_string_literal: true

module UiRules
  class NginxLogRule < Base
    def generate_rules
      @repo = LogcheckApp::NginxLogRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if %i[show reopen].include? @mode
      # set_complete_fields if @mode == :complete
      # set_approve_fields if @mode == :approve

      # add_approve_behaviours if @mode == :approve

      form_name 'nginx_log'
    end

    def set_show_fields
      fields[:remote_addr] = { renderer: :label }
      fields[:remote_user] = { renderer: :label }
      fields[:time_local] = { renderer: :label, format: :without_timezone_or_seconds }
      fields[:method] = { renderer: :label }
      fields[:request] = { renderer: :label }
      fields[:http_version] = { renderer: :label }
      fields[:status] = { renderer: :label }
      fields[:bytes] = { renderer: :label }
      fields[:http_referer] = { renderer: :label }
      fields[:http_user_agent] = { renderer: :label }
      fields[:request_time_in_ms] = { renderer: :label }
      fields[:request_time_in_secs] = { renderer: :label }
      fields[:request_time_in_minutes] = { renderer: :label }
      fields[:base_url] = { renderer: :label }
      fields[:params] = { renderer: :label }
      fields[:mobile] = { renderer: :label, as_boolean: true }
      fields[:java_robot] = { renderer: :label, as_boolean: true }
    end

    # def set_approve_fields
    #   set_show_fields
    #   fields[:approve_action] = { renderer: :select, options: [%w[Approve a], %w[Reject r]], required: true }
    #   fields[:reject_reason] = { renderer: :textarea, disabled: true }
    # end

    # def set_complete_fields
    #   set_show_fields
    #   user_repo = DevelopmentApp::UserRepo.new
    #   fields[:to] = { renderer: :select, options: user_repo.email_addresses(user_email_group: AppConst::EMAIL_GROUP_NGINX_LOG_APPROVERS), caption: 'Email address of person to notify', required: true }
    # end

    def common_fields
      {
        remote_addr: { required: true },
        remote_user: {},
        time_local: { required: true },
        method: { required: true },
        request: { required: true },
        http_version: { required: true },
        status: { required: true },
        bytes: { required: true },
        http_referer: {},
        http_user_agent: {},
        request_time_in_ms: {},
        request_time_in_secs: {},
        request_time_in_minutes: {},
        base_url: {},
        params: {},
        mobile: { renderer: :checkbox },
        java_robot: { renderer: :checkbox }
      }
    end

    def make_form_object
      if @mode == :new
        make_new_form_object
        return
      end

      @form_object = @repo.find_nginx_log(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(remote_addr: nil,
                                    remote_user: nil,
                                    time_local: nil,
                                    method: nil,
                                    request: nil,
                                    http_version: nil,
                                    status: nil,
                                    bytes: nil,
                                    http_referer: nil,
                                    http_user_agent: nil,
                                    request_time_in_ms: nil,
                                    request_time_in_secs: nil,
                                    request_time_in_minutes: nil,
                                    base_url: nil,
                                    params: nil,
                                    mobile: nil,
                                    java_robot: nil)
    end

    # private

    # def add_approve_behaviours
    #   behaviours do |behaviour|
    #     behaviour.enable :reject_reason, when: :approve_action, changes_to: ['r']
    #   end
    # end
  end
end
