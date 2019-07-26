# frozen_string_literal: true

module Logcheck
  module Sql
    module SqlLog
      class Show
        def self.call(id) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:sql_log, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page| # rubocop:disable Metrics/BlockLength
            page.form_object ui_rule.form_object
            page.add_text show_time(ui_rule.form_object)
            page.form do |form| # rubocop:disable Metrics/BlockLength
              form.view_only!
              form.add_field :action_type
              form.add_field :duration_in_ms
              form.add_field :duration_in_secs
              form.add_field :duration_in_minutes
              form.add_field :csv_row_no
              form.add_text wrapped_sql(ui_rule.form_object.sql_query), syntax: :sql
              form.add_field :log_message
              form.fold_up do |fold|
                fold.caption 'Lock status'
                fold.add_field :holding_process_id
                fold.add_field :waiting_process_id
                fold.add_field :holding_transaction_id
                fold.add_field :lock_wait_duration
                fold.add_field :lock_acquired
                fold.add_field :lock_waiting
              end
              form.add_field :start_time
              form.add_field :time_stamp
              form.add_field :user_name
              form.add_field :database_name
              form.add_field :process_id
              form.add_field :query_fingerprint
              form.fold_up do |fold|
                fold.caption 'Postgres log data'
                fold.add_field :host_port
                fold.add_field :session_id
                fold.add_field :line_no
                fold.add_field :command_tag
                fold.add_field :session_start_time
                fold.add_field :virtual_transaction_id
                fold.add_field :regular_transaction_id
                fold.add_field :error_severity
                fold.add_field :sqlstate_code
                fold.add_field :error_message
                fold.add_field :error_message_detail
                fold.add_field :hint
                fold.add_field :internal_query
                fold.add_field :char_cnt_int_query
                fold.add_field :error_context
                fold.add_field :user_query
                fold.add_field :char_cnt_usr_query
                fold.add_field :pg_err_loc
                fold.add_field :application_name
              end
            end
          end

          layout
        end

        def self.show_time(form_object)
          if form_object[:start_time] == form_object[:time_stamp]
            "#{form_object[:start_time].strftime('%Y-%m-%d')}: at <strong>#{form_object[:start_time].strftime('%H:%M:%S')}</strong>"
          else
            "#{form_object[:start_time].strftime('%Y-%m-%d')}: from #{form_object[:start_time].strftime('%H:%M:%S')} to <strong>#{form_object[:time_stamp].strftime('%H:%M:%S')}</strong>"
          end
        end

        def self.wrapped_sql(sql)
          return '' if sql.nil?

          width = 100
          ar = sql.gsub(/from /i, "\nFROM ").gsub(/where /i, "\nWHERE ").gsub(/(left outer join |left join |inner join |join )/i, "\n\\1").split("\n")
          ar.map { |a| a.scan(/\S.{0,#{width - 2}}\S(?=\s|$)|\S+/).join("\n") }.join("\n")
        end
      end
    end
  end
end
