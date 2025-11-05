require_relative "error"

module ActionReporter
  # Thread-safe storage for ActionReporter context attributes
  # Uses Thread.current for maximum compatibility and thread safety
  # Note: ActiveSupport::CurrentAttributes is request-scoped (not thread-scoped),
  # so we use Thread.current for proper thread isolation
  class Current
    class << self
      def current_user
        Thread.current[:action_reporter_current_user]
      end

      def current_user=(user)
        Thread.current[:action_reporter_current_user] = user
      end

      def current_request_uuid
        Thread.current[:action_reporter_current_request_uuid]
      end

      def current_request_uuid=(uuid)
        Thread.current[:action_reporter_current_request_uuid] = uuid
      end

      def current_remote_addr
        Thread.current[:action_reporter_current_remote_addr]
      end

      def current_remote_addr=(addr)
        Thread.current[:action_reporter_current_remote_addr] = addr
      end

      def reset
        Thread.current[:action_reporter_current_user] = nil
        Thread.current[:action_reporter_current_request_uuid] = nil
        Thread.current[:action_reporter_current_remote_addr] = nil
      end
    end
  end
end
