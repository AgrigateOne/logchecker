# frozen_string_literal: true

root_dir = File.expand_path('..', __dir__)
Dir["#{root_dir}/logcheck/entities/*.rb"].each { |f| require f }
Dir["#{root_dir}/logcheck/interactors/*.rb"].each { |f| require f }
# Dir["#{root_dir}/logcheck/jobs/*.rb"].each { |f| require f }
Dir["#{root_dir}/logcheck/repositories/*.rb"].each { |f| require f }
Dir["#{root_dir}/logcheck/services/*.rb"].each { |f| require f }
# Dir["#{root_dir}/logcheck/task_permission_checks/*.rb"].each { |f| require f }
Dir["#{root_dir}/logcheck/ui_rules/*.rb"].each { |f| require f }
Dir["#{root_dir}/logcheck/validations/*.rb"].each { |f| require f }
Dir["#{root_dir}/logcheck/views/**/*.rb"].each { |f| require f }

module LogcheckApp
end
