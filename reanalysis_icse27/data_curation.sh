#!/usr/bash


# license change

# region 1 finding clear license change instances

# projects with more than 1 license
zcat data/P2LtFullV.s |
cut -d\; -f1,2 |
~/utils/sort.sh -t\; -u |
cut -d\; -f1 |
uniq -d |
~/utils/sort.sh -t\; -k1,1 |
LC_ALL=C LANG=C join -t\; \
    - \
    <(zcat data/P2LtFullV.s |
        ~/utils/sort.sh -t\; -k1,1) |
gzip >"$dir1/P2LtFullV.gt1"

# projects with only one license in their latest
zcat "$dir1/P2LtFullV.gt1" |
grep ";latest$" |
cut -d\; -f1,2 |
~/utils/sort.sh -t\; -u |
cut -d\; -f1 |
uniq -u |
~/utils/sort.sh -t\; -k1,1 |
LC_ALL=C LANG=C join -t\; \
    - \
    <(zcat "$dir1/P2LtFullV.gt1" |
        ~/utils/sort.sh -t\; -k1,1) |
gzip >"$dir1/P2LtFullV.gt1e1"

# aggregating license data for each project
zcat "$dir1/P2LtFullV.gt1e1" |
grep -v ";invalid$" |
awk -F\; '
    BEGIN {
        OFS= ";"
        lastP = ""
        lastL = ""
        first = ""
        last = ""
        fullData = ""
    }
    {
        P = $1
        L = $2
        if (lastP != P) {
            fullData = fullData OFS lastL OFS first OFS last
            print lastP fullData
            lastP = P
            lastL = L
            first = $3
            fullData = ""
        }
        else if (lastL != L) {
            fullData = fullData OFS lastL OFS first OFS last
            lastL = L
            first = $3
        }
        last = $3
    }
    END {
        fullData = fullData OFS lastL OFS first OFS last
        print lastP fullData
    }
' |
tail -n +2 |
gzip >"$dir1/P2allL.s"

# filtering to clear license changes
zcat "$dir1/P2allL.s" |
awk -F\; '{
    OFS = ";"
    skip = 0
    for (i = 4; i <= NF; i += 3) {
        if ($i == "latest") {
            lastL = $(i-2)
            lastLinit = $(i-1)
            firstL = $(i-2)
            firstLinit = $(i-1)
            if (lastLinit == "latest") {
                lastLinit = "2023-08"
            }
            break
        }
    }
    for (i = 3; i <= NF; i += 3) {
        if ($i < lastLinit) {
            if ($i < firstLinit) {
                firstL = $(i-1)
                firstLinit = $i
            }
            else if ($i == firstLinit) {
                skip = 1
            }
        }
    }
    if (firstL != lastL && skip == 0) {
        split(firstLinit, start, "-")
        split(lastLinit, end, "-")
        start_months = start[1] * 12 + start[2]
        end_months = end[1] * 12 + end[2]
        diff = end_months - start_months
        print $1, firstL, firstLinit, lastL, lastLinit, diff
    }
}' |
gzip >"$dir1/P2change.s"

# endregion 1

# region 2 getting basic stats

# region 2.1 all the data for change projects
# mongodb data
zcat "$dir1/P2change.s" |
cut -d\; -f1 |
uniq |
~/utils/P2mongo.sh -o "$dir1/cP2mongo" --skip-parse
~/utils/P2mongo.sh -i "$dir1/cP2mongo.gz" |
gzip >"$dir1/cP2mongo.s"

# getting all the commits with their times for change projects
for i in {0..31}; do
    LC_ALL=C LANG=C join -t\; \
        <(zcat "$dir1/P2change.s" | 
            cut -d\; -f1 | 
            uniq |
            ~/utils/sort.sh -t\; -k1,1) \
        <(zcat "$dir2/PtcFullV$i.s" |
            ~/utils/sort.sh -t\; -k1,1) |
    gzip >"$dir1/split/cP2tc.$i"
