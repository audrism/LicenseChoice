#!/usr/bin/env python3
"""
Compute year-before-final-license-adoption and year-after-final-license-adoption
metrics for license-change projects, from cP2mongo.gz.
"""
import gzip
import json
import sys
from datetime import datetime

P2CHANGE = "/home/mjahansh/repos/lcs/data/choice/P2change.s"
P2MONGO  = "/home/mjahansh/repos/lcs/data/choice/cP2mongo.gz"
OUTFILE  = "/home/audris/tmp/lcs_icse27/cP2pre_post.1y"

def parse_yyyy_mm(s):
    return datetime.strptime(s + "-15", "%Y-%m-%d")

def months_between(a, b):
    return (a.year - b.year) * 12 + (a.month - b.month)

# Load P2change: project -> (firstAdoption, lastAdoption, distance, language placeholder)
proj_dates = {}
with open(P2CHANGE) as f:
    for line in f:
        parts = line.rstrip("\n").split(";")
        if len(parts) < 6:
            continue
        pid = parts[0]
        first_adop = parts[2]
        last_adop  = parts[4]
        distance   = int(parts[5])
        if distance < 12:
            continue
        proj_dates[pid] = (parse_yyyy_mm(first_adop), parse_yyyy_mm(last_adop), distance)

sys.stderr.write(f"Loaded {len(proj_dates):,} projects from P2change.s (distance>=12)\n")

# Process cP2mongo.gz: per-project month dicts
out = open(OUTFILE, "w")
out.write("ProjectID;preNcmt;postNcmt;firstNcmt;preNauth;postNauth;firstNauth;preActMon;postActMon;firstActMon\n")

n_written = 0
n_seen = 0
with gzip.open(P2MONGO, "rt") as f:
    for line in f:
        n_seen += 1
        try:
            d = json.loads(line)
        except Exception:
            continue
        pid = d.get("ProjectID")
        if pid not in proj_dates:
            continue
        first_t, last_t, distance = proj_dates[pid]

        mon_ncmt  = d.get("MonNcmt", {})
        mon_nauth = d.get("MonNauth", {})

        pre_ncmt = post_ncmt = first_ncmt = 0
        pre_auth = post_auth = first_auth = 0
        pre_act  = post_act  = first_act  = 0

        for m_str, c in mon_ncmt.items():
            try:
                mdt = parse_yyyy_mm(m_str)
            except Exception:
                continue
            delta_last = months_between(mdt, last_t)
            delta_first = months_between(mdt, first_t)
            if -12 <= delta_last < 0:
                pre_ncmt += c
                pre_act  += 1
            elif 0 <= delta_last < 12:
                post_ncmt += c
                post_act  += 1
            if 0 <= delta_first < 12:
                first_ncmt += c
                first_act  += 1
        for m_str, c in mon_nauth.items():
            try:
                mdt = parse_yyyy_mm(m_str)
            except Exception:
                continue
            delta_last = months_between(mdt, last_t)
            delta_first = months_between(mdt, first_t)
            if -12 <= delta_last < 0:
                pre_auth += c
            elif 0 <= delta_last < 12:
                post_auth += c
            if 0 <= delta_first < 12:
                first_auth += c

        out.write(f"{pid};{pre_ncmt};{post_ncmt};{first_ncmt};{pre_auth};{post_auth};{first_auth};{pre_act};{post_act};{first_act}\n")
        n_written += 1

out.close()
sys.stderr.write(f"Seen {n_seen:,} mongo records, wrote {n_written:,}\n")
