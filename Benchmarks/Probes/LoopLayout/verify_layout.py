#!/usr/bin/env python3
"""Verify the built probe: every probe_copy_N symbol has exactly the reference bytes,
its entry is at (4096 * k + pad) and its vector loop (+0x80) starts at mod64 == pad.

Usage: verify_layout.py OBJDUMP_TEXT [closure_bytes.h]
OBJDUMP_TEXT is the output of `objdump -d probe` (GNU binutils or llvm-objdump)."""
import re, sys

dump = sys.argv[1]
header = sys.argv[2] if len(sys.argv) > 2 else "closure_bytes.h"
PADS = [0, 8, 16, 24, 32, 40, 48, 56, 32, 48]

src = open(header).read()
length = int(re.search(r"#define CLOSURE_LENGTH (\d+)", src).group(1))
loop_off = int(re.search(r"#define CLOSURE_LOOP_OFFSET (0x[0-9a-f]+)", src).group(1), 16)
ref = bytes(int(x, 16) for x in re.findall(r"0x([0-9a-f]{2})", src.split("{", 1)[1]))
assert len(ref) == length, (len(ref), length)

funcs, cur = {}, None
head = re.compile(r"^([0-9a-f]+) <_?(probe_copy_\d+)>:")
insn = re.compile(r"^\s*([0-9a-f]+):\s+((?:[0-9a-f]{2}[ \t])+)")
for line in open(dump, errors="replace"):
    m = head.match(line)
    if m:
        cur = m.group(2)
        funcs[cur] = [int(m.group(1), 16), bytearray()]
        continue
    if cur:
        if line.strip() == "" or re.match(r"^[0-9a-f]+ <", line):
            cur = None
            continue
        m = insn.match(line)
        if m:
            funcs[cur][1] += bytes.fromhex(re.sub(r"\s", "", m.group(2)))

ok = True
for i, pad in enumerate(PADS):
    name = f"probe_copy_{i}"
    if name not in funcs:
        print(f"FAIL {name}: not found"); ok = False; continue
    addr, body = funcs[name]
    loop = addr + loop_off
    same = bytes(body[:length]) == ref
    placed = addr % 4096 == pad and loop % 64 == pad
    print(f"{'OK  ' if same and placed else 'FAIL'} {name} entry={addr:#x} loop={loop:#x} "
          f"entry_mod4096={addr % 4096} loop_mod32={loop % 32} loop_mod64={loop % 64} "
          f"expected_pad={pad} bytes_identical={same} disassembled_bytes={len(body)}")
    ok &= same and placed
print("ALL OK" if ok else "VERIFY FAILED")
sys.exit(0 if ok else 1)
