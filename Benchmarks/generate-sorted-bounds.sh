#!/bin/sh
set -eu
cd "$(dirname "$0")"
swift build -c release
binary="$(swift build -c release --show-bin-path)/benchmark"
output=${1:-Results/2M/SortedBounds/$(date +%Y%m%d-%H%M%S)}
mkdir -p "$output"
{
  date -u
  sw_vers
  sysctl -n machdep.cpu.brand_string
  swift --version
  git -C .. rev-parse HEAD
  git -C .. status --short
  printf 'Release; sanitizer OFF; current package default traits\n'
  printf 'max-size=2M; smoothness=1; cycles=3; iterations=3\n'
} > "$output/environment.txt"
cp Package.resolved "$output/Package.resolved.json"
"$binary" library run --library Libraries/SortedBounds.json "$output/results.json" \
  --max-size 2M --smoothness 1 --cycles 3 --iterations 3 --mode replace-all > "$output/run.log" 2>&1
"$binary" library render --library Libraries/SortedBounds.json "$output/results.json" \
  --min-time 1ns --max-time 10us --percentile 90 --output "$output" --format png > "$output/render.log" 2>&1
printf 'Results: %s\n' "$output"
