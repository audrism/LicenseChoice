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

# Optional: path to a GHArchive-derived star-event map. Expected format
# (sorted by project, one event per line):
#   project_id;starred_at_unix_ts
# When the map exists, we compute STARS_AT_LAST = cumulative star count
# at the final license adoption date (a proper pre-treatment proxy) and
# STARS_TOTAL = lifetime cumulative star count.
P2STAR_EVENTS = "/home/mjahansh/repos/lcs/data/choice/P2starEvents.s"

# Use gzip.open instead of open for P2change since the file is gzipped
# despite the .s extension.

def parse_yyyy_mm(s):
    return datetime.strptime(s + "-15", "%Y-%m-%d")

def months_between(a, b):
    return (a.year - b.year) * 12 + (a.month - b.month)

# Load P2change: project -> (firstAdoption, lastAdoption, distance, language placeholder)
proj_dates = {}
with gzip.open(P2CHANGE, "rt") as f:
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

# Optional: load star events. The file is expected to be pre-sorted by
# project so we can stream it; for each project we count events with
# timestamp <= lastAdoption (pre-treatment proxy) and total events.
import os
stars_at_last  = {}  # pid -> cumulative stars at last_adoption
stars_total    = {}  # pid -> lifetime stars
if os.path.exists(P2STAR_EVENTS):
    sys.stderr.write(f"Loading star events from {P2STAR_EVENTS}...\n")
    opener = gzip.open if P2STAR_EVENTS.endswith(".gz") else open
    mode = "rt" if P2STAR_EVENTS.endswith(".gz") else "r"
    with opener(P2STAR_EVENTS, mode) as f:
        for line in f:
            parts = line.rstrip("\n").split(";")
            if len(parts) < 2:
                continue
            pid = parts[0]
            if pid not in proj_dates:
                continue
            try:
                ts = int(parts[1])
            except Exception:
                continue
            stars_total[pid] = stars_total.get(pid, 0) + 1
            last_dt = proj_dates[pid][1]  # datetime for lastAdoption
            event_dt = datetime.fromtimestamp(ts)
            if event_dt <= last_dt:
                stars_at_last[pid] = stars_at_last.get(pid, 0) + 1
    sys.stderr.write(f"Star events available for {len(stars_total):,} projects\n")
else:
    sys.stderr.write(f"No star events file at {P2STAR_EVENTS}; StarsAtLast=0\n")

# Process cP2mongo.gz: per-project month dicts
out = open(OUTFILE, "w")
out.write("ProjectID;preNcmt;postNcmt;firstNcmt;preNauth;postNauth;firstNauth;preActMon;postActMon;firstActMon;NumForks;CommunitySize;NumCore;StarsAtLast;StarsTotal\n")

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

        # Lifetime popularity proxies from mongo aggregate.
        # Note: NumForks and CommunitySize are snapshot values at data-extraction
        # time. They are pre-treatment with respect to the regression target
        # (the change in metrics around the FINAL license switch) only for
        # projects whose final switch precedes the extraction date; for the
        # rest they are at worst contemporaneous. We treat them as static
        # popularity proxies in the same spirit as a star count.
        num_forks      = int(d.get("NumForks", 0) or 0)
        community_size = int(d.get("CommunitySize", 0) or 0)
        num_core       = int(d.get("NumCore", 0) or 0)

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

        stars_pre   = stars_at_last.get(pid, 0)
        stars_lifetime = stars_total.get(pid, 0)

        out.write(
            f"{pid};{pre_ncmt};{post_ncmt};{first_ncmt};"
            f"{pre_auth};{post_auth};{first_auth};"
            f"{pre_act};{post_act};{first_act};"
            f"{num_forks};{community_size};{num_core};"
            f"{stars_pre};{stars_lifetime}\n"
        )
        n_written += 1

out.close()
sys.stderr.write(f"Seen {n_seen:,} mongo records, wrote {n_written:,}\n")
