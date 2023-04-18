module ActionReporter
  class AuditedReporter < Base
    class_accessor "Audited"

    def notify(*)
    end

    def context(args)
      Audited.store[:current_remote_address] = args[:remote_addr] if args[
        :remote_addr
      ].present?
    end

    def reset_context
      Audited.store.delete(:current_remote_address)
      Audited.store.delete(:audited_user)
    end

    def audited_user
      Audited.store[:audited_user]
    end

    def audited_user=(user)
      Audited.store[:audited_user] = user
    end
  end
end
