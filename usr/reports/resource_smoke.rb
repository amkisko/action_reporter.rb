require "json"
require "objspace"
require "action_reporter"

ActionReporter.enabled_reporters = [ActionReporter::Base.new]
iterations = 10_000
GC.start
allocated_before = GC.stat(:total_allocated_objects)
heap_before = ObjectSpace.memsize_of_all
started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
cpu_started_at = Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID)
iterations.times do
  ActionReporter.context(request: "fixture")
  ActionReporter.notify("fixture")
  ActionReporter.reset_context
end
wall_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at
cpu_time = Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID) - cpu_started_at
GC.start
puts JSON.generate(
  iterations: iterations,
  wall_seconds: wall_time.round(6),
  cpu_seconds: cpu_time.round(6),
  allocated_objects: GC.stat(:total_allocated_objects) - allocated_before,
  retained_heap_bytes: ObjectSpace.memsize_of_all - heap_before
)