done

# uniq commits
zcat $dir1/split/cP2tc.{0..31} |
cut -d\; -f3 |
~/utils/sort.sh -t\; -u |
~/lookup/splitSec.perl $dir1/split/cPCommits. 128

# c2b, c2f, c2dat
for i in {0..127}; do
    LC_ALL=C LANG=C join -t\; \
        <(zcat "$dir1/split/cPCommits.$i") \
        <(zcat "$dir2/c2bFullV$i.s") |
    gzip >"$dir1/split/cPc2b.$i"

    LC_ALL=C LANG=C join -t\; \
        <(zcat "$dir1/split/cPCommits.$i") \
        <(zcat "$dir2/c2fFullV$i.s") |
    gzip >"$dir1/split/cPc2f.$i"

    LC_ALL=C LANG=C join -t\; \
        <(zcat "$dir1/split/cPCommits.$i") \
        <(zcat "$dir3/c2datFullV$i.s") |
    gzip >"$dir1/split/cPc2dat.$i"
done

# endregion 2.1

# region 2.2 finding 1 and 2 year interval commits

# creating index for faster search
for i in {0..31}; do
    zcat "$dir1/split/cP2tc.$i" |
    cut -d\; -f1 |
    uniq |
    gzip >"$dir1/split/cP.$i"
done

# splitting the projects
zcat "$dir1/P2change.s" |
~/utils/split.pl 128 "$dir1/split/P2change"
# getting relevant data for each interval
for i in {0..127}; do
    zcat "$dir1/split/P2change.$i" |
    awk -F\; '{if ($6 >= 12) print}' |
    while read -r line; do
        x=32
        for j in {0..31}; do 
            if LC_ALL=C LANG=C join -t\; <(echo "$line") <(zcat "$dir1/split/cP.$j") | grep -q .; then
                x=$j
                break
            fi
        done
        if [[ $x -ne 32 ]]; then 
            LC_ALL=C LANG=C join -t\; \
                <(echo "$line") \
                <(zcat "$dir1/split/cP2tc.$x") |
            awk -F\; '{
                OFS = ";"
                split($3, first, "-")
                split($5, last, "-")
                firstT = mktime(first[1]" "first[2]" 15 00 00 00")
                firstTl = firstT + 31536000
                lastT = mktime(last[1]" "last[2]" 15 00 00 00")
                lastTl = lastT + 31536000
                period = 12
                for (i = 1; i <= 2; i++) {
                    if ($6 >= period && $7 > firstT && $7 < firstTl) {
                        print $1, i"y", "first", $8
                    } else if ($6 >= period && $7 > lastT && $7 < lastTl) {
                        print $1, i"y", "last", $8
                    }
                    firstTl += 31536000
                    lastTl += 31536000
                    period += 12
                }
            }'
        fi
    done |
    ~/utils/sort.sh -t\; -u |
    gzip >"$dir1/split/cP2yic.$i"
done

# endregion 2.2

# region 2.3 - generating the stats

# sorting and splitting based on commit
zcat "$dir1/split/cP2yic".{0..127} |
awk -F\; '{OFS=";"; print $4,$1,$2,$3}' |
~/utils/sort.sh -t\; |
~/lookup/splitSec.perl "$dir1/split/c2cPyi." 128

