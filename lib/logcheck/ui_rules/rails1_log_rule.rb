# frozen_string_literal: true

module UiRules
  class Rails1LogRule < Base
    def generate_rules
      @repo = LogcheckApp::Rails1LogRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if %i[show reopen].include? @mode
      # set_complete_fields if @mode == :complete
      # set_approve_fields if @mode == :approve

      # add_approve_behaviours if @mode == :approve

      form_name 'rails1_log'
    end

    def set_show_fields
      fields[:approximate_time] = { renderer: :label }
      fields[:log_file] = { renderer: :label }
      fields[:line_no] = { renderer: :label }
      fields[:duration_in_ms] = { renderer: :label }
      fields[:duration_in_secs] = { renderer: :label }
      fields[:duration_in_minutes] = { renderer: :label }
      fields[:approximate_end_time] = { renderer: :label }
      fields[:render_time_ms] = { renderer: :label }
      fields[:render_time_secs] = { renderer: :label }
      fields[:render_time_minutes] = { renderer: :label }
      fields[:render_percent] = { renderer: :label }
      fields[:db_time_ms] = { renderer: :label }
      fields[:db_time_secs] = { renderer: :label }
      fields[:db_time_minutes] = { renderer: :label }
      fields[:db_percent] = { renderer: :label }
      fields[:status] = { renderer: :label }
      fields[:host] = { renderer: :label }
      fields[:functional_area] = { renderer: :label }
      fields[:controller] = { renderer: :label }
      fields[:action] = { renderer: :label }
      fields[:params] = { renderer: :label }
      fields[:queryparams] = { renderer: :label }
      fields[:sessionid] = { renderer: :label }
    end

    # def set_approve_fields
    #   set_show_fields
    #   fields[:approve_action] = { renderer: :select, options: [%w[Approve a], %w[Reject r]], required: true }
    #   fields[:reject_reason] = { renderer: :textarea, disabled: true }
    # end

    # def set_complete_fields
    #   set_show_fields
    #   user_repo = DevelopmentApp::UserRepo.new
    #   fields[:to] = { renderer: :select, options: user_repo.email_addresses(user_email_group: AppConst::EMAIL_GROUP_RAILS1_LOG_APPROVERS), caption: 'Email address of person to notify', required: true }
    # end

    def common_fields
      {
        approximate_time: {},
        log_file: {},
        line_no: {},
        duration_in_ms: {},
        duration_in_secs: {},
        duration_in_minutes: {},
        approximate_end_time: {},
        render_time_ms: {},
        render_time_secs: {},
        render_time_minutes: {},
        render_percent: {},
        db_time_ms: {},
        db_time_secs: {},
        db_time_minutes: {},
        db_percent: {},
        status: {},
        host: {},
        functional_area: {},
        controller: {},
        action: {},
        params: {},
        queryparams: {},
        sessionid: {}
      }
    end

    def make_form_object
      if @mode == :new
        make_new_form_object
        return
      end

      @form_object = @repo.find_rails1_log(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(approximate_time: nil,
                                    log_file: nil,
                                    line_no: nil,
                                    duration_in_ms: nil,
                                    duration_in_secs: nil,
                                    duration_in_minutes: nil,
                                    approximate_end_time: nil,
                                    render_time_ms: nil,
                                    render_time_secs: nil,
                                    render_time_minutes: nil,
                                    render_percent: nil,
                                    db_time_ms: nil,
                                    db_time_secs: nil,
                                    db_time_minutes: nil,
                                    db_percent: nil,
                                    status: nil,
                                    host: nil,
                                    functional_area: nil,
                                    controller: nil,
                                    action: nil,
                                    params: nil,
                                    queryparams: nil,
                                    sessionid: nil)
    end

    # private

    # def add_approve_behaviours
    #   behaviours do |behaviour|
    #     behaviour.enable :reject_reason, when: :approve_action, changes_to: ['r']
    #   end
    # end
  end
end
