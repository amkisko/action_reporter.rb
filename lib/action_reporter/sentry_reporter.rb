module ActionReporter
  class SentryReporter < Base
    class_accessor "Sentry"

    def notify(error, context: {})
      sentry_class.with_scope do |temp_scope|
        temp_scope.set_context("context", transform_context(context))

        if error.is_a?(StandardError)
          sentry_class.capture_exception(error)
        else
          sentry_class.capture_message(error)
        end
      end
    end

    def context(args)
      apply_reporter_context(merge_context_updates(current_reporter_context, args))
    end

    def reset_context
      apply_reporter_context({})
    end

    def current_user=(user)
      id = resolve_user_id(user)
      sentry_class.set_user(id: id)
    end

    def transaction_id=(transaction_id)
      sentry_class.set_tags(transaction_id: transaction_id)
    end

    def transaction_name=(transaction_name)
      sentry_class.configure_scope do |scope|
        scope.set_transaction_name(transaction_name)
      end
    end

    private

    def current_reporter_context
      sentry_class.get_current_scope.contexts["context"] || {}
    end

    # sentry-ruby merges via set_context and cannot remove keys; replace the bucket via protected setter.
    def apply_reporter_context(context_hash)
      scope = sentry_class.get_current_scope
      contexts = scope.contexts.dup
      if context_hash.empty?
        contexts.delete("context")
      else
        contexts["context"] = context_hash
      end
      scope.send(:contexts=, contexts)
    end
  end
end