# joining with blobs, files, authors, times
for i in {0..127}; do
    LC_ALL=C LANG=C join -t\; -o 1.2 1.3 1.4 2.2 \
        <(zcat "$dir1/split/c2cPyi.$i") \
        <(zcat "$dir1/split/cPc2b.$i") |
    ~/utils/sort.sh -t\; -u |
    gzip >"$dir1/split/cP2yib.$i"

    LC_ALL=C LANG=C join -t\; -o 1.2 1.3 1.4 2.2 \
        <(zcat "$dir1/split/c2cPyi.$i") \
        <(zcat "$dir1/split/cPc2f.$i") |
    ~/utils/sort.sh -t\; -u |
    gzip >"$dir1/split/cP2yif.$i"

    LC_ALL=C LANG=C join -t\; -o 1.2 1.3 1.4 2.2 \
        <(zcat "$dir1/split/c2cPyi.$i") \
        <(zcat "$dir1/split/cPc2dat.$i" | 
            cut -d\; -f1,4) |
    ~/utils/sort.sh -t\; -u |
    gzip >"$dir1/split/cP2yia.$i"

    LC_ALL=C LANG=C join -t\; -o 1.2 1.3 1.4 2.2 \
        <(zcat "$dir1/split/c2cPyi.$i") \
        <(zcat "$dir1/split/cPc2dat.$i" | 
            cut -d\; -f1,2) |
    awk -F\; '{OFS=";"; print $1, $2, $3, strftime("%Y-%m",$4)}' |
    ~/utils/sort.sh -t\; -u |
    gzip >"$dir1/split/cP2yit.$i"
done

# aggregating
for g in {c,b,f,a,t}; do
    zcat "$dir1/split/cP2yi$g".{0..127} |
    ~/utils/sort.sh -t\; -u |
    cut -d\; -f1-3 |
    uniq -c | 
    awk '{print $2";"$1}' |
    gzip >"$dir1/cP2yin.$g"
done

# endregion 2.3

# endregion 2

# region 3 - reuse stat

# region 3.1 all reuse data
for i in {0..127}; do
    LC_ALL=C LANG=C join -t\; \
        <(zcat "$dir1/P2change.s" | 
            cut -d\; -f1 | 
            ~/utils/sort.sh -t\; -k1,1) \
        <(zcat "$dir4/Ptb2PtFullV$i.s" |
            cut -d\; -f1,4,5 |
            ~/utils/sort.sh -t\; -k1,1) |
    uniq |
    gzip >"$dir1/split/cP2down.$i"

    LC_ALL=C LANG=C join -t\; \
        <(zcat "$dir1/P2change.s" | 
            cut -d\; -f1 | 
            ~/utils/sort.sh -t\; -k1,1) \
        <(zcat "$dir4/Ptb2PtFullV$i.s" |
            awk -F\; '{OFS=";"; print $4,$1,$5}' |
            ~/utils/sort.sh -t\; -k1,1) |
    uniq |
    gzip >"$dir1/split/cP2up.$i"
done

zcat "$dir1/split/cP2down".{0..127} |
~/utils/sort.sh -t\; -u |
~/utils/split.pl 128 "$dir1/split/cP2dPt"

zcat "$dir1/split/cP2up".{0..127} |
~/utils/sort.sh -t\; -u |
~/utils/split.pl 128 "$dir1/split/cP2uPt"

# endregion 3.1

# region 3.2 finding 1 and 2 year data and generating stats
for i in {0..127}
    for g in {dP,uP}; do
        LC_ALL=C LANG=C join -t\; \
            <(zcat "$dir1/split/P2change.$i" |
                ~/utils/sort.sh -t\; -k1,1) \
            <(zcat "$dir1/split/cP2${g}t.$i" |
                ~/utils/sort.sh -t\; -k1,1) |
        awk -F\; '{
            OFS = ";"
            split($3, first, "-")
            split($5, last, "-")
            firstT = mktime(first[1]" "first[2]" 15 00 00 00")
            firstTl = firstT + 31536000
            lastT = mktime(last[1]" "last[2]" 15 00 00 00")
            lastTl = lastT + 31536000
            period = 12
            for (i = 1; i <= 2; i++) {
                if ($6 >= period && $8 > firstT && $8 < firstTl) {
                    print $1, i"y", "first", $7
                } else if ($6 >= period && $8 > lastT && $8 < lastTl) {
                    print $1, i"y", "last", $7
                }
                firstTl += 31536000
                lastTl += 31536000
                period += 12
            }
        }' |
        ~/utils/sort.sh -t\; -u |
        gzip >"$dir1/split/cP2yi$g.$i"
    done
