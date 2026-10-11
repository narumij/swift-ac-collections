#!/usr/bin/env ruby

require "open3"

TEST_DECLARATION = /^\s*(?:func\s+test[A-Za-z0-9_]*\s*\(|@Test(?:\s|\(|$))/

def git(*arguments)
  output, status = Open3.capture2("git", *arguments)
  abort "git #{arguments.join(' ')} failed" unless status.success?
  output
end

def condition_value(expression)
  value = expression.dup
  value.gsub!(/\/\/.*$/, "")
  value.gsub!(/os\([^)]+\)|arch\([^)]+\)|canImport\([^)]+\)|swift\([^)]+\)|compiler\([^)]+\)/, "false")
  value.gsub!(/\bDEBUG\b/, "true")
  value.gsub!(/\bCOMPATIBLE_ATCODER_2025\b|\bDEATH_TEST\b/, "false")
  value.gsub!(/\b[A-Z][A-Z0-9_]*\b/, "false")
  return false unless value.match?(/\A[\s()!&|truefals]+\z/)

  eval(value.gsub("&&", " and ").gsub("||", " or ").gsub(/!(?!=)/, " not "))
rescue SyntaxError
  false
end

def counts(source)
  total = 0
  active = 0
  stack = []
  enabled = true

  source.each_line do |line|
    case line
    when /^\s*#if\s+(.+)/
      parent = enabled
      branch = condition_value(Regexp.last_match(1))
      stack << [parent, branch]
      enabled = parent && branch
    when /^\s*#elseif\s+(.+)/
      parent, taken = stack.last
      branch = !taken && condition_value(Regexp.last_match(1))
      stack[-1] = [parent, taken || branch]
      enabled = parent && branch
    when /^\s*#else\b/
      parent, taken = stack.last
      enabled = parent && !taken
      stack[-1] = [parent, true]
    when /^\s*#endif\b/
      parent, = stack.pop
      enabled = parent
    else
      next unless line.match?(TEST_DECLARATION)
      total += 1
      active += 1 if enabled
    end
  end

  [total, active]
end

puts "commit,date,total_declarations,statically_active_normal_debug"
ARGV.each do |revision|
  commit = git("rev-parse", "--verify", "#{revision}^{commit}").strip
  date = git("show", "-s", "--format=%as", commit).strip
  path_prefix = ENV.fetch("HISTORICAL_TEST_PATH_PREFIX", "Tests")
  paths = git("ls-tree", "-r", "--name-only", commit, "--", "Tests")
    .lines.map(&:strip)
    .select { |path| path.end_with?(".swift") && path.start_with?(path_prefix) }
  total = 0
  active = 0
  paths.each do |path|
    file_total, file_active = counts(git("show", "#{commit}:#{path}"))
    total += file_total
    active += file_active
  end
  puts [commit[0, 8], date, total, active].join(",")
end
