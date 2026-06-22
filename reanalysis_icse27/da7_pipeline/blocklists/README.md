# Author blocklist used by stage 50

We use the **single official WoC V2604 bad-author list**:

```
/data/play/forks/badV2604.ids
```

(on da5, 155 MB, 3,206,105 entries; format `<raw_author>;<category>` where
category is `generic` or `bot`).

The file is too large to commit and is not in the local pipeline tree.  It
must be copied to `$SCRATCH/blocklists/badV2604.ids` on the run host
before stage 50 runs:

```sh
ssh da5 'scp /data/play/forks/badV2604.ids da7:/corrino/play/audris/lcs_icse27/blocklists/'
```

`50_classify_and_aggregate.sh` will refuse to start if the file is absent.

## Why not the smaller lists we used to ship

Earlier drafts of this directory shipped (now removed):

- `bad_authors_findHomonyms.txt` (1,734 entries from
  `~/swsc/lookup/findHomonyms.perl`)
- `bad_authors_woc.txt` (24 entries from `%badAuthors` in
  `~/swsc/lookup/woc.pm`)
- `bad_emails_findHomonyms.txt` (578 entries)
- `badEmailS` (4,776 entries from `~/lookup/badEmailS`)

`badV2604.ids` supersedes all of these.  It is the production V2604 bad-ID
list used by the alias-map build itself, two orders of magnitude larger,
and aligned to the V2604 raw-author namespace we are reading from
`c2aAcCtFull.V2604.*.s` field 2.

## Category breakdown (informational)

| Category | Count | What it covers |
|---|---|---|
| `generic` | 2,652,369 | Homonyms, placeholder identities (`<Admin@.>`, `Your Name <you@example.com>`, IP-only emails, single-char names, etc.) |
| `bot` | 553,736 | Automated identities (`dependabot[bot]`, CI bots, mirror scripts, etc.) |

Both categories are dropped in stage 50: a "generic" author is a unidentifiable
identity and should not be counted as a distinct contributor; a "bot" author
is not a human contributor.
