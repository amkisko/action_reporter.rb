require "spec_helper"

class NoopReporter < ActionReporter::Base
  def notify(error, context: {})
  end

  def context(args)
  end

  def reset_context
  end
end

class FailingReporter < ActionReporter::Base
  def notify(*)
    raise "boom"
  end
end

RSpec.describe "ActionReporter performance" do
  before do
    ActionReporter.enabled_reporters = []
    ActionReporter.reset_context
    ActionReporter.logger = nil
    ActionReporter.error_handler = nil
  end

  def measure_wall_time(iterations = 10_000)
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    yield iterations
    Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
  end

  def measure_memory(iterations = 10_000)
    GC.start
    GC.compact if GC.respond_to?(:compact)

    before_stat = GC.stat if GC.respond_to?(:stat)
    ObjectSpace.count_objects

    yield iterations

    after_stat = GC.stat if GC.respond_to?(:stat)
    ObjectSpace.count_objects

    # Calculate allocated objects (TOTAL includes all objects, we want new allocations)
    allocated_objects = if before_stat && after_stat
      after_stat[:total_allocated_objects] - before_stat[:total_allocated_objects]
    else
      0
    end

    allocated_memory = if before_stat && after_stat && before_stat[:total_allocated_memsize] && after_stat[:total_allocated_memsize]
      after_stat[:total_allocated_memsize] - before_stat[:total_allocated_memsize]
    end

    {
      objects: allocated_objects,
      memory: allocated_memory
    }
  end

  it "benchmarks notify/context/reset (wall-time) with 0 to 10 reporters" do
    error = StandardError.new("error")
    ctx = {foo: "bar"}
    iterations = 5_000
    results = {}

    # Test with 0, 1, 3, 5, 7, and 10 reporters
    [0, 1, 3, 5, 7, 10].each do |count|
      ActionReporter.enabled_reporters = Array.new(count) { NoopReporter.new }
      time = measure_wall_time(iterations) do |n|
        n.times do
          ActionReporter.context(ctx)
          ActionReporter.notify(error, context: ctx)
          ActionReporter.reset_context
        end
      end
      results[count] = time
      expect(time).to be >= 0
    end

    # Log results for visibility (helpful for understanding performance)
    puts "\nPerformance results (#{iterations} iterations):"
    results.each do |count, time|
      overhead_ms = (count > 0) ? ((time - results[0]) * 1000 / count).round(3) : 0
      puts "  #{count.to_s.rjust(2)} reporter#{"s" if count != 1}: #{time.round(6)}s#{" (~#{overhead_ms}ms per reporter)" if overhead_ms > 0}"
    end

    # Calculate average overhead per reporter
    if results[1] > 0
      avg_overhead = ((results[1] - results[0]) * 1000).round(3)
      puts "  Average overhead per reporter: ~#{avg_overhead}ms"
    end

    # Measure memory allocation
    memory_results = {}
    [0, 1, 3, 5, 7, 10].each do |count|
      ActionReporter.enabled_reporters = Array.new(count) { NoopReporter.new }
      mem = measure_memory(iterations) do |n|
        n.times do
          ActionReporter.context(ctx)
          ActionReporter.notify(error, context: ctx)
          ActionReporter.reset_context
        end
      end
      memory_results[count] = mem
    end

    puts "\nMemory allocation (#{iterations} iterations):"
    memory_results.each do |count, mem|
      memory_per_op = mem[:memory] ? (mem[:memory] / iterations.to_f / 1024.0).round(2) : nil
      objects_per_op = (mem[:objects] / iterations.to_f).round(2)
      puts "  #{count.to_s.rjust(2)} reporter#{"s" if count != 1}: #{mem[:objects]} objects#{" (#{memory_per_op}KB per op)" if memory_per_op} (#{objects_per_op} objects/op)"
    end
  end

  it "benchmarks error path overhead (wall-time)" do
    error = StandardError.new("error")
    ctx = {foo: "bar"}
    ActionReporter.enabled_reporters = [FailingReporter.new]

    # Ensure no leaked logger/error_handler doubles from other examples
    allow(ActionReporter).to receive(:logger).and_return(nil)
    ActionReporter.error_handler = nil

    t = measure_wall_time(2_000) do |n|
      n.times do
        ActionReporter.notify(error, context: ctx)
      end
    end

    expect(t).to be >= 0
  end

  it "benchmarks memory allocation with context data" do
    error = StandardError.new("error")
    iterations = 2_000

    # Test with different context sizes
    contexts = {
      empty: {},
      small: {user_id: 123, request_id: "req-123"},
      medium: {
        user_id: 123,
        request_id: "req-123",
        ip: "192.168.1.1",
        user_agent: "Mozilla/5.0",
        params: {action: "index", controller: "users"},
        metadata: {timestamp: Time.now.to_i, version: "1.0"}
      },
      large: {
        user_id: 123,
        request_id: "req-123",
        ip: "192.168.1.1",
        user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)",
        params: {action: "index", controller: "users", filter: "active", page: 1},
        metadata: {timestamp: Time.now.to_i, version: "1.0", environment: "production"},
        nested: {
          session: {id: "abc123", created_at: Time.now},
          headers: {"X-Request-ID" => "req-123", "X-User-ID" => "123"},
          tags: %w[api v1 authenticated]
        }
      }
    }

    memory_results = {}

    contexts.each do |size, ctx|
      ActionReporter.enabled_reporters = [NoopReporter.new]
      mem = measure_memory(iterations) do |n|
        n.times do
          ActionReporter.context(ctx)
          ActionReporter.notify(error, context: ctx)
          ActionReporter.reset_context
        end
      end
      memory_results[size] = mem
    end

    puts "\nMemory allocation with context data (#{iterations} iterations, 1 reporter):"
    memory_results.each do |size, mem|
      memory_per_op = mem[:memory] ? (mem[:memory] / iterations.to_f / 1024.0).round(3) : nil
      objects_per_op = (mem[:objects] / iterations.to_f).round(2)
      puts "  #{size.to_s.ljust(6)} context: #{mem[:objects]} objects#{" (#{memory_per_op}KB per op)" if memory_per_op} (#{objects_per_op} objects/op)"
    end

    # Verify all measurements are reasonable
    memory_results.each_value do |mem|
      expect(mem[:objects]).to be >= 0
    end
  end
end
