# frozen_string_literal: true

module Logcheck
  module Nginx
    module NginxLog
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:nginx_log, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              # form.caption 'Nginx Log'
              form.view_only!
              form.add_field :remote_addr
              form.add_field :remote_user
              form.add_field :time_local
              form.add_field :method
              form.add_field :request
              form.add_field :http_version
              form.add_field :status
              form.add_field :bytes
              form.add_field :http_referer
              form.add_field :http_user_agent
              form.add_field :request_time_in_ms
              form.add_field :request_time_in_secs
              form.add_field :request_time_in_minutes
              form.add_field :base_url
              form.add_field :params
              form.add_field :mobile
              form.add_field :java_robot
            end
          end

          layout
        end
      end
    end
  end
end
