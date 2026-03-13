module ActionReporter
  class ActiveVersionReporter < Base
    class_accessor "ActiveVersion", gem_spec: "active_version (~> 1)"

    def notify(*)
    end

    def context(args)
      ActiveVersion.context = ActiveVersion.context.merge(args) if ActiveVersion.respond_to?(:context=)
    end

    def reset_context
      request_store = request_store_class
      request_store.request_uuid = nil if request_store&.respond_to?(:request_uuid=)
      request_store.remote_address = nil if request_store&.respond_to?(:remote_address=)
      request_store.audited_user = nil if request_store&.respond_to?(:audited_user=)
      ActiveVersion.context = {} if ActiveVersion.respond_to?(:context=)
    end

    def current_user
      request_store_class&.audited_user
    end

    def current_user=(user)
      request_store_class.audited_user = user if request_store_class&.respond_to?(:audited_user=)
    end

    def current_request_uuid
      request_store_class&.request_uuid
    end

    def current_request_uuid=(request_uuid)
      request_store_class.request_uuid = request_uuid if request_store_class&.respond_to?(:request_uuid=)
    end

    def current_remote_addr
      request_store_class&.remote_address
    end

    def current_remote_addr=(remote_addr)
      request_store_class.remote_address = remote_addr if request_store_class&.respond_to?(:remote_address=)
    end

    private

    def request_store_class
      ActiveVersion::RequestStore if ActiveVersion.const_defined?(:RequestStore)
    end
  end
end
