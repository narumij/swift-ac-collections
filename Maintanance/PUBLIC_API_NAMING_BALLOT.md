# Public API naming ballot

Status: template only. The ballot is not yet compiled or accepted.

## Purpose

After all independent candidate submissions are complete, Codex compiles every distinct candidate
into this common ballot. This file fixes the candidate IDs and meanings used by all three scoring
records; it does not score or adopt a name.

## Inputs

- `PUBLIC_API_NAMING_CANDIDATES_USER.md`
- `PUBLIC_API_NAMING_CANDIDATES_CODEX.md`
- `PUBLIC_API_NAMING_CANDIDATES_CLAUDE.md`
- `ArrayObjectAndAPINamingDraft.md`
- `User/CONCEPT_DEFINITION.md`
- `QUALITY_REQUIREMENTS.md`

## Compilation rules

- Include every submitted candidate, including current-name retention candidates.
- Preserve different meanings as different candidates even when spellings overlap.
- Record aliases or exact duplicates without multiplying their weight.
- Give each candidate a stable ballot ID.
- Do not rank, score, recommend, or adopt candidates while compiling the ballot.
- Codex verifies candidate coverage, meaning separation, duplicate handling, and stable IDs before
  handing the ballot to the three independent scorers.

## Array object families

| ID | Candidate family | Submitted by | Representative spellings | Intended meaning | Known concern |
| --- | --- | --- | --- | --- | --- |
| `AO-01` | _not compiled_ |  |  |  |  |

## Array access API families

| ID | Candidate family | Submitted by | Read | Write | Mutable reference | Reference type | Intended meaning | Known concern |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `AA-01` | _not compiled_ |  |  |  |  |  |  |  |

## Other Array public names

| ID | Current role or name | Candidate | Submitted by | Intended meaning | Known concern |
| --- | --- | --- | --- | --- | --- |
| `AX-01` | _not compiled_ |  |  |  |  |

## Permutation API families

| ID | Candidate family | Submitted by | Normal factory | Normal owner / iterator | Normal yielded view | Borrowed factory | Borrowed owner / iterator | Intended meaning | Known concern |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `PF-01` | _not compiled_ |  |  |  |  |  |  |  |  |

## Other Permutation public names

| ID | Current role or name | Candidate | Submitted by | Intended meaning | Known concern |
| --- | --- | --- | --- | --- | --- |
| `PX-01` | _not compiled_ |  |  |  |  |

## Compilation verification

| Check | Result | Evidence or correction |
| --- | --- | --- |
| Every submitted candidate is represented. | _not verified_ |  |
| Distinct meanings have not been silently merged. | _not verified_ |  |
| Exact duplicates do not gain additional weight. | _not verified_ |  |
| Every scoring target has one stable ballot ID. | _not verified_ |  |
