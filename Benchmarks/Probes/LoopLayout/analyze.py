#!/usr/bin/env python3
"""Summarize probe CSV (warmup rows excluded). Reports distributions, not just means.

Usage: analyze.py results.csv
  code sweep: buffer 0 fixed, ratio of each copy's median to copy 4 (pad 32, the
              placement of the fast CI binaries) for the same size.
  data sweep: code copy fixed (pad 32 / pad 48), ratio of each buffer's median to
              buffer 0 for the same copy and size.
Same-placement controls: copies 4 vs 8 (pad 32), 6 vs 9 (pad 48); buffers 0 vs 1.

Exit status is 0 only if there are measured rows, every checksum is ok and every
expected (experiment, copy, buffer, size) group is present; otherwise 1."""
import csv, statistics, sys
from collections import defaultdict

CODE_COPIES = range(10)
DATA_COPIES = (4, 6)
BUFFERS = range(9)


def q(xs, p):
    xs = sorted(xs)
    k = (len(xs) - 1) * p
    lo, hi = int(k), min(int(k) + 1, len(xs) - 1)
    return xs[lo] + (xs[hi] - xs[lo]) * (k - lo)


def main(path):
    try:
        rows = [r for r in csv.DictReader(open(path)) if r["warmup"] == "0"]
    except (OSError, KeyError, csv.Error) as e:
        print(f"INVALID: cannot read measured rows: {e}")
        return 1
    if not rows:
        print("INVALID: no measured rows (empty CSV or warm-up only)")
        return 1
    valid = True
    bad = [r for r in rows if r["ok"] != "1"]
    if bad:
        print(f"INVALID: checksum failures in {len(bad)} rows")
        valid = False

    groups = defaultdict(list)  # (experiment, copy, buffer, size) -> ns
    meta = {}
    for r in rows:
        key = (r["experiment"], int(r["copy"]), int(r["buffer"]), int(r["size"]))
        groups[key].append(int(r["ns"]))
        meta[key] = (int(r["pad"]), int(r["data_off"]))
    sizes = sorted({k[3] for k in groups})
    expected = [("code", c, 0, s) for s in sizes for c in CODE_COPIES] + \
               [("data", c, b, s) for s in sizes for c in DATA_COPIES for b in BUFFERS]
    missing = [k for k in expected if k not in groups]
    if missing:
        print(f"INVALID: {len(missing)} expected groups missing, e.g. {missing[:3]}")
        return 1
    counts = {len(v) for v in groups.values()}
    print(f"rows={len(rows)} measured_rounds={len({r['round'] for r in rows})} "
          f"samples_per_group={sorted(counts)} checksum_failures={len(bad)}")

    def med(k):
        return statistics.median(groups[k])

    print("\n## code sweep (buffer 0 fixed). ratio = median / median(copy 4, pad 32)")
    print("| size | copy | pad (loop mod64) | loop mod32 | n | min ns | p25 | median | p75 | ratio |")
    print("| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |")
    for s in sizes:
        ref = med(("code", 4, 0, s))
        for c in CODE_COPIES:
            xs = groups[("code", c, 0, s)]
            pad = meta[("code", c, 0, s)][0]
            print(f"| {s} | {c} | {pad} | {pad % 32} | {len(xs)} | {min(xs)} | {q(xs, .25):.0f} | "
                  f"{statistics.median(xs):.0f} | {q(xs, .75):.0f} | {statistics.median(xs) / ref:.3f} |")

    print("\n## data sweep (code copy fixed). ratio = median / median(buffer 0, same copy)")
    print("| size | copy (pad) | buffer | data offset | n | min ns | median | p75 | ratio |")
    print("| --- | --- | --- | --- | --- | --- | --- | --- | --- |")
    for s in sizes:
        for c in DATA_COPIES:
            ref = med(("data", c, 0, s))
            for b in BUFFERS:
                xs = groups[("data", c, b, s)]
                pad, off = meta[("data", c, b, s)]
                print(f"| {s} | {c} ({pad}) | {b} | {off} | {len(xs)} | {min(xs)} | "
                      f"{statistics.median(xs):.0f} | {q(xs, .75):.0f} | {statistics.median(xs) / ref:.3f} |")

    print("\n## same-placement controls (median ratio)")
    for s in sizes:
        print(f"size {s}: copy8/copy4 (pad32) {med(('code', 8, 0, s)) / med(('code', 4, 0, s)):.3f}  "
              f"copy9/copy6 (pad48) {med(('code', 9, 0, s)) / med(('code', 6, 0, s)):.3f}  "
              f"buffer1/buffer0 (copy4) {med(('data', 4, 1, s)) / med(('data', 4, 0, s)):.3f}")
    if not valid:
        print("\nINVALID: see checksum failures above; numbers are not a result")
    return 0 if valid else 1


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    sys.exit(main(sys.argv[1]))
