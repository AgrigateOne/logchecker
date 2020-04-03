# frozen_string_literal: true

module LogcheckApp
  # Service to import an nginx logfile.
  class ImportNginxLog < BaseService
    attr_reader :logdate, :table_name, :filenames

    LINE_FORMAT_REGEXP = /^(\S*) (\S*) (\S*) (\[[^\]]+\]) (?-mix:"([^"\\]*(?:\\.[^"\\]*)*)") (\S*) (\S*) (?-mix:"([^"\\]*(?:\\.[^"\\]*)*)") (?-mix:"([^"\\]*(?:\\.[^"\\]*)*)") (\S*)$/.freeze

    DATE_REGEXP = /(\d+)\/(\D+)\/(\d{4}):/.freeze

    def initialize(logdate, filenames)
      @logdate = logdate
      @table_name = :nginx_logs # dated_table_name
      @filenames = Array(filenames)
    end

    def call
      repo.truncate(table_name)

      # Should automatically uncompress gzipped files.
      filenames.each { |f| process_log(f) }
    end

    private

    def process_log(filename)
      puts "..processing \"#{filename}\""

      if filename.end_with?('.gz')
        Zlib::GzipReader.open(filename) do |gz|
          gz.each_line do |line|
            row = build_row(line)
            repo.create_nginx_log(row) unless row.nil?
          end
        end
      else
        File.foreach(filename) do |line|
          row = build_row(line)
          repo.create_nginx_log(row) unless row.nil?
        end
      end
    end
    # 172.17.2.16 - - [25/Mar/2020:13:03:18 +0200] "GET /finished_goods/inspection/govt_inspection_sheets/new HTTP/1.1" 200 5878 "http://172.17.2.243/list/govt_inspection_sheets" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.132 Safari/537.36 OPR/67.0.3575.97" 0.021


    # LINE_FORMAT_REGEXP = /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s?\-\s?-\s?\[(\d{2}\/[a-z]{3}\/\d{4}:\d{2}:\d{2}:\d{2} (\+|\-)\d{4})\]\s?\\?"?(GET|POST|PUT|HEAD|DELETE|OPTIONS)\s?(.*?)\s(HTTP\/\d\.\d)\\?"?\s?(\d{3})\s?(\d+)\s?\\?\"\-\\?\"\s?\\?\"(.*?)\"/i
    REQUEST_FORMAT = %i[
      ip_address
      date
      symbol
      request_method
      request_path
      http_version
      response_status
      body_size
      user_agent
    ].freeze

    def build_row(line)
      # 192.168.9.56 - - [19/Mar/2020:08:59:04 +0200] "GET /messcada/rmt/bin_tipping/weighing?bin_number=SK122258559&gross_weight=398.0&measurement_unit=Kg&device=BTM-03 HTTP/1.1" 200 336 "-" "Java/1.8.0_144"

      # log_format combine_ext '$remote_addr - $remote_user [$time_local] '
      #                        '"$request" $status $body_bytes_sent '
      #                        '"$http_referer" "$http_user_agent"'
      #                        ' $request_time';
      matches = LINE_FORMAT_REGEXP.match(line.chomp)
      return nil if matches.nil?
      return nil if matches[5].include?('/terminus/message-bus')

      row = { remote_addr: matches[1], status: matches[6], bytes: matches[7], http_referer: matches[8], http_user_agent: matches[9] }

      date_part = matches[4].gsub(/[\[\]]/, '') # [25/Mar/2020:13:03:18 +0200]
      m = date_part.match(DATE_REGEXP)
      row[:time_local] = Time.parse(date_part.sub(m[0], "#{m[3]}-#{m[2]}-#{m[1]} "))

      req_parts = matches[5].split(' ') # POST /terminus/message-bus/27e6b21e69bf4d67856da9522263bd2c/poll?_=9542 HTTP/1.1
      row[:method] = req_parts.first
      request = req_parts[1]
      row[:request] = request
      base_url, params = request.split('?')
      row[:base_url] = base_url
      row[:params] = params
      row[:device] = params.split('device=').last.split('&').first if params&.include?('device=')
      row[:http_version] = req_parts.last
      ar = base_url.split('/')
      return nil if %w[js css images favicon-32x32.png apple-touch-icon.png assets].include?(ar[1]) # Skip assets

      row[:func_area] = ar[1] if ar[1]
      row[:prog_area] = ar[2] if ar[2] && ar[1] != 'list' && ar[1] != 'search'
      row[:dm_key] = ar[2] if ar[2] && (ar[1] == 'list' || ar[1] == 'search')
      row[:url_fingerprint] = base_url.match(/([^\d]+)/)[1]
      # could take leftovers from fingerprinnt as param...
      # could do booleans for new/edit/delete/create/upd?

      timing = BigDecimal(matches[10]) # 0.246
      row[:request_time_in_ms] = timing * 1000
      row[:request_time_in_secs] = timing
      row[:request_time_in_minutes] = timing / 60.0
      row[:mobile] = matches[9].include?('Android')
      row[:java_robot] = matches[9].include?('Java')
      row

      # attribute :remote_addr, Types::String
      # attribute :remote_user, Types::String
      # attribute :time_local, Types::DateTime
      # attribute :method, Types::String
      # attribute :request, Types::String
      # attribute :http_version, Types::String
      # attribute :status, Types::Integer
      # attribute :bytes, Types::Integer
      # attribute :http_referer, Types::String
      # attribute :http_user_agent, Types::String
      # attribute :request_time_in_ms, Types::Decimal
      # attribute :request_time_in_secs, Types::Decimal
      # attribute :request_time_in_minutes, Types::Decimal
      # attribute :base_url, Types::String
      # attribute :params, Types::String
      # attribute :mobile, Types::Bool
      # attribute :java_robot, Types::Bool
    end

    def repo
      @repo ||= NginxLogRepo.new
    end
  end
end
