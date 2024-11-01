module ActionReporter
  class PaperTrailReporter < Base
    class_accessor "PaperTrail", gem_spec: "paper_trail (~> 15)"

    def notify(*)
    end

    def context(args)
    end

    def reset_context
      PaperTrail.request.whodunnit = nil
    end

    def current_user
      PaperTrail.request.whodunnit
    end

    def current_user=(user)
      PaperTrail.request.whodunnit = user
    end
  end
end