done

# aggregating
for g in {dP,uP}; do
    zcat "$dir1/split/cP2yi$g".{0..127} |
    ~/utils/sort.sh -t\; -u |
    cut -d\; -f1-3 |
    uniq -c | 
    awk '{print $2";"$1}' |
    gzip >"$dir1/cP2yin.$g"
done

# endregion 3.2

# endregion 3

# region 4 - aggregation

for g in {c,a,b,f,dP,uP,t}; do
    zcat "$dir1/cP2yin.$g" |
    awk -F\; '
        BEGIN {
            lp = ""
            ll = ""
        }
        {
            if (lp != $1) {
                print lp ll
                lp = $1
                ll = ""
            }
            ll = ll";"$2";"$3";"$4
        }
        END {
            print lp ll
        }
    ' |
    tail -n +2 |
    awk -F\; '{
        l = $1
        yi[1] = "1y;first"
        yi[2] = "1y;last"
        yi[3] = "2y;first"
        yi[4] = "2y;last"
        j = 0
        for (i = 1; i < 5; i++) {
            key = $(j+2)";"$(j+3)
            if (yi[i] == key) {
                l = l";"yi[i]";"$(j+4)
                j += 3
            } else {
                l = l";"yi[i]";0"
            }
        }
        print l
    }' |
    gzip >"$dir1/cP2yin.$g.agg"
done

# final table
# $1 Project; $2 fistLicense; $3 fistAdoption; $4 lastLicense; $5 lastAdoption; 
# $6 distance; $7 earliestCommit; $8 latestCommit; $9 language, $10  firstAuthors
# $11 lastAuthors; $12 firstBlobs; $13 lastBlobs; $14 firstCommits; $15 lastCommits
# $16 firstFiles; $17 lastFiles; $18 firstMonths; $19 lastMonths; $20 firstUpP
# $21 lastUpP; $22 firstDownP; $23 lastDownP

# 1 year: 50,765 total
LC_ALL=C LANG=C join -t\; -a1 \
    <(zcat "$dir1/P2change.s" |
        awk -F\; '{if ($6 >=12 && $5 < "2022-08") print}' |
        ~/utils/sort.sh -t\; -k1,1) \
    <(zcat "$dir1/cP2mongo.s" |
        cut -d\; -f1,2,3,15 |
        ~/utils/sort.sh -t\; -k1,1) |
LC_ALL=C LANG=C join -t\; -a1 - \
    <(zcat "$dir1/cP2yin.a.agg" |
        cut -d\; -f1,4,7 |
        ~/utils/sort.sh -t\; -k1,1) |
awk -F\; '{if (NF == 11) {
        print $0
    } else {
        print $0";0;0"
    }}' |
LC_ALL=C LANG=C join -t\; -a1 - \
    <(zcat "$dir1/cP2yin.b.agg" |
        cut -d\; -f1,4,7 |
        ~/utils/sort.sh -t\; -k1,1) |
awk -F\; '{if (NF == 13) {
        print $0
    } else {
        print $0";0;0"
    }}' |
LC_ALL=C LANG=C join -t\; -a1 - \
    <(zcat "$dir1/cP2yin.c.agg" |
        cut -d\; -f1,4,7 |
        ~/utils/sort.sh -t\; -k1,1) |
awk -F\; '{if (NF == 15) {
        print $0
    } else {
        print $0";0;0"
    }}' |
LC_ALL=C LANG=C join -t\; -a1 - \
    <(zcat "$dir1/cP2yin.f.agg" |
        cut -d\; -f1,4,7 |
        ~/utils/sort.sh -t\; -k1,1) |
awk -F\; '{if (NF == 17) {
        print $0
    } else {
        print $0";0;0"
    }}' |
