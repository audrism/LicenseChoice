#!/usr/bin/env python3
"""
Drop-in replacement for ~/lookup/splitSec.perl.

splitSec.perl in the WoC repo is documented for hash-like (SHA1) keys, but in
practice it routes on the same sHash() that splitSecCh.perl uses (FNV-1a-32
of the first field).  So both are implemented identically here.
"""
import sys
from pathlib import Path

# Re-use the body of splitSecCh.py
here = Path(__file__).parent
sys.path.insert(0, str(here))
from splitSecCh import main  # noqa: E402


if __name__ == "__main__":
    main()
