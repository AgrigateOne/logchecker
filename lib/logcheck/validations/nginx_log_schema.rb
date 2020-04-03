# frozen_string_literal: true

module LogcheckApp
  NginxLogSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:remote_addr, Types::StrippedString).filled(:str?)
    required(:remote_user, Types::StrippedString).maybe(:str?)
    required(:time_local, :time).filled(:time?)
    required(:method, Types::StrippedString).filled(:str?)
    required(:request, Types::StrippedString).filled(:str?)
    required(:http_version, Types::StrippedString).filled(:str?)
    required(:status, :integer).filled(:int?)
    required(:bytes, :integer).filled(:int?)
    required(:http_referer, Types::StrippedString).maybe(:str?)
    required(:http_user_agent, Types::StrippedString).maybe(:str?)
    required(:request_time_in_ms, [:nil, :decimal]).maybe(:decimal?)
    required(:request_time_in_secs, [:nil, :decimal]).maybe(:decimal?)
    required(:request_time_in_minutes, [:nil, :decimal]).maybe(:decimal?)
    required(:base_url, Types::StrippedString).maybe(:str?)
    required(:params, Types::StrippedString).maybe(:str?)
    required(:mobile, :bool).maybe(:bool?)
    required(:java_robot, :bool).maybe(:bool?)
  end
end
