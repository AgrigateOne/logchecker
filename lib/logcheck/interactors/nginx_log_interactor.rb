# frozen_string_literal: true

module LogcheckApp
  class NginxLogInteractor < BaseInteractor
    def create_nginx_log(params)
      res = validate_nginx_log_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      id = nil
      repo.transaction do
        id = repo.create_nginx_log(res)
        log_status(:nginx_logs, id, 'CREATED')
        log_transaction
      end
      instance = nginx_log(id)
      success_response("Created nginx log #{instance.remote_addr}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { remote_addr: ['This nginx log already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_nginx_log(id, params)
      res = validate_nginx_log_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      repo.transaction do
        repo.update_nginx_log(id, res)
        log_transaction
      end
      instance = nginx_log(id)
      success_response("Updated nginx log #{instance.remote_addr}",
                       instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_nginx_log(id)
      name = nginx_log(id).remote_addr
      repo.transaction do
        repo.delete_nginx_log(id)
        log_status(:nginx_logs, id, 'DELETED')
        log_transaction
      end
      success_response("Deleted nginx log #{name}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    # def complete_a_nginx_log(id, params)
    #   res = complete_a_record(:nginx_logs, id, params.merge(enqueue_job: false))
    #   if res.success
    #     success_response(res.message, nginx_log(id))
    #   else
    #     failed_response(res.message, nginx_log(id))
    #   end
    # end

    # def reopen_a_nginx_log(id, params)
    #   res = reopen_a_record(:nginx_logs, id, params.merge(enqueue_job: false))
    #   if res.success
    #     success_response(res.message, nginx_log(id))
    #   else
    #     failed_response(res.message, nginx_log(id))
    #   end
    # end

    # def approve_or_reject_a_nginx_log(id, params)
    #   res = if params[:approve_action] == 'a'
    #           approve_a_record(:nginx_logs, id, params.merge(enqueue_job: false))
    #         else
    #           reject_a_record(:nginx_logs, id, params.merge(enqueue_job: false))
    #         end
    #   if res.success
    #     success_response(res.message, nginx_log(id))
    #   else
    #     failed_response(res.message, nginx_log(id))
    #   end
    # end

    def assert_permission!(task, id = nil)
      res = TaskPermissionCheck::NginxLog.call(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    private

    def repo
      @repo ||= NginxLogRepo.new
    end

    def nginx_log(id)
      repo.find_nginx_log(id)
    end

    def validate_nginx_log_params(params)
      NginxLogSchema.call(params)
    end
  end
end
