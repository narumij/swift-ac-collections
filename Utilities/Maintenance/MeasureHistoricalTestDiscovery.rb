#!/usr/bin/env ruby

require "csv"
require "fileutils"
require "open3"
require "tmpdir"
require "timeout"

scratch_path = ENV.fetch("HISTORICAL_TEST_SCRATCH", "/tmp/swift-ac-historical-test-scratch")
timeout_seconds = Integer(ENV.fetch("HISTORICAL_TEST_TIMEOUT", "240"))

def capture(*arguments, chdir: nil)
  chdir ? Open3.capture3(*arguments, chdir: chdir) : Open3.capture3(*arguments)
end

CSV($stdout) do |csv|
  csv << %w[commit date discovered_tests status elapsed_seconds]

  ARGV.each do |revision|
    commit_output, error, status = capture("git", "rev-parse", "--verify", "#{revision}^{commit}")
    abort error unless status.success?
    commit = commit_output.strip
    date, error, status = capture("git", "show", "-s", "--format=%as", commit)
    abort error unless status.success?

    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    discovered = nil
    result = "failed"

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
            "swift", "test", "--disable-sandbox", "--scratch-path", scratch_path, "list",
            chdir: directory
          )
          warn "#{commit[0, 8]}: #{build_log.lines.last(3).join.strip}" unless test_status.success?
          result = test_status.success? ? "ok" : "build_failed"
        end
        discovered = output.lines.count { |line| !line.strip.empty? } if result == "ok"
      rescue Timeout::Error
        result = "timeout"
      end
    end

    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started
    csv << [commit[0, 8], date.strip, discovered, result, elapsed.round(1)]
    $stdout.flush
    warn "#{commit[0, 8]}: #{result}, #{discovered || '-'} tests, #{elapsed.round(1)}s"
  end
end
