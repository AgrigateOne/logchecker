# frozen_string_literal: true

module Logcheck
  module Rails1
    module Rails1Log
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:rails1_log, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              # form.caption 'Rails1 Log'
              form.view_only!
              form.add_field :approximate_time
              form.add_field :log_file
              form.add_field :line_no
              form.add_field :duration_in_ms
              form.add_field :duration_in_secs
              form.add_field :duration_in_minutes
              form.add_field :approximate_end_time
              form.add_field :render_time_ms
              form.add_field :render_time_secs
              form.add_field :render_time_minutes
              form.add_field :render_percent
              form.add_field :db_time_ms
              form.add_field :db_time_secs
              form.add_field :db_time_minutes
              form.add_field :db_percent
              form.add_field :status
              form.add_field :host
              form.add_field :functional_area
              form.add_field :controller
              form.add_field :action
              form.add_field :params
              form.add_field :queryparams
              form.add_field :sessionid
            end
          end

          layout
        end
      end
    end
  end
end
