#!/usr/bin/env ruby

require "csv"
require "fileutils"
require "open3"
require "tmpdir"
require "timeout"

scratch_path = ENV.fetch("HISTORICAL_TEST_SCRATCH", "/tmp/swift-ac-historical-test-scratch")
timeout_seconds = Integer(ENV.fetch("HISTORICAL_TEST_TIMEOUT", "240"))
test_filter = Regexp.new(ENV.fetch("HISTORICAL_TEST_FILTER", ".*"))

def capture(*arguments, chdir: nil)
  chdir ? Open3.capture3(*arguments, chdir: chdir) : Open3.capture3(*arguments)
end

CSV($stdout) do |csv|
  csv << %w[commit date discovered_tests all_discovered_tests status elapsed_seconds]

  ARGV.each do |revision|
    commit_output, error, status = capture("git", "rev-parse", "--verify", "#{revision}^{commit}")
    abort error unless status.success?
    commit = commit_output.strip
    date, error, status = capture("git", "show", "-s", "--format=%as", commit)
    abort error unless status.success?

    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    discovered = nil
    all_discovered = nil
    result = "failed"
    commit_scratch_path = "#{scratch_path}-#{commit[0, 8]}"
    FileUtils.rm_rf(commit_scratch_path)

    Dir.mktmpdir("swift-ac-historical-test-") do |directory|
      archive_statuses = Open3.pipeline(
        ["git", "archive", commit],
        ["tar", "-x", "-C", directory],
        err: File::NULL
      )
      unless archive_statuses.all?(&:success?)
        result = "archive_failed"
        next
      end

      begin
        output = ""
        Timeout.timeout(timeout_seconds) do
          output, build_log, test_status = capture(
            "swift", "test", "--disable-sandbox", "--scratch-path", commit_scratch_path, "list",
            chdir: directory
          )
          warn "#{commit[0, 8]}: #{build_log.lines.last(3).join.strip}" unless test_status.success?
          result = test_status.success? ? "ok" : "build_failed"
        end
        if result == "ok"
          test_lines = output.lines.reject { |line| line.strip.empty? }
          all_discovered = test_lines.length
          discovered = test_lines.count { |line| line.match?(test_filter) }
        end
      rescue Timeout::Error
        result = "timeout"
      end
    end

    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started
    csv << [commit[0, 8], date.strip, discovered, all_discovered, result, elapsed.round(1)]
    $stdout.flush
    warn "#{commit[0, 8]}: #{result}, #{discovered || '-'} tests, #{elapsed.round(1)}s"
  end
end
