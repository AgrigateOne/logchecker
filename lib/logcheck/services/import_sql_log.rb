# frozen_string_literal: true

require 'csv'

module LogcheckApp
  # Service to import a Postgres csv logfile.
  class ImportSqlLog < BaseService # rubocop:disable Metrics/ClassLength
    attr_reader :logdate, :table_name, :filenames

    def initialize(logdate, filenames)
      @logdate = logdate
      @table_name = :sql_logs # dated_table_name
      @filenames = Array(filenames)
    end

    def call
      DB[table_name].truncate # to repo...

      filenames.each { |f| process_csv(f) }
    end

    private

    def dated_table_name
      "sql_log_#{logdate.strftime('%Y_%m_%d')}".to_sym
    end

    RECEIVED      = 'connection received:'
    AUTHED        = 'connection authorized:'
    EOFCON        = 'unexpected EOF on client connection'
    DISCON        = 'disconnection:'
    DURATION      = 'duration:'
    CHECKPOINT    = 'checkpoint'
    VACUUM        = 'automatic vacuum of table'
    ANALYZE       = 'automatic analyze of table'
    TIMEOUT       = 'Connection timed out'
    SYNTAX        = 'syntax error at or near'
    INPROGRESS    = 'there is already a transaction in progress'
    NOTRANSACTION = 'there is no transaction in progress'
    GOTLOCK       = 'acquired ShareLock'
    WAITLOCK      = 'still waiting for ShareLock'

    ERR_POS  = 13
    APP_NAME = 22

    def process_csv(filename) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      index = 0

      # # 1. add duration in secs
      # # 2. split out before : into log_message
      # 3. lock waiting messages

      CSV.foreach(filename) do |row| # rubocop:disable Metrics/BlockLength
        index += 1
        rec = build_row_copy(row)
        rec[:regular_transaction_id] = nil if rec[:regular_transaction_id].zero?

        err_msg = row[ERR_POS]
        type = case err_msg
               when /#{DURATION}/
                 'DURATION'
               when /#{RECEIVED}/
                 'CONNECTED'
               when /#{AUTHED}/
                 'AUTHORISE'
               when /#{EOFCON}/
                 'UNEXPECTED EOF'
               when /#{DISCON}/
                 'DISCONNECTED'
               when /#{CHECKPOINT}/
                 'CHECKPOINT'
               when /#{VACUUM}/
                 'VACUUM'
               when /#{ANALYZE}/
                 'ANALYZE'
               when /#{TIMEOUT}/
                 'TIMEOUT'
               when /#{SYNTAX}/
                 'SYNTAX'
               when /#{INPROGRESS}/
                 'INPROGRESS'
               when /#{NOTRANSACTION}/
                 'NOTRANSACTION'
               when /#{GOTLOCK}/
                 'GOTLOCK'
               when /#{WAITLOCK}/
                 'WAITLOCK'
               else
                 'PROBLEM'
               end
        rec[:action_type] = type
        rec[:csv_row_no] = index
        rec[:sql_query] = sql_query(row[ERR_POS])
        rec[:log_message] = row[ERR_POS].split(':').first
        rec[:start_time] = rec[:time_stamp]

        # break if index > 20
        if err_msg.start_with?(DURATION)
          ar = err_msg.split('ms', 2)
          duration = ar.first.sub(DURATION, '').strip
          calc_duration_from_ms(rec, duration)
        end

        if %w[ANALYZE VACUUM].include?(type)
          secs = err_msg.split('elapsed').last.to_s.split('sec').last.to_s.strip
          calc_duration_from_secs(rec, secs)
        end

        if type == 'GOTLOCK'
          # process 12418 acquired ShareLock on transaction 10599682 after 511623.899 ms
          # - while updating tuple (457,22) in relation "pallets" (error context)
          duration = err_msg.split('after').last.to_s.split('ms').last.to_s.strip
          calc_duration_from_ms(rec, duration)
          rec[:waiting_process_id] = err_msg.split('process').last.to_s.split('acquired').first.to_s.strip.to_i
          rec[:holding_transaction_id] = err_msg.split('transaction').last.to_s.split('after').first.to_s.strip.to_i
          rec[:lock_wait_duration] = rec[:duration_in_ms]
          rec[:sql_query] = rec[:user_query]
          rec[:lock_acquired] = true
        end

        if type == 'WAITLOCK'
          # process 12418 still waiting for ShareLock on transaction 10599682 after 1000.050 ms
          # Process holding the lock: 26179. Wait queue: 15983, 12418. (Error message detail)
          duration = err_msg.split('after').last.to_s.split('ms').last.to_s.strip
          calc_duration_from_ms(rec, duration)
          rec[:waiting_process_id] = err_msg.split('process').last.to_s.split('still').first.to_s.strip.to_i
          rec[:holding_process_id] = rec[:error_message_detail].split(':').last.to_s.split('.').first.to_s.strip.to_i
          rec[:holding_transaction_id] = err_msg.split('transaction').last.to_s.split('after').first.to_s.strip.to_i
          rec[:lock_wait_duration] = rec[:duration_in_ms]
          rec[:sql_query] = rec[:user_query]
          rec[:lock_waiting] = true
        end
        rec[:query_fingerprint] = PgQuery.fingerprint(rec[:sql_query]) if rec[:sql_query]
        DB[table_name].insert(rec)
      end
      # TODO: use pg_query fingerprinting to identify similar queries?
    end

    def calc_duration_from_ms(rec, duration)
      return if duration.nil? || duration.empty?

      rec[:duration_in_ms] = BigDecimal(duration)
      rec[:duration_in_secs] = rec[:duration_in_ms] / 1000
      rec[:duration_in_minutes] = rec[:duration_in_ms] / 1000 / 60.0
      rec[:start_time] = rec[:time_stamp] - rec[:duration_in_secs]
    end

    def calc_duration_from_secs(rec, secs)
      return if secs.nil? || secs.empty?

      rec[:duration_in_secs] = BigDecimal(secs)
      rec[:duration_in_ms] = rec[:duration_in_secs] * 1000
      rec[:duration_in_minutes] = rec[:duration_in_ms] / 60.0
      rec[:start_time] = rec[:time_stamp] - rec[:duration_in_secs]
    end

    def build_row_copy(row) # rubocop:disable Metrics/AbcSize
      n = -1
      {
        time_stamp: datetime_val(row[n += 1]), # , Types::DateTime
        user_name: row[n += 1], # , Types::String
        database_name: row[n += 1], # , Types::String
        process_id: int_val(row[n += 1]), # , Types::Integer
        host_port: row[n += 1], # , Types::String
        session_id: row[n += 1], # , Types::String
        line_no: int_val(row[n += 1]), # , Types::Integer
        command_tag: row[n += 1], # , Types::String
        session_start_time: datetime_val(row[n += 1]), # , Types::DateTime
        virtual_transaction_id: row[n += 1], # , Types::String
        regular_transaction_id: int_val(row[n += 1]), # , Types::Integer
        error_severity: row[n += 1], # , Types::String
        sqlstate_code: int_val(row[n += 1]), # , Types::Integer
        error_message: row[n += 1], # , Types::String
        error_message_detail: row[n += 1], # , Types::String
        hint: row[n += 1], # , Types::String
        internal_query: row[n += 1], # , Types::String
        char_cnt_int_query: row[n += 1], # , Types::String
        error_context: row[n += 1], # , Types::String
        user_query: row[n += 1], # , Types::String
        char_cnt_usr_query: row[n += 1], # , Types::String
        pg_err_loc: row[n += 1], # , Types::String
        application_name: row[n + 1] # , Types::String
      }
    end

    def int_val(str)
      return nil if str.nil? || str.empty?

      str.to_i
    end

    def datetime_val(str)
      return nil if str.nil? || str.empty?

      Time.parse(str)
    end

    def sql_query(str)
      return nil if str.nil? || str.empty?
      return nil unless str[/statement: |execute <unnamed>:/]

      if str.include?(' execute <unnamed>: ')
        str.split(' execute <unnamed>: ').last
      else
        str.split('statement: ').last
      end
    end
  end
end
