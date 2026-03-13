require_relative "error"

module ActionReporter
  # Thread-safe storage for ActionReporter context attributes
  # Uses ActiveSupport::IsolatedExecutionState when available (fiber/request-aware),
  # and falls back to Thread.current for non-Rails/non-ActiveSupport environments.
  class Current
    STORAGE_PREFIX = :action_reporter

    class << self
      attr_reader :storage_adapter

      def storage_adapter=(adapter)
        if adapter && (!adapter.respond_to?(:[]) || !adapter.respond_to?(:[]=))
          raise ArgumentError, "storage_adapter must respond to #[] and #[]="
        end

        @storage_adapter = adapter
      end

      def reset_storage_adapter!
        @storage_adapter = nil
      end

      def current_user
        read(:current_user)
      end

      def current_user=(user)
        write(:current_user, user)
      end

      def current_request_uuid
        read(:current_request_uuid)
      end

      def current_request_uuid=(uuid)
        write(:current_request_uuid, uuid)
      end

      def current_remote_addr
        read(:current_remote_addr)
      end

      def current_remote_addr=(addr)
        write(:current_remote_addr, addr)
      end

      def transaction_id
        read(:transaction_id)
      end

      def transaction_id=(transaction_id)
        write(:transaction_id, transaction_id)
      end

      def transaction_name
        read(:transaction_name)
      end

      def transaction_name=(transaction_name)
        write(:transaction_name, transaction_name)
      end

      def reset
        write(:current_user, nil)
        write(:current_request_uuid, nil)
        write(:current_remote_addr, nil)
        write(:transaction_id, nil)
        write(:transaction_name, nil)
      end

      private

      def storage
        return storage_adapter if storage_adapter

        if defined?(ActiveSupport::IsolatedExecutionState)
          ActiveSupport::IsolatedExecutionState
        else
          Thread.current
        end
      end

      def key(name)
        :"#{STORAGE_PREFIX}_#{name}"
      end

      def read(name)
        storage[key(name)]
      end

      def write(name, value)
        storage[key(name)] = value
      end
    end
  end
end
