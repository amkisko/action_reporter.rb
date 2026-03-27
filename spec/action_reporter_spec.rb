require "spec_helper"
require "action_reporter/rails_reporter"
require "action_reporter/audited_reporter"

RSpec.describe ActionReporter do
  it "has a version number" do
    expect(ActionReporter::VERSION).not_to be_nil
  end

  describe ".enabled_reporters" do
    subject(:enabled_reporters) { described_class.enabled_reporters }

    before do
      described_class.enabled_reporters = []
    end

    it "returns enabled reporters" do
      expect(enabled_reporters).to eq([])
    end

    context "when Rails is defined" do
      let(:rails_reporter) { ActionReporter::RailsReporter.new }

      before do
        described_class.enabled_reporters = [
          rails_reporter
        ]
      end

      it "returns enabled reporters" do
        expect(enabled_reporters).to eq([rails_reporter])
      end
    end
  end

  describe ".notify" do
    let(:reporter) { double("Reporter") }
    let(:error) { StandardError.new("error") }
    let(:context_data) { {foo: "bar"} }

    before do
      described_class.enabled_reporters = [reporter]
    end

    it "calls notify on enabled reporters", :aggregate_failures do
      allow(reporter).to receive(:respond_to?).with(:notify).and_return(true)
      allow(reporter).to receive(:notify)
      described_class.notify(error, context: context_data)
      expect(reporter).to have_received(:respond_to?).with(:notify)
      expect(reporter).to have_received(:notify).with(error, context: context_data)
    end

    it "skips reporters that don't respond to notify", :aggregate_failures do
      allow(reporter).to receive(:respond_to?).with(:notify).and_return(false)
      allow(reporter).to receive(:notify)
      described_class.notify(error, context: context_data)
      expect(reporter).to have_received(:respond_to?).with(:notify)
      expect(reporter).not_to have_received(:notify)
    end
  end

  describe ".context" do
    let(:reporter) { double("Reporter") }
    let(:context_data) { {foo: "bar"} }

    before do
      described_class.enabled_reporters = [reporter]
    end

    it "calls context on enabled reporters", :aggregate_failures do
      allow(reporter).to receive(:respond_to?).with(:context).and_return(true)
      allow(reporter).to receive(:context)
      described_class.context(context_data)
      expect(reporter).to have_received(:respond_to?).with(:context)
      expect(reporter).to have_received(:context).with(context_data)
    end

    it "skips reporters that don't respond to context", :aggregate_failures do
      allow(reporter).to receive(:respond_to?).with(:context).and_return(false)
      allow(reporter).to receive(:context)
      described_class.context(context_data)
      expect(reporter).to have_received(:respond_to?).with(:context)
      expect(reporter).not_to have_received(:context)
    end

    it "raises ArgumentError when context is not a Hash", :aggregate_failures do
      expect {
        described_class.context("not a hash")
      }.to raise_error(ArgumentError, "context must be a Hash")

      expect {
        described_class.context(nil)
      }.to raise_error(ArgumentError, "context must be a Hash")

      expect {
        described_class.context([])
      }.to raise_error(ArgumentError, "context must be a Hash")
    end
  end

  describe ".reset_context" do
    let(:reporter) { double("Reporter") }

    before do
      described_class.enabled_reporters = [reporter]
      described_class.reset_context # Ensure clean state
    end

    it "calls reset_context on enabled reporters", :aggregate_failures do
      allow(reporter).to receive(:respond_to?).with(:reset_context).and_return(true)
      allow(reporter).to receive(:reset_context)
      described_class.reset_context
      expect(reporter).to have_received(:respond_to?).with(:reset_context)
      expect(reporter).to have_received(:reset_context)
    end

    it "skips reporters that don't respond to reset_context", :aggregate_failures do
      allow(reporter).to receive(:respond_to?).with(:reset_context).and_return(false)
      allow(reporter).to receive(:reset_context)
      described_class.reset_context
      expect(reporter).to have_received(:respond_to?).with(:reset_context)
      expect(reporter).not_to have_received(:reset_context)
    end

    it "resets instance attributes", :aggregate_failures do
      user = double("User")
      uuid = "123-456-789"
      addr = "192.168.1.1"
      transaction_id = "txn-123"
      transaction_name = "TestTransaction"

      described_class.current_user = user
      described_class.current_request_uuid = uuid
      described_class.current_remote_addr = addr
      described_class.transaction_id = transaction_id
      described_class.transaction_name = transaction_name

      expect(described_class.current_user).to eq(user)
      expect(described_class.current_request_uuid).to eq(uuid)
      expect(described_class.current_remote_addr).to eq(addr)
      expect(described_class.transaction_id).to eq(transaction_id)
      expect(described_class.transaction_name).to eq(transaction_name)

      described_class.reset_context

      expect(described_class.current_user).to be_nil
      expect(described_class.current_request_uuid).to be_nil
      expect(described_class.current_remote_addr).to be_nil
      expect(described_class.transaction_id).to be_nil
      expect(described_class.transaction_name).to be_nil
    end
  end

  describe ".check_in" do
    let(:reporter) { double("Reporter") }
    let(:identifier) { "check-in-id" }

    before do
      described_class.enabled_reporters = [reporter]
    end

    it "calls check_in on enabled reporters", :aggregate_failures do
      allow(reporter).to receive(:respond_to?).with(:check_in).and_return(true)
      allow(reporter).to receive(:check_in)
      described_class.check_in(identifier)
      expect(reporter).to have_received(:respond_to?).with(:check_in)
      expect(reporter).to have_received(:check_in).with(identifier)
    end

    it "skips reporters that don't respond to check_in", :aggregate_failures do
      allow(reporter).to receive(:respond_to?).with(:check_in).and_return(false)
      allow(reporter).to receive(:check_in)
      described_class.check_in(identifier)
      expect(reporter).to have_received(:respond_to?).with(:check_in)
      expect(reporter).not_to have_received(:check_in)
    end
  end

  describe ".current_request_uuid" do
    before do
      described_class.enabled_reporters = []
      described_class.reset_context # Ensure clean state
    end

    it "returns nil initially" do
      expect(described_class.current_request_uuid).to be_nil
    end

    it "returns the set value" do
      uuid = "123-456-789"
      described_class.current_request_uuid = uuid
      expect(described_class.current_request_uuid).to eq(uuid)
    end

    context "when reporter responds to current_request_uuid=" do
      let(:reporter) { double("Reporter") }

      before do
        described_class.enabled_reporters = [reporter]
      end

      it "sets current_request_uuid on reporters", :aggregate_failures do
        uuid = "123-456-789"
        allow(reporter).to receive(:respond_to?).with(:current_request_uuid=).and_return(true)
        allow(reporter).to receive(:current_request_uuid=)
        described_class.current_request_uuid = uuid
        expect(reporter).to have_received(:respond_to?).with(:current_request_uuid=)
        expect(reporter).to have_received(:current_request_uuid=).with(uuid)
      end
    end
  end

  describe ".current_remote_addr" do
    before do
      described_class.enabled_reporters = []
      described_class.reset_context # Ensure clean state
    end

    it "returns nil initially" do
      expect(described_class.current_remote_addr).to be_nil
    end

    it "returns the set value" do
      addr = "192.168.1.1"
      described_class.current_remote_addr = addr
      expect(described_class.current_remote_addr).to eq(addr)
    end

    context "when reporter responds to current_remote_addr=" do
      let(:reporter) { double("Reporter") }

      before do
        described_class.enabled_reporters = [reporter]
      end

      it "sets current_remote_addr on reporters", :aggregate_failures do
        addr = "192.168.1.1"
        allow(reporter).to receive(:respond_to?).with(:current_remote_addr=).and_return(true)
        allow(reporter).to receive(:current_remote_addr=)
        described_class.current_remote_addr = addr
        expect(reporter).to have_received(:respond_to?).with(:current_remote_addr=)
        expect(reporter).to have_received(:current_remote_addr=).with(addr)
      end
    end
  end

  describe ".current_user" do
    before do
      described_class.enabled_reporters = []
      described_class.reset_context
    end

    it "returns nil initially" do
      expect(described_class.current_user).to be_nil
    end

    it "returns the set value" do
      user = double("User")
      described_class.current_user = user
      expect(described_class.current_user).to eq(user)
    end

    context "when AuditedReporter is enabled" do
      let(:audited_reporter) { ActionReporter::AuditedReporter.new }
      let(:new_user) { double("User", to_global_id: "gid://user/1") }
      let(:audited_stub) { double("Audited") }

      before do
        described_class.enabled_reporters = [
          audited_reporter
        ]
        allow(audited_stub).to receive(:store).and_return({current_user: "user"})
        stub_const("Audited", audited_stub)
      end

      it "returns current_user", :aggregate_failures do
        expect { described_class.current_user = new_user }.not_to raise_error
        expect(described_class.current_user).to eq(new_user)
      end
    end

    context "when reporter responds to current_user=" do
      let(:reporter) { double("Reporter") }

      before do
        described_class.enabled_reporters = [reporter]
      end

      it "sets current_user on reporters", :aggregate_failures do
        user = double("User")
        allow(reporter).to receive(:respond_to?).with(:current_user=).and_return(true)
        allow(reporter).to receive(:current_user=)
        described_class.current_user = user
        expect(reporter).to have_received(:respond_to?).with(:current_user=)
        expect(reporter).to have_received(:current_user=).with(user)
      end
    end
  end

  describe ".logger" do
    before do
      described_class.logger = nil
    end

    it "returns nil when no logger is set and Rails is not available" do
      if defined?(Rails)
        stub_const("Rails", Object.new)
      end
      expect(described_class.logger).to be_nil
    end

    it "returns set logger" do
      logger = double("Logger")
      described_class.logger = logger
      expect(described_class.logger).to eq(logger)
    end
  end

  describe ".error_handler" do
    it "returns nil initially" do
      described_class.error_handler = nil
      expect(described_class.error_handler).to be_nil
    end

    it "returns set error handler" do
      handler = proc { |e, r, m| }
      described_class.error_handler = handler
      expect(described_class.error_handler).to eq(handler)
    end
  end

  describe ".user_id_resolver" do
    after do
      described_class.user_id_resolver = nil
    end

    it "returns nil initially" do
      described_class.user_id_resolver = nil
      expect(described_class.user_id_resolver).to be_nil
    end

    it "returns set resolver" do
      resolver = ->(user) { user.to_s }
      described_class.user_id_resolver = resolver
      expect(described_class.user_id_resolver).to eq(resolver)
    end
  end

  describe ".enabled_reporters=" do
    it "handles nil gracefully" do
      described_class.enabled_reporters = nil
      expect(described_class.enabled_reporters).to eq([])
    end
  end

  describe "error handling" do
    describe ".notify" do
      let(:failing_reporter) { double("FailingReporter") }
      let(:working_reporter) { double("WorkingReporter") }
      let(:error) { StandardError.new("error") }
      let(:logger) { double("Logger") }

      before do
        described_class.enabled_reporters = [failing_reporter, working_reporter]
        described_class.logger = logger
        allow(logger).to receive(:error)
        allow(logger).to receive(:debug)
      end

      it "continues to other reporters when one fails", :aggregate_failures do
        allow(failing_reporter).to receive(:respond_to?).with(:notify).and_return(true)
        allow(failing_reporter).to receive(:notify).and_raise(StandardError.new("Reporter failed"))
        allow(working_reporter).to receive(:respond_to?).with(:notify).and_return(true)
        allow(working_reporter).to receive(:notify)
        allow(logger).to receive(:error)

        described_class.notify(error, context: {})
        expect(working_reporter).to have_received(:notify).with(error, context: {})
        expect(logger).to have_received(:error).with(/ActionReporter: .*#notify failed/)
      end

      it "logs error details when a reporter fails", :aggregate_failures do
        reporter_error = StandardError.new("Reporter failed")
        allow(failing_reporter).to receive(:respond_to?).with(:notify).and_return(true)
        allow(failing_reporter).to receive(:notify).and_raise(reporter_error)
        allow(working_reporter).to receive(:respond_to?).with(:notify).and_return(true)
        allow(working_reporter).to receive(:notify)
        allow(logger).to receive(:error)
        allow(logger).to receive(:debug)

        described_class.notify(error, context: {})
        expect(logger).to have_received(:error).with(/ActionReporter: .*#notify failed: StandardError - Reporter failed/)
        expect(logger).to have_received(:debug).with(anything)
      end
    end

    describe ".context" do
      let(:failing_reporter) { double("FailingReporter") }
      let(:working_reporter) { double("WorkingReporter") }
      let(:logger) { double("Logger") }

      before do
        described_class.enabled_reporters = [failing_reporter, working_reporter]
        described_class.logger = logger
        allow(logger).to receive(:error)
        allow(logger).to receive(:debug)
      end

      it "continues to other reporters when one fails", :aggregate_failures do
        allow(failing_reporter).to receive(:respond_to?).with(:context).and_return(true)
        allow(failing_reporter).to receive(:context).and_raise(StandardError.new("Reporter failed"))
        allow(working_reporter).to receive(:respond_to?).with(:context).and_return(true)
        allow(working_reporter).to receive(:context)
        allow(logger).to receive(:error)

        described_class.context(foo: "bar")
        expect(working_reporter).to have_received(:context).with({foo: "bar"})
        expect(logger).to have_received(:error).with(/ActionReporter: .*#context failed/)
      end
    end

    describe ".check_in" do
      let(:failing_reporter) { double("FailingReporter") }
      let(:working_reporter) { double("WorkingReporter") }
      let(:logger) { double("Logger") }

      before do
        described_class.enabled_reporters = [failing_reporter, working_reporter]
        described_class.logger = logger
        allow(logger).to receive(:error)
        allow(logger).to receive(:debug)
      end

      it "continues to other reporters when one fails", :aggregate_failures do
        allow(failing_reporter).to receive(:respond_to?).with(:check_in).and_return(true)
        allow(failing_reporter).to receive(:check_in).and_raise(StandardError.new("Reporter failed"))
        allow(working_reporter).to receive(:respond_to?).with(:check_in).and_return(true)
        allow(working_reporter).to receive(:check_in)
        allow(logger).to receive(:error)

        described_class.check_in("check-in-id")
        expect(working_reporter).to have_received(:check_in).with("check-in-id")
        expect(logger).to have_received(:error).with(/ActionReporter: .*#check_in failed/)
      end
    end

    describe "error handler callback" do
      let(:reporter) { double("Reporter") }
      let(:error_handler) { double("ErrorHandler") }
      let(:logger) { double("Logger") }

      before do
        described_class.enabled_reporters = [reporter]
        described_class.logger = logger
        described_class.error_handler = error_handler
        allow(logger).to receive(:error)
        allow(logger).to receive(:debug)
      end

      it "calls error handler when provided" do
        allow(reporter).to receive(:respond_to?).with(:notify).and_return(true)
        allow(reporter).to receive(:notify).and_raise(StandardError.new("Reporter failed"))
        allow(error_handler).to receive(:respond_to?).with(:call).and_return(true)
        allow(error_handler).to receive(:call)

        described_class.notify("error")
        expect(error_handler).to have_received(:call).with(an_instance_of(StandardError), reporter, "notify")
      end

      it "skips error handler when it doesn't respond to call" do
        allow(reporter).to receive(:respond_to?).with(:notify).and_return(true)
        allow(reporter).to receive(:notify).and_raise(StandardError.new("Reporter failed"))
        allow(error_handler).to receive(:respond_to?).with(:call).and_return(false)
        allow(error_handler).to receive(:call)

        described_class.notify("error")
        expect(error_handler).not_to have_received(:call)
      end

      it "handles errors without backtrace" do
        error = StandardError.new("Reporter failed")
        # Create error without backtrace by removing the backtrace method
        allow(error).to receive(:backtrace).and_return(nil)

        allow(reporter).to receive(:respond_to?).with(:notify).and_return(true)
        allow(reporter).to receive(:notify).and_raise(error)
        allow(logger).to receive(:error)
        allow(logger).to receive(:debug)

        described_class.notify("error")
        expect(logger).not_to have_received(:debug)
      end

      it "handles error handler failure gracefully" do
        allow(reporter).to receive(:respond_to?).with(:notify).and_return(true)
        allow(reporter).to receive(:notify).and_raise(StandardError.new("Reporter failed"))
        allow(error_handler).to receive(:respond_to?).with(:call).and_return(true)
        allow(error_handler).to receive(:call).and_raise(StandardError.new("Handler failed"))
        # Allow logger.error to succeed, but error_handler.call to fail
        allow(logger).to receive(:error)
        allow(logger).to receive(:debug)

        # Should not raise an exception even when error handler itself fails
        expect { described_class.notify("error") }.not_to raise_error
      end

      it "handles logger failure gracefully" do
        allow(reporter).to receive(:respond_to?).with(:notify).and_return(true)
        allow(reporter).to receive(:notify).and_raise(StandardError.new("Reporter failed"))
        described_class.error_handler = nil
        allow(logger).to receive(:error).and_raise(StandardError.new("Logger failed"))

        # Should not raise an exception even when logger fails
        expect { described_class.notify("error") }.not_to raise_error
      end
    end

    describe ".reset_context error handling" do
      it "handles reporter reset_context errors" do
        reporter = double("Reporter")
        logger = double("Logger")

        described_class.enabled_reporters = [reporter]
        described_class.logger = logger
        described_class.error_handler = nil
        allow(logger).to receive(:error)
        allow(logger).to receive(:debug)

        allow(reporter).to receive(:respond_to?).with(:reset_context).and_return(true)
        allow(reporter).to receive(:reset_context).and_raise(StandardError.new("Reset failed"))

        described_class.reset_context
        expect(logger).to have_received(:error).with(/ActionReporter: .*#reset_context failed/)
      end
    end

    describe "setter methods error handling" do
      it "handles current_user= errors" do
        reporter = double("Reporter")
        logger = double("Logger")

        described_class.enabled_reporters = [reporter]
        described_class.logger = logger
        described_class.error_handler = nil
        allow(logger).to receive(:error)
        allow(logger).to receive(:debug)

        user = double("User")
        allow(reporter).to receive(:respond_to?).with(:current_user=).and_return(true)
        allow(reporter).to receive(:current_user=).and_raise(StandardError.new("Set failed"))

        described_class.current_user = user
        expect(logger).to have_received(:error).with(/ActionReporter: .*#current_user= failed/)
      end

      it "handles current_request_uuid= errors" do
        reporter = double("Reporter")
        logger = double("Logger")

        described_class.enabled_reporters = [reporter]
        described_class.logger = logger
        described_class.error_handler = nil
        allow(logger).to receive(:error)
        allow(logger).to receive(:debug)

        uuid = "123-456-789"
        allow(reporter).to receive(:respond_to?).with(:current_request_uuid=).and_return(true)
        allow(reporter).to receive(:current_request_uuid=).and_raise(StandardError.new("Set failed"))

        described_class.current_request_uuid = uuid
        expect(logger).to have_received(:error).with(/ActionReporter: .*#current_request_uuid= failed/)
      end

      it "handles current_remote_addr= errors" do
        reporter = double("Reporter")
        logger = double("Logger")

        described_class.enabled_reporters = [reporter]
        described_class.logger = logger
        described_class.error_handler = nil
        allow(logger).to receive(:error)
        allow(logger).to receive(:debug)

        addr = "192.168.1.1"
        allow(reporter).to receive(:respond_to?).with(:current_remote_addr=).and_return(true)
        allow(reporter).to receive(:current_remote_addr=).and_raise(StandardError.new("Set failed"))

        described_class.current_remote_addr = addr
        expect(logger).to have_received(:error).with(/ActionReporter: .*#current_remote_addr= failed/)
      end
    end
  end

  describe "thread safety" do
    before do
      described_class.enabled_reporters = []
      described_class.reset_context
    end

    it "isolates context between threads", :aggregate_failures do
      threads = []
      thread_results = Array.new(10)

      10.times do |i|
        threads << Thread.new do # rubocop:disable ThreadSafety/NewThread -- intentional concurrency test
          thread_id = i
          described_class.current_user = "user_#{thread_id}"
          described_class.current_request_uuid = "uuid_#{thread_id}"
          described_class.current_remote_addr = "addr_#{thread_id}"

          # Small delay to increase chance of race condition
          sleep 0.01

          # Verify values are still correct after delay
          result = {
            user: described_class.current_user,
            uuid: described_class.current_request_uuid,
            addr: described_class.current_remote_addr,
            thread_id: thread_id
          }

          thread_results[thread_id] = result
        end
      end

      threads.each(&:join)

      # Each thread should have its own isolated context
      thread_results.each_with_index do |result, i|
        expect(result).not_to be_nil, "Thread #{i} did not set its result"
        expect(result[:user]).to eq("user_#{i}"), "Thread #{i} user mismatch: expected user_#{i}, got #{result[:user]}"
        expect(result[:uuid]).to eq("uuid_#{i}"), "Thread #{i} uuid mismatch: expected uuid_#{i}, got #{result[:uuid]}"
        expect(result[:addr]).to eq("addr_#{i}"), "Thread #{i} addr mismatch: expected addr_#{i}, got #{result[:addr]}"
        expect(result[:thread_id]).to eq(i), "Thread #{i} ID mismatch"
      end

      # Main thread should have nil values (different thread)
      expect(described_class.current_user).to be_nil
      expect(described_class.current_request_uuid).to be_nil
      expect(described_class.current_remote_addr).to be_nil
    end
  end

  describe ".transaction_id" do
    before do
      described_class.enabled_reporters = []
      described_class.reset_context
    end

    it "returns nil initially" do
      expect(described_class.transaction_id).to be_nil
    end

    it "returns the set value" do
      id = "txn-123"
      described_class.transaction_id = id
      expect(described_class.transaction_id).to eq(id)
    end

    context "when reporter responds to transaction_id=" do
      let(:reporter) { double("Reporter") }

      before do
        described_class.enabled_reporters = [reporter]
      end

      it "sets transaction_id on reporters", :aggregate_failures do
        id = "txn-123"
        allow(reporter).to receive(:respond_to?).with(:context).and_return(false)
        allow(reporter).to receive(:respond_to?).with(:transaction_id=).and_return(true)
        allow(reporter).to receive(:transaction_id=)
        described_class.transaction_id = id
        expect(reporter).to have_received(:respond_to?).with(:transaction_id=)
        expect(reporter).to have_received(:transaction_id=).with(id)
      end

      it "sets context with transaction_id", :aggregate_failures do
        id = "txn-123"
        allow(reporter).to receive(:respond_to?).with(:transaction_id=).and_return(true)
        allow(reporter).to receive(:transaction_id=)
        allow(reporter).to receive(:respond_to?).with(:context).and_return(true)
        allow(reporter).to receive(:context)
        described_class.transaction_id = id
        expect(reporter).to have_received(:context).with(hash_including(transaction_id: id))
      end
    end
  end

  describe ".transaction_name" do
    before do
      described_class.enabled_reporters = []
      described_class.reset_context
    end

    it "returns nil initially" do
      expect(described_class.transaction_name).to be_nil
    end

    it "returns the set value" do
      name = "GET /api/users"
      described_class.transaction_name = name
      expect(described_class.transaction_name).to eq(name)
    end

    context "when reporter responds to transaction_name=" do
      let(:reporter) { double("Reporter") }

      before do
        described_class.enabled_reporters = [reporter]
      end

      it "sets transaction_name on reporters", :aggregate_failures do
        name = "GET /api/users"
        allow(reporter).to receive(:respond_to?).with(:context).and_return(false)
        allow(reporter).to receive(:respond_to?).with(:transaction_name=).and_return(true)
        allow(reporter).to receive(:transaction_name=)
        described_class.transaction_name = name
        expect(reporter).to have_received(:respond_to?).with(:transaction_name=)
        expect(reporter).to have_received(:transaction_name=).with(name)
      end

      it "sets context with transaction_name", :aggregate_failures do
        name = "GET /api/users"
        allow(reporter).to receive(:respond_to?).with(:transaction_name=).and_return(true)
        allow(reporter).to receive(:transaction_name=)
        allow(reporter).to receive(:respond_to?).with(:context).and_return(true)
        allow(reporter).to receive(:context)
        described_class.transaction_name = name
        expect(reporter).to have_received(:context).with(hash_including(transaction_name: name))
      end
    end
  end

  describe ".transaction" do
    before do
      described_class.enabled_reporters = []
      described_class.reset_context
    end

    it "raises ArgumentError when no block is given" do
      expect {
        described_class.transaction(name: "Test")
      }.to raise_error(ArgumentError, "transaction requires a block")
    end

    it "executes the block" do
      result = described_class.transaction { "result" }
      expect(result).to eq("result")
    end

    it "sets transaction name and ID within block", :aggregate_failures do
      described_class.transaction(name: "TestTransaction", id: "txn-123") do
        expect(described_class.transaction_name).to eq("TestTransaction")
        expect(described_class.transaction_id).to eq("txn-123")
      end
    end

    it "restores previous transaction name after block", :aggregate_failures do
      described_class.transaction_name = "PreviousName"
      described_class.transaction(name: "NewName") do
        expect(described_class.transaction_name).to eq("NewName")
      end
      expect(described_class.transaction_name).to eq("PreviousName")
    end

    it "restores previous transaction ID after block", :aggregate_failures do
      described_class.transaction_id = "previous-id"
      described_class.transaction(id: "new-id") do
        expect(described_class.transaction_id).to eq("new-id")
      end
      expect(described_class.transaction_id).to eq("previous-id")
    end

    it "restores previous values even when exception is raised", :aggregate_failures do
      described_class.transaction_name = "PreviousName"
      described_class.transaction_id = "previous-id"

      expect {
        described_class.transaction(name: "NewName", id: "new-id") do
          raise StandardError, "Test error"
        end
      }.to raise_error(StandardError, "Test error")

      expect(described_class.transaction_name).to eq("PreviousName")
      expect(described_class.transaction_id).to eq("previous-id")
    end

    it "sets additional context", :aggregate_failures do
      reporter = double("Reporter")
      described_class.enabled_reporters = [reporter]
      allow(reporter).to receive(:respond_to?).with(:context).and_return(true)
      allow(reporter).to receive(:respond_to?).with(:transaction_name=).and_return(false)
      allow(reporter).to receive(:respond_to?).with(:transaction_id=).and_return(false)
      allow(reporter).to receive(:context)

      described_class.transaction(name: "Test", foo: "bar") do
      end
      expect(reporter).to have_received(:context).with(hash_including(transaction_name: "Test")).ordered
      expect(reporter).to have_received(:context).with(hash_including(foo: "bar")).ordered
      expect(reporter).to have_received(:context).with(hash_including(transaction_name: nil)).ordered
    end

    it "does not restore when name/id are not provided", :aggregate_failures do
      described_class.transaction_name = "PreviousName"
      described_class.transaction_id = "previous-id"

      described_class.transaction(foo: "bar") do
        expect(described_class.transaction_name).to eq("PreviousName")
        expect(described_class.transaction_id).to eq("previous-id")
      end

      expect(described_class.transaction_name).to eq("PreviousName")
      expect(described_class.transaction_id).to eq("previous-id")
    end

    it "supports nested transactions", :aggregate_failures do
      described_class.transaction(name: "Outer") do
        expect(described_class.transaction_name).to eq("Outer")
        described_class.transaction(name: "Inner") do
          expect(described_class.transaction_name).to eq("Inner")
        end
        expect(described_class.transaction_name).to eq("Outer")
      end
      expect(described_class.transaction_name).to be_nil
    end
  end

  describe ".reset_context transaction fields" do
    it "resets transaction_id and transaction_name", :aggregate_failures do
      described_class.transaction_id = "txn-123"
      described_class.transaction_name = "TestTransaction"
      described_class.reset_context
      expect(described_class.transaction_id).to be_nil
      expect(described_class.transaction_name).to be_nil
    end
  end

  describe "transaction error handling" do
    it "handles transaction_id= errors" do
      reporter = double("Reporter")
      logger = double("Logger")

      described_class.enabled_reporters = [reporter]
      described_class.logger = logger
      described_class.error_handler = nil
      allow(logger).to receive(:error)
      allow(logger).to receive(:debug)
      allow(reporter).to receive(:respond_to?).with(:context).and_return(false)

      id = "txn-123"
      allow(reporter).to receive(:respond_to?).with(:transaction_id=).and_return(true)
      allow(reporter).to receive(:transaction_id=).and_raise(StandardError.new("Set failed"))

      described_class.transaction_id = id
      expect(logger).to have_received(:error).with(/ActionReporter: .*#transaction_id= failed/)
    end

    it "handles transaction_name= errors" do
      reporter = double("Reporter")
      logger = double("Logger")

      described_class.enabled_reporters = [reporter]
      described_class.logger = logger
      described_class.error_handler = nil
      allow(logger).to receive(:error)
      allow(logger).to receive(:debug)
      allow(reporter).to receive(:respond_to?).with(:context).and_return(false)

      name = "TestTransaction"
      allow(reporter).to receive(:respond_to?).with(:transaction_name=).and_return(true)
      allow(reporter).to receive(:transaction_name=).and_raise(StandardError.new("Set failed"))

      described_class.transaction_name = name
      expect(logger).to have_received(:error).with(/ActionReporter: .*#transaction_name= failed/)
    end
  end
end
