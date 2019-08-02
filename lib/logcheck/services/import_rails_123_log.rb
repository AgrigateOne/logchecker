# frozen_string_literal: true

require 'csv'

module LogcheckApp
  # Service to import a Rails version 1.2.3 logfile.
  class ImportRails123Log < BaseService
    attr_reader :logdate, :table_name, :filenames

    def initialize(logdate, filenames)
      @logdate = logdate
      @table_name = :rails1_logs # dated_table_name
      @filenames = Array(filenames)
    end

    def call
      DB[table_name].truncate # to repo...

      # Should automatically uncompress gzipped files.
      filenames.each { |f| process_log(f) }
    end

    private

    def process_log(filename) # rubocop:disable Metrics/AbcSize
      line_no = 0
      row = {}
      File.foreach(filename) do |line| # rubocop:disable Metrics/BlockLength
        line_no += 1

        # break if line_no > 226
        next unless line.match?(%r{reqs/sec|Processing|Session ID|Parameters: })

        if line.include?('Processing')
          procline = line
          time = procline.split(' at ').last.split(')').first
          row = { approximate_time: Time.parse(time) }
          next
        end
        if line.include?('Session ID')
          row[:sessionid] = line.split('Session ID:').last.chomp.strip
          next
        end
        if line.include?('Parameters: ')
          row[:params] = line.split('Parameters: ').last.chomp.strip # maybe form into hash & remove controller + action?
          next
        end
        # Completed in 0.24022 (4 reqs/sec) | Rendering: 0.00163 (0%) | DB: 0.01822 (7%) | 200 OK [http://172.16.0.17/logistics/cumulative_stock/reprocess_edi_doc/?id=65281]

        parts = line.chomp.sub('sec) | DB', 'sec) | Rendering: 0.00000 (00%) | DB').sub('Rendering: ', '').sub('DB: ', '').sub('[http://', '| ').sub('Completed in', ' |').sub(%r{\(\d+ reqs/sec\) }, '').sub(':', ' | ').sub(']', '').sub('/?', '?').split('?')
        ar = parts.shift.split(' | ')
        ar.shift # remove blank
        ar.unshift filename.gsub(%r{.*/}, '') # Remove path in front of logfile name.
        str_fields = ar.join(',').gsub('/', ',').split(',')

        build_row(row, str_fields)
        # ["0.24022", "0.00163 (0%)", "0.01822 (7%)", "200 OK", "172.16.0.17", "logistics", "cumulative_stock", "reprocess_edi_doc"]
        #
        row[:queryparams] = parts.join(',') unless parts.empty? # parameters
        row[:line_no] = line_no
        DB[table_name].insert(row)
      end
    end

    def build_row(row, str_fields) # rubocop:disable Metrics/AbcSize
      row[:log_file] = str_fields[0]
      unless str_fields[1].empty?
        row[:duration_in_ms] = BigDecimal(str_fields[1])
        row[:duration_in_secs] = row[:duration_in_ms] / 1000
        row[:duration_in_minutes] = row[:duration_in_ms] / 1000 / 60.0
        row[:approximate_end_time] = row[:approximate_time] + row[:duration_in_secs]
      end

      unless str_fields[2].empty?
        ar = str_fields[2].split(' (')
        row[:render_time_ms] = BigDecimal(ar.first)
        row[:render_time_secs] = row[:render_time_ms] / 1000
        row[:render_time_minutes] = row[:render_time_ms] / 1000 / 60.0
        row[:render_percent] = ar.last.split('%').first.to_i
      end

      unless str_fields[3].empty?
        ar = str_fields[3].split(' (')
        row[:db_time_ms] = BigDecimal(ar.first)
        row[:db_time_secs] = row[:db_time_ms] / 1000
        row[:db_time_minutes] = row[:db_time_ms] / 1000 / 60.0
        row[:db_percent] = ar.last.split('%').first.to_i
      end

      row[:status] = str_fields[4]
      row[:host] = str_fields[5]
      row[:functional_area] = str_fields[6]
      row[:controller] = str_fields[7]
      row[:action] = str_fields[8]
      row[:controller] = row[:params].split('"controller"=>"').last.split('"').first if row[:controller].nil?
      row[:action] = row[:params].split('"action"=>"').last.split('"').first if row[:action].nil?
    end

    def dated_table_name
      "rails1_log_#{logdate.strftime('%Y_%m_%d')}".to_sym
    end
  end
end