LC_ALL=C LANG=C join -t\; -a1 - \
    <(zcat "$dir1/cP2yin.t.agg" |
        cut -d\; -f1,4,7 |
        ~/utils/sort.sh -t\; -k1,1) |
awk -F\; '{if (NF == 19) {
        print $0
    } else {
        print $0";0;0"
    }}' |
LC_ALL=C LANG=C join -t\; -a1 - \
    <(zcat "$dir1/cP2yin.uP.agg" |
        cut -d\; -f1,4,7 |
        ~/utils/sort.sh -t\; -k1,1) |
awk -F\; '{if (NF == 21) {
        print $0
    } else {
        print $0";0;0"
    }}' |
LC_ALL=C LANG=C join -t\; -a1 - \
    <(zcat "$dir1/cP2yin.dP.agg" |
        cut -d\; -f1,4,7 |
        ~/utils/sort.sh -t\; -k1,1) |
awk -F\; '{if (NF == 23) {
        print $0
    } else {
        print $0";0;0"
    }}' |
gzip >"$dir1/cP2all.1y"

# 2 year: 22,981 total
LC_ALL=C LANG=C join -t\; -a1 \
    <(zcat "$dir1/P2change.s" |
        awk -F\; '{if ($6 >=24 && $5 < "2021-08") print}' |
        ~/utils/sort.sh -t\; -k1,1) \
    <(zcat "$dir1/cP2mongo.s" |
        cut -d\; -f1,2,3,15 |
        ~/utils/sort.sh -t\; -k1,1) |
LC_ALL=C LANG=C join -t\; -a1 - \
    <(zcat "$dir1/cP2yin.a.agg" |
        cut -d\; -f1,10,13 |
        ~/utils/sort.sh -t\; -k1,1) |
awk -F\; '{if (NF == 11) {
        print $0
    } else {
        print $0";0;0"
    }}' |
LC_ALL=C LANG=C join -t\; -a1 - \
    <(zcat "$dir1/cP2yin.b.agg" |
        cut -d\; -f1,10,13 |
        ~/utils/sort.sh -t\; -k1,1) |
awk -F\; '{if (NF == 13) {
        print $0
    } else {
        print $0";0;0"
    }}' |
LC_ALL=C LANG=C join -t\; -a1 - \
    <(zcat "$dir1/cP2yin.c.agg" |
        cut -d\; -f1,10,13 |
        ~/utils/sort.sh -t\; -k1,1) |
awk -F\; '{if (NF == 15) {
        print $0
    } else {
        print $0";0;0"
    }}' |
LC_ALL=C LANG=C join -t\; -a1 - \
    <(zcat "$dir1/cP2yin.f.agg" |
        cut -d\; -f1,10,13 |
        ~/utils/sort.sh -t\; -k1,1) |
awk -F\; '{if (NF == 17) {
        print $0
    } else {
        print $0";0;0"
    }}' |
LC_ALL=C LANG=C join -t\; -a1 - \
    <(zcat "$dir1/cP2yin.t.agg" |
        cut -d\; -f1,10,13 |
        ~/utils/sort.sh -t\; -k1,1) |
awk -F\; '{if (NF == 19) {
        print $0
    } else {
        print $0";0;0"
    }}' |
LC_ALL=C LANG=C join -t\; -a1 - \
    <(zcat "$dir1/cP2yin.uP.agg" |
        cut -d\; -f1,10,13 |
        ~/utils/sort.sh -t\; -k1,1) |
awk -F\; '{if (NF == 21) {
        print $0
    } else {
        print $0";0;0"
    }}' |
LC_ALL=C LANG=C join -t\; -a1 - \
    <(zcat "$dir1/cP2yin.dP.agg" |
        cut -d\; -f1,10,13 |
        ~/utils/sort.sh -t\; -k1,1) |
awk -F\; '{if (NF == 23) {
        print $0
    } else {
        print $0";0;0"
    }}' |
gzip >"$dir1/cP2all.2y"

# endregion 4

