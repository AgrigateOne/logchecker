# frozen_string_literal: true

require File.expand_path('../../app_loader.rb', __dir__)

# Rake tasks for importing log files.
class LogImportTasks
  include Rake::DSL

  def initialize # rubocop:disable Metrics/AbcSize
    namespace :import_logs do
      desc 'Import postgresql csv log files'
      task :sql do
        # Dir.chdir '/home/james/SilberbauerComputing/NoSoft/nspack/performance/2020-06-30' # from user
        Dir.chdir '/home/james/SilberbauerComputing/NoSoft/nspack/performance/2020-07-30' # from user
        files = Rake::FileList['**/*.csv']
        files.exclude('~*')
        puts files
        LogcheckApp::ImportSqlLog.call(Date.today, files)
      end

      desc 'Import nginx log files'
      task :nginx do
        # Dir.chdir '/home/james/SilberbauerComputing/NoSoft/nspack/performance/2020-03-31' # from user
        # Dir.chdir '/home/james/SilberbauerComputing/NoSoft/nspack/performance/2020-06-30/nginx' # from user
        Dir.chdir '/home/james/SilberbauerComputing/NoSoft/nspack/performance/2020-07-30/nginx' # from user
        # files = Rake::FileList['**/*.log', '**/*.log.*', '**/*.gz']
        files = Rake::FileList['**/*.log', '**/*.log.*']
        files.exclude('~*')
        puts files
        LogcheckApp::ImportNginxLog.call(Date.today, files)

        # @logs = []
        # puts '1. Mail settings'
        # setup_mail_settings
        # puts ''
        # puts '2. Dataminer settings'
        # setup_dm_settings
        # puts ''
        # puts '3. Environment variables'
        # setup_env
        # puts '4. Required paths'
        # prep_required_paths
        # @logs.unshift "\n----------" unless @logs.empty?
        # @logs.push '----------' unless @logs.empty?
        # puts @logs.join("\n") unless @logs.empty?
      end

      # desc 'List of ENV variables'
      # task :listenv do
      #   EnvVarRules.new.print
      # end
      #
      # desc 'Validate presence of ENV variables'
      # task :validateenv do
      #   EnvVarRules.new.validate
      # end
    end
  end
end

LogImportTasks.new
