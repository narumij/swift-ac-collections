#!/usr/bin/env ruby

require "csv"
require "date"

input, output = ARGV
abort "usage: #{$PROGRAM_NAME} input.csv output.svg" unless input && output

rows = CSV.read(input, headers: true).map do |row|
  discovered = row["runner_discovered"]
  {
    commit: row["commit"],
    date: Date.parse(row["date"]),
    label: row["label"],
    total: Integer(row["total_declarations"]),
    active: Integer(row["statically_active_normal_debug"]),
    discovered: discovered.nil? || discovered.empty? ? nil : Integer(discovered),
  }
end

width = 1600
height = 900
left = 110
right = 50
top = 95
bottom = 145
plot_width = width - left - right
plot_height = height - top - bottom
minimum_date = rows.map { |row| row[:date] }.min
maximum_date = rows.map { |row| row[:date] }.max
maximum_count = ((rows.map { |row| row[:total] }.max + 199) / 200) * 200

x = ->(date) { left + (date - minimum_date).to_f / (maximum_date - minimum_date).to_f * plot_width }
y = ->(count) { top + plot_height - count.to_f / maximum_count * plot_height }
points = ->(key) { rows.map { |row| format("%.1f,%.1f", x.call(row[:date]), y.call(row[key])) }.join(" ") }
segments = lambda do |key|
  rows.chunk_while { |left_row, right_row| left_row[key] && right_row[key] }
    .map { |segment| segment.select { |row| row[key] } }
    .select { |segment| segment.length > 1 }
end

svg = []
svg << %(<svg xmlns="http://www.w3.org/2000/svg" width="#{width}" height="#{height}" viewBox="0 0 #{width} #{height}">)
svg << %(<rect width="100%" height="100%" fill="#fbfaf7"/>)
svg << %(<text x="#{left}" y="42" font-family="-apple-system, sans-serif" font-size="27" font-weight="700" fill="#20242a">Test declarations during the AtCoder 2025 refactoring</text>)
svg << %(<text x="#{left}" y="70" font-family="-apple-system, sans-serif" font-size="15" fill="#59636e">Stored declarations, statically active declarations, and runner-discovered test units</text>)

(0..maximum_count).step(200) do |count|
  yy = y.call(count)
  svg << %(<line x1="#{left}" y1="#{yy}" x2="#{width - right}" y2="#{yy}" stroke="#d9dde2" stroke-width="1"/>)
  svg << %(<text x="#{left - 18}" y="#{yy + 5}" text-anchor="end" font-family="-apple-system, sans-serif" font-size="13" fill="#59636e">#{count}</text>)
end

month = Date.new(minimum_date.year, minimum_date.month, 1)
while month <= maximum_date
  xx = x.call(month < minimum_date ? minimum_date : month)
  svg << %(<line x1="#{xx}" y1="#{top}" x2="#{xx}" y2="#{top + plot_height}" stroke="#eceef1" stroke-width="1"/>)
  svg << %(<text x="#{xx}" y="#{top + plot_height + 28}" text-anchor="middle" font-family="-apple-system, sans-serif" font-size="13" fill="#59636e">#{month.strftime('%Y-%m')}</text>)
  month = month.next_month
end

svg << %(<polyline points="#{points.call(:total)}" fill="none" stroke="#276fbf" stroke-width="4" stroke-linejoin="round" stroke-linecap="round"/>)
svg << %(<polyline points="#{points.call(:active)}" fill="none" stroke="#d05a3a" stroke-width="4" stroke-linejoin="round" stroke-linecap="round"/>)
segments.call(:discovered).each do |segment|
  segment_points = segment.map { |row| format("%.1f,%.1f", x.call(row[:date]), y.call(row[:discovered])) }.join(" ")
  svg << %(<polyline points="#{segment_points}" fill="none" stroke="#3b8f6b" stroke-width="4" stroke-linejoin="round" stroke-linecap="round"/>)
end

rows.each do |row|
  xx = x.call(row[:date])
  svg << %(<circle cx="#{xx}" cy="#{y.call(row[:total])}" r="4.5" fill="#276fbf"/>)
  svg << %(<circle cx="#{xx}" cy="#{y.call(row[:active])}" r="4.5" fill="#d05a3a"/>)
  svg << %(<circle cx="#{xx}" cy="#{y.call(row[:discovered])}" r="4.5" fill="#3b8f6b"/>) if row[:discovered]
end

legend_x = width - 475
svg << %(<line x1="#{legend_x}" y1="45" x2="#{legend_x + 42}" y2="45" stroke="#276fbf" stroke-width="4"/>)
svg << %(<text x="#{legend_x + 55}" y="50" font-family="-apple-system, sans-serif" font-size="15" fill="#20242a">Total test declarations</text>)
svg << %(<line x1="#{legend_x}" y1="70" x2="#{legend_x + 42}" y2="70" stroke="#d05a3a" stroke-width="4"/>)
svg << %(<text x="#{legend_x + 55}" y="75" font-family="-apple-system, sans-serif" font-size="15" fill="#20242a">Statically active (normal Debug)</text>)
svg << %(<line x1="#{legend_x}" y1="95" x2="#{legend_x + 42}" y2="95" stroke="#3b8f6b" stroke-width="4"/>)
svg << %(<text x="#{legend_x + 55}" y="100" font-family="-apple-system, sans-serif" font-size="15" fill="#20242a">Runner-discovered (gaps are unbuildable)</text>)

baseline = rows.first
contraction = rows.find { |row| row[:commit] == "43656817" }
current = rows.last
[
  [baseline, :active, "baseline #{baseline[:active]} active", "start", 12, -13],
  [contraction, :active, "contraction #{contraction[:active]} active", "end", -12, -13],
  [current, :total, "current #{current[:total]} total / #{current[:active]} active", "end", -12, 30],
].each do |row, key, text, anchor, offset_x, offset_y|
  xx = x.call(row[:date])
  yy = y.call(row[key])
  svg << %(<text x="#{xx + offset_x}" y="#{yy + offset_y}" text-anchor="#{anchor}" font-family="-apple-system, sans-serif" font-size="14" font-weight="600" fill="#20242a">#{text}</text>)
end

svg << %(<text x="#{left}" y="#{height - 63}" font-family="-apple-system, sans-serif" font-size="13" fill="#59636e">One declaration counts as one XCTest test method or one Swift Testing @Test declaration; parameterized cases are not expanded.</text>)
svg << %(<text x="#{left}" y="#{height - 40}" font-family="-apple-system, sans-serif" font-size="13" fill="#59636e">Static activity evaluates compile conditions for normal Debug: DEBUG=true, COMPATIBLE_ATCODER_2025=false, DEATH_TEST=false.</text>)
svg << %(<text x="#{left}" y="#{height - 17}" font-family="-apple-system, sans-serif" font-size="13" fill="#59636e">Runner discovery uses the current toolchain; it is not a pass count, and manifest-incompatible commits remain gaps.</text>)
svg << "</svg>"

File.write(output, svg.join("\n"))
