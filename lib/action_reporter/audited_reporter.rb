module ActionReporter
  class AuditedReporter < Base
    class_accessor "Audited", gem_spec: "audited (~> 5)"

    def notify(*)
    end

    def context(args)
      Audited.context = Audited.context.merge(args) if Audited.respond_to?(:context=)
    end

    def reset_context
      Audited.store.delete(:current_remote_address)
      Audited.store.delete(:current_request_uuid)
      Audited.store.delete(:audited_user)
      Audited.context = {} if Audited.respond_to?(:context=)
    end

    def current_user
      Audited.store[:audited_user]
    end

    def current_user=(user)
      Audited.store[:audited_user] = user
    end

    def current_request_uuid
      Audited.store[:current_request_uuid]
    end

    def current_request_uuid=(request_uuid)
      Audited.store[:current_request_uuid] = request_uuid
    end

    def current_remote_addr
      Audited.store[:current_remote_address]
    end

    def current_remote_addr=(remote_addr)
      Audited.store[:current_remote_address] = remote_addr
    end
  end
end
