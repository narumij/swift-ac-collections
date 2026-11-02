#!/usr/bin/env bash
# Build, verify and run the reduced placement probe on native x86-64 Linux, then
# summarize. All evidence goes to OUTDIR (use a location not tracked by git).
# Usage: ./run.sh OUTDIR
# Env:   CPU=<core to pin; default: lowest core in this process's affinity mask>
#        SEED=<20261102>  ROUNDS=<21>  WARMUP=<2>  MAX_SECONDS=<300>
#        SIZES=<64,256,1024>  ELEMENTS_PER_SAMPLE=<16777216>
# Exit status is non-zero if build/verify fails, any checksum fails, the probe stops
# early, or the CSV is empty. Partial output is kept for inspection but is not a result.
set -euo pipefail
if [ $# -ne 1 ]; then
    echo "usage: $0 OUTDIR" >&2
    exit 2
fi
here=$(cd "$(dirname "$0")" && pwd)
out=$1
mkdir -p "$out"

if [ "$(uname -s)" != Linux ] || [ "$(uname -m)" != x86_64 ]; then
    echo "refusing: timing needs native x86-64 Linux (got $(uname -s) $(uname -m))." >&2
    echo "emulated or non-x86 runs must not be used for placement conclusions." >&2
    exit 2
fi
if ! command -v taskset >/dev/null 2>&1; then
    echo "refusing: taskset not found; the probe must be pinned to one core." >&2
    exit 2
fi
cpu=${CPU:-$(python3 -c 'import os; print(min(os.sched_getaffinity(0)))')}
seed=${SEED:-20261102}
rounds=${ROUNDS:-21}
warmup=${WARMUP:-2}
max_seconds=${MAX_SECONDS:-300}
sizes=${SIZES:-64,256,1024}
eps=${ELEMENTS_PER_SAMPLE:-16777216}

{
    echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "uname: $(uname -a)"
    echo "cc: $(${CC:-cc} --version | head -1)"
    echo "objdump: $(objdump --version | head -1)"
    echo "seed=$seed rounds=$rounds warmup=$warmup max_seconds=$max_seconds"
    echo "sizes=$sizes elements_per_sample=$eps cpu=$cpu"
    echo "affinity: $(python3 -c 'import os; print(sorted(os.sched_getaffinity(0)))')"
    echo "--- lscpu"; lscpu 2>/dev/null || echo unavailable
    echo "--- /proc/cpuinfo (first processor)"; sed -n '1,/^$/p' /proc/cpuinfo
    echo "--- scaling governor (cpu $cpu)"
    cat "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor" 2>/dev/null || echo unavailable
    echo "--- loadavg before"; cat /proc/loadavg
} > "$out/environment.txt"

"$here/build.sh" "$out"

status=0
taskset -c "$cpu" "$out/probe" --seed "$seed" --rounds "$rounds" --warmup "$warmup" \
    --max-seconds "$max_seconds" --sizes "$sizes" --elements-per-sample "$eps" \
    > "$out/results.csv" 2> "$out/probe-meta.txt" || status=$?
echo "probe exit status: $status" | tee -a "$out/probe-meta.txt"
{ echo "--- loadavg after"; cat /proc/loadavg; } >> "$out/environment.txt"

analyze_status=0
python3 "$here/analyze.py" "$out/results.csv" > "$out/summary.md" || analyze_status=$?
cat "$out/summary.md"
if [ "$status" -ne 0 ] || [ "$analyze_status" -ne 0 ]; then
    echo "run NOT complete (probe $status, analyze $analyze_status); output kept in $out" >&2
    exit 1
fi
