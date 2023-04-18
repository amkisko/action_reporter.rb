module ActionReporter
  class AuditedReporter < Base
    class_accessor "Audited"

    def transform_context?
      false
    end

    def notify(*)
    end

    def context(args)
      Audited.store[:current_remote_address] = args[:remote_addr] if args[
        :remote_addr
      ].present?
      Audited.store[:audited_user] = args[:audited_user] if args[
        :audited_user
      ].present?
    end

    def reset_context
      Audited.store.delete(:current_remote_address)
      Audited.store.delete(:audited_user)
    end

    def audited_user
      Audited.store[:audited_user]
    end
  end
end
