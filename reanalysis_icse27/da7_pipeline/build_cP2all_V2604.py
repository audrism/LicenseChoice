#!/usr/bin/env python3
"""
Pivot the long per-(project, window) aggregates into a wide one-row-per-project
table compatible with the columns of cP2all.1y (plus the new PRE-window cols).

Input:
  --windows  cP2windows.V2604.gz   project;window;ncmt;nfiles;nblobs;nmonths
  --p2change P2change.V2604.s      project;firstLic;firstAdop;lastLic;lastAdop;
                                    distance;firstT;lastT;oldList;flag

Output (semicolon-separated, no header):
  project;firstLic;firstAdop;lastLic;lastAdop;distance;firstT;lastT;
  firstNcmt;firstNfiles;firstNblobs;firstActMon;
  lastNcmt;lastNfiles;lastNblobs;lastActMon;
  preNcmt;preNfiles;preNblobs;preActMon
"""
import argparse
import gzip
import sys
from collections import defaultdict


def opener(p):
    # Sniff gzip magic regardless of extension.
    with open(p, "rb") as f:
        magic = f.read(2)
    if magic == b"\x1f\x8b":
        return gzip.open(p, "rt")
    return open(p, "r")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--windows", required=True)
    ap.add_argument("--p2change", required=True)
    ap.add_argument("--out", required=True)
    args = ap.parse_args()

    # window aggregates: per-project per-window counts
    wnd = defaultdict(lambda: defaultdict(lambda: [0, 0, 0, 0]))
    with opener(args.windows) as f:
        for line in f:
            parts = line.rstrip("\n").split(";")
            if len(parts) < 6:
                continue
            pid, win = parts[0], parts[1]
            try:
                ncmt, nfiles, nblobs, nmonths = (int(parts[2]), int(parts[3]),
                                                 int(parts[4]), int(parts[5]))
            except ValueError:
                continue
            wnd[pid][win] = [ncmt, nfiles, nblobs, nmonths]
    sys.stderr.write(f"windows loaded for {len(wnd):,} projects\n")

    # Walk P2change.V2604 in order so each project appears once and we keep its
    # full row of license metadata.
    n_written = 0
    n_pre_nonzero = 0
    n_last_nonzero = 0
    n_first_nonzero = 0
    with opener(args.p2change) as fin, open(args.out, "w") as fout:
        for line in fin:
            parts = line.rstrip("\n").split(";")
            if len(parts) < 10:
                continue
            pid = parts[0]
            # keep the first 10 cols (newP;firstLic;firstAdop;lastLic;lastAdop;
            #  dist;firstT;lastT;oldList;flag) so the output preserves the
            # consolidation diagnostics for the supplement.
            head = parts[:10]
            w = wnd.get(pid, {})
            first = w.get("FIRST", [0, 0, 0, 0])
            last  = w.get("LAST",  [0, 0, 0, 0])
            pre   = w.get("PRE",   [0, 0, 0, 0])
            if first[0] > 0: n_first_nonzero += 1
            if last[0]  > 0: n_last_nonzero  += 1
            if pre[0]   > 0: n_pre_nonzero   += 1
            row = head + [str(v) for v in (first + last + pre)]
            fout.write(";".join(row) + "\n")
            n_written += 1

    sys.stderr.write(
        f"wrote {n_written:,} rows; "
        f"FIRST>0={n_first_nonzero:,}, LAST>0={n_last_nonzero:,}, PRE>0={n_pre_nonzero:,}\n"
    )


if __name__ == "__main__":
    main()
