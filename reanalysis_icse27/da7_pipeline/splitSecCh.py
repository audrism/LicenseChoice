#!/usr/bin/env python3
"""
Drop-in replacement for ~/lookup/splitSecCh.perl that does not require
TokyoCabinet.  Computes FNV-1a-32 of the first ';'-separated field of each
input line and routes the line to <prefix><shard>.gz where shard =
fnv1a_32(field1) & (nseg - 1).

Usage:
  ... | python3 splitSecCh.py PREFIX. NSEG [SHOW]

NSEG must be a power of 2.  If SHOW is set, prints the shard number per line
instead of writing files.
"""
import sys
import gzip

# FNV-1a 32-bit per RFC, identical to Digest::FNV::XS::fnv1a_32 in cmt.pm.
FNV_OFFSET = 0x811C9DC5
FNV_PRIME  = 0x01000193
MASK32 = 0xFFFFFFFF


def fnv1a_32(s: bytes) -> int:
    h = FNV_OFFSET
    for b in s:
        h ^= b
        h = (h * FNV_PRIME) & MASK32
    return h


def main():
    if len(sys.argv) < 3:
        sys.stderr.write("usage: splitSecCh.py PREFIX. NSEG [SHOW]\n")
        sys.exit(2)
    prefix = sys.argv[1]
    nseg = int(sys.argv[2])
    if (nseg & (nseg - 1)) != 0:
        sys.stderr.write(f"NSEG must be a power of two; got {nseg}\n")
        sys.exit(2)
    mask = nseg - 1
    show = len(sys.argv) > 3

    if show:
        for line in sys.stdin.buffer:
            field1 = line.split(b";", 1)[0]
            shard = fnv1a_32(field1) & mask
            sys.stdout.buffer.write(f"{shard}\n".encode())
        return

    fhs = [None] * nseg
    try:
        for line in sys.stdin.buffer:
            field1 = line.split(b";", 1)[0]
            shard = fnv1a_32(field1) & mask
            fh = fhs[shard]
            if fh is None:
                fh = gzip.open(f"{prefix}{shard}.gz", "wb", compresslevel=4)
                fhs[shard] = fh
            fh.write(line)
    finally:
        for fh in fhs:
            if fh is not None:
                fh.close()


if __name__ == "__main__":
    main()
