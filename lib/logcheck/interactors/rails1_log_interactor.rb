# frozen_string_literal: true

module LogcheckApp
  class Rails1LogInteractor < BaseInteractor
    def create_rails1_log(params)
      res = validate_rails1_log_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      id = nil
      repo.transaction do
        id = repo.create_rails1_log(res)
        log_status('rails1_logs', id, 'CREATED')
        log_transaction
      end
      instance = rails1_log(id)
      success_response("Created rails1 log #{instance.log_file}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { log_file: ['This rails1 log already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_rails1_log(id, params)
      res = validate_rails1_log_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      repo.transaction do
        repo.update_rails1_log(id, res)
        log_transaction
      end
      instance = rails1_log(id)
      success_response("Updated rails1 log #{instance.log_file}",
                       instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_rails1_log(id)
      name = rails1_log(id).log_file
      repo.transaction do
        repo.delete_rails1_log(id)
        log_status('rails1_logs', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted rails1 log #{name}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    # def complete_a_rails1_log(id, params)
    #   res = complete_a_record(:rails1_logs, id, params.merge(enqueue_job: false))
    #   if res.success
    #     success_response(res.message, rails1_log(id))
    #   else
    #     failed_response(res.message, rails1_log(id))
    #   end
    # end

    # def reopen_a_rails1_log(id, params)
    #   res = reopen_a_record(:rails1_logs, id, params.merge(enqueue_job: false))
    #   if res.success
    #     success_response(res.message, rails1_log(id))
    #   else
    #     failed_response(res.message, rails1_log(id))
    #   end
    # end

    # def approve_or_reject_a_rails1_log(id, params)
    #   res = if params[:approve_action] == 'a'
    #           approve_a_record(:rails1_logs, id, params.merge(enqueue_job: false))
    #         else
    #           reject_a_record(:rails1_logs, id, params.merge(enqueue_job: false))
    #         end
    #   if res.success
    #     success_response(res.message, rails1_log(id))
    #   else
    #     failed_response(res.message, rails1_log(id))
    #   end
    # end

    def assert_permission!(task, id = nil)
      res = TaskPermissionCheck::Rails1Log.call(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    private

    def repo
      @repo ||= Rails1LogRepo.new
    end

    def rails1_log(id)
      repo.find_rails1_log(id)
    end

    def validate_rails1_log_params(params)
      Rails1LogSchema.call(params)
    end
  end
end
