#!/usr/bin/env ruby

require "csv"
require "date"

input, output = ARGV
abort "usage: #{$PROGRAM_NAME} input.csv output.svg" unless input && output

rows = CSV.read(input, headers: true).map do |row|
  {
    commit: row["commit"],
    date: Date.parse(row["date"]),
    label: row["label"],
    total: Integer(row["total_declarations"]),
    active: Integer(row["statically_active_normal_debug"]),
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

svg = []
svg << %(<svg xmlns="http://www.w3.org/2000/svg" width="#{width}" height="#{height}" viewBox="0 0 #{width} #{height}">)
svg << %(<rect width="100%" height="100%" fill="#fbfaf7"/>)
svg << %(<text x="#{left}" y="42" font-family="-apple-system, sans-serif" font-size="27" font-weight="700" fill="#20242a">Test declarations during the AtCoder 2025 refactoring</text>)
svg << %(<text x="#{left}" y="70" font-family="-apple-system, sans-serif" font-size="15" fill="#59636e">Total declarations vs. statically active declarations in the normal Debug configuration</text>)

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

rows.each do |row|
  xx = x.call(row[:date])
  svg << %(<circle cx="#{xx}" cy="#{y.call(row[:total])}" r="4.5" fill="#276fbf"/>)
  svg << %(<circle cx="#{xx}" cy="#{y.call(row[:active])}" r="4.5" fill="#d05a3a"/>)
end

legend_x = width - 475
svg << %(<line x1="#{legend_x}" y1="45" x2="#{legend_x + 42}" y2="45" stroke="#276fbf" stroke-width="4"/>)
svg << %(<text x="#{legend_x + 55}" y="50" font-family="-apple-system, sans-serif" font-size="15" fill="#20242a">Total test declarations</text>)
svg << %(<line x1="#{legend_x}" y1="70" x2="#{legend_x + 42}" y2="70" stroke="#d05a3a" stroke-width="4"/>)
svg << %(<text x="#{legend_x + 55}" y="75" font-family="-apple-system, sans-serif" font-size="15" fill="#20242a">Statically active (normal Debug)</text>)

baseline = rows.first
contraction = rows.find { |row| row[:commit] == "43656817" }
current = rows.last
[
  [baseline, :active, "baseline #{baseline[:active]} active"],
  [contraction, :active, "contraction #{contraction[:active]} active"],
  [current, :total, "current #{current[:total]} total / #{current[:active]} active"],
].each_with_index do |(row, key, text), index|
  xx = x.call(row[:date])
  yy = y.call(row[key])
  anchor = index == 2 ? "end" : "start"
  tx = index == 2 ? xx - 12 : xx + 12
  svg << %(<text x="#{tx}" y="#{yy - 13}" text-anchor="#{anchor}" font-family="-apple-system, sans-serif" font-size="14" font-weight="600" fill="#20242a">#{text}</text>)
end

svg << %(<text x="#{left}" y="#{height - 63}" font-family="-apple-system, sans-serif" font-size="13" fill="#59636e">One declaration counts as one XCTest test method or one Swift Testing @Test declaration; parameterized cases are not expanded.</text>)
svg << %(<text x="#{left}" y="#{height - 40}" font-family="-apple-system, sans-serif" font-size="13" fill="#59636e">Static activity evaluates compile conditions for normal Debug: DEBUG=true, COMPATIBLE_ATCODER_2025=false, DEATH_TEST=false.</text>)
svg << %(<text x="#{left}" y="#{height - 17}" font-family="-apple-system, sans-serif" font-size="13" fill="#59636e">It is not a historical pass count; runtime skips and build failures require separate evidence.</text>)
svg << "</svg>"

File.write(output, svg.join("\n"))
