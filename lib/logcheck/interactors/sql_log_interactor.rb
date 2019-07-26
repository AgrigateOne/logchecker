# frozen_string_literal: true

module LogcheckApp
  class SqlLogInteractor < BaseInteractor
    def create_sql_log(params)
      res = validate_sql_log_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      id = nil
      repo.transaction do
        id = repo.create_sql_log(res)
        log_status('sql_logs', id, 'CREATED')
        log_transaction
      end
      instance = sql_log(id)
      success_response("Created sql log #{instance.action_type}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { action_type: ['This sql log already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_sql_log(id, params)
      res = validate_sql_log_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      repo.transaction do
        repo.update_sql_log(id, res)
        log_transaction
      end
      instance = sql_log(id)
      success_response("Updated sql log #{instance.action_type}",
                       instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_sql_log(id)
      name = sql_log(id).action_type
      repo.transaction do
        repo.delete_sql_log(id)
        log_status('sql_logs', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted sql log #{name}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    # def complete_a_sql_log(id, params)
    #   res = complete_a_record(:sql_logs, id, params.merge(enqueue_job: false))
    #   if res.success
    #     success_response(res.message, sql_log(id))
    #   else
    #     failed_response(res.message, sql_log(id))
    #   end
    # end

    # def reopen_a_sql_log(id, params)
    #   res = reopen_a_record(:sql_logs, id, params.merge(enqueue_job: false))
    #   if res.success
    #     success_response(res.message, sql_log(id))
    #   else
    #     failed_response(res.message, sql_log(id))
    #   end
    # end

    # def approve_or_reject_a_sql_log(id, params)
    #   res = if params[:approve_action] == 'a'
    #           approve_a_record(:sql_logs, id, params.merge(enqueue_job: false))
    #         else
    #           reject_a_record(:sql_logs, id, params.merge(enqueue_job: false))
    #         end
    #   if res.success
    #     success_response(res.message, sql_log(id))
    #   else
    #     failed_response(res.message, sql_log(id))
    #   end
    # end

    def assert_permission!(task, id = nil)
      res = TaskPermissionCheck::SqlLog.call(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    private

    def repo
      @repo ||= SqlLogRepo.new
    end

    def sql_log(id)
      repo.find_sql_log(id)
    end

    def validate_sql_log_params(params)
      SqlLogSchema.call(params)
    end
  end
end
