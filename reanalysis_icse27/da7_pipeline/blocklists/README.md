# Author/email blocklists used by stage 50

Filter sources, used in `50_classify_and_aggregate.sh` to drop bot and
homonym authors *before* aggregating distinct aliased-author counts per
(project, window).

## Canonical lists (used by the pipeline)

| File | Entries | Source |
|---|---|---|
| `bad_authors_combined.txt` | 1,677 | Union of WoC official sources (below) |
| `bad_emails_combined.txt` | 5,156 | Union of WoC official sources (below) |

## Underlying official sources

| File | Entries | Provenance |
|---|---|---|
| `bad_authors_findHomonyms.txt` | 1,734 raw (1,660 unique) | `$badAuthHere` here-doc in `~/swsc/lookup/findHomonyms.perl`, the script WoC uses to build its alias map.  This is the canonical "drop these from alias resolution" list. |
| `bad_authors_woc.txt` | 24 | `%badAuthors` hash in `~/swsc/lookup/woc.pm` — newer additions (DANDI, github-actions, ...) layered on top of findHomonyms. |
| `bad_emails_findHomonyms.txt` | 578 | `$badEmailHere` here-doc in `~/swsc/lookup/findHomonyms.perl` — the WoC-canonical bad-email list (noreply patterns, `example.com`, etc.). |
| `badEmailS` | 4,776 | `~/lookup/badEmailS` — the larger live blocklist of personal/test emails. |

Internal duplicates removed by `LC_ALL=C sort -u`.

## No regex heuristics

Earlier drafts of the filter used substring matches (`[bot]`,
`@users.noreply.github.com`) to catch bot accounts.  We dropped this in
favor of the explicit canonical lists because:

1. The canonical findHomonyms list already includes essentially every
   GitHub `[bot]` identity we care about (`dependabot[bot]`,
   `renovate[bot]`, `greenkeeper[bot]`, `imgbot[bot]`, etc.).
2. `@users.noreply.github.com` is ALSO used by many real humans who keep
   their personal email private; the c2aAcCt alias map resolves many of
   those to the noreply form (e.g., `Jiyong Youn <hletrd@users.noreply.github.com>`).
   A regex filter on this domain false-positives real authors.

If a new bot account appears that is not on the canonical list, the right
fix is to add it to `findHomonyms.perl` upstream and re-derive the lists
here, not to extend the local regex.

## Rebuild

```sh
ssh da5 "awk 'BEGIN{f=0} /badAuthHere.*<<.*EOT/{f=1; next} /^EOT/{if(f){f=0;exit}} f' ~/swsc/lookup/findHomonyms.perl" > bad_authors_findHomonyms.txt
ssh da5 "awk 'BEGIN{found=0; f=0} /<<.*EOT/{found++; if(found==2){f=1; next}} /^EOT/{if(f){f=0;exit}} f' ~/swsc/lookup/findHomonyms.perl" > bad_emails_findHomonyms.txt
ssh da5 'perl -e "use lib qq{$ENV{HOME}/swsc/lookup}; require qq{woc.pm}; for my \$k (keys %woc::badAuthors) {print \"\$k\\n\"}"' > bad_authors_woc.txt
scp da5:/home/audris/lookup/badEmailS .
cat bad_authors_woc.txt bad_authors_findHomonyms.txt | LC_ALL=C sort -u > bad_authors_combined.txt
cat badEmailS bad_emails_findHomonyms.txt | LC_ALL=C sort -u > bad_emails_combined.txt
```
