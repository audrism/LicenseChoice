#!/usr/bin/env python3
"""
Pivot the long per-(project, window) aggregates into a wide one-row-per-project
table compatible with the columns of cP2all.1y (plus the new PRE-window cols
and bot-filtered distinct-author counts).

Input:
  --windows  cP2windows.V2604.gz   project;window;ncmt;nfiles;nblobs;nmonths;nauthors
  --p2change P2change.V2604.s      project;firstLic;firstAdop;lastLic;lastAdop;
                                    distance;firstT;lastT;oldList;flag

Output (semicolon-separated, no header):
  project;firstLic;firstAdop;lastLic;lastAdop;distance;firstT;lastT;
  oldList;flag;
  firstNcmt;firstNfiles;firstNblobs;firstActMon;firstNauthors;
  lastNcmt;lastNfiles;lastNblobs;lastActMon;lastNauthors;
  preNcmt;preNfiles;preNblobs;preActMon;preNauthors

(10 license/meta cols + 3 windows x 5 metrics = 25 cols total.)
"""
import argparse
import gzip
import sys
from collections import defaultdict


N_METRICS = 5      # ncmt, nfiles, nblobs, nmonths, nauthors


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
    wnd = defaultdict(lambda: defaultdict(lambda: [0] * N_METRICS))
    with opener(args.windows) as f:
        for line in f:
            parts = line.rstrip("\n").split(";")
            if len(parts) < 2 + N_METRICS:
                continue
            pid, win = parts[0], parts[1]
            try:
                values = [int(parts[2 + i]) for i in range(N_METRICS)]
            except ValueError:
                continue
            wnd[pid][win] = values
    sys.stderr.write(f"windows loaded for {len(wnd):,} projects\n")

    # Walk P2change.V2604 in order so each project appears once and we keep its
    # full row of license metadata.
    n_written = 0
    n_first_nonzero = n_last_nonzero = n_pre_nonzero = 0
    n_authors_first = n_authors_last = n_authors_pre = 0
    with opener(args.p2change) as fin, open(args.out, "w") as fout:
        for line in fin:
            parts = line.rstrip("\n").split(";")
            if len(parts) < 10:
                continue
            pid = parts[0]
            head = parts[:10]
            w = wnd.get(pid, {})
            first = w.get("FIRST", [0] * N_METRICS)
            last  = w.get("LAST",  [0] * N_METRICS)
            pre   = w.get("PRE",   [0] * N_METRICS)
            if first[0] > 0: n_first_nonzero += 1
            if last[0]  > 0: n_last_nonzero  += 1
            if pre[0]   > 0: n_pre_nonzero   += 1
            if first[4] > 0: n_authors_first += 1
            if last[4]  > 0: n_authors_last  += 1
            if pre[4]   > 0: n_authors_pre   += 1
            row = head + [str(v) for v in (first + last + pre)]
            fout.write(";".join(row) + "\n")
            n_written += 1

    sys.stderr.write(
        f"wrote {n_written:,} rows; "
        f"FIRST>0 commits={n_first_nonzero:,} authors={n_authors_first:,}; "
        f"LAST>0 commits={n_last_nonzero:,} authors={n_authors_last:,}; "
        f"PRE>0 commits={n_pre_nonzero:,} authors={n_authors_pre:,}\n"
    )


if __name__ == "__main__":
    main()
