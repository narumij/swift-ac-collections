# Release checklist

Copy this checklist forward from `prepare/release/template` with every
`release/<version>` branch. Update it on the release branch as evidence of the
run. A checked item records an observed result; it is not a substitute for the
linked CI logs or artifacts.

## Candidate

- [x] Release branch identifies the intended version: `0.5.1-rehearsal`.
- [x] Candidate source is the `0.5.1` tagged state. The template was created
  from that tag, so this rehearsal requires no additional merge commit.
- [ ] `CHANGELOG.md` describes the intended public release.
- [ ] Public version references and package installation examples are correct.
- [ ] The diff contains no unrelated source or documentation changes.

## Materialization

- [x] `prepare_release_tree.py --apply` completed.
- [x] `verify_release_tree.py` passed after materialization.
- [x] Compatibility-only declarations and tests were removed.
- [x] Internal maintenance records and historical benchmark results were
  removed.
- [x] Sources, applicable tests, user documentation, benchmark definitions,
  and release tooling remain.

## Local verification

- [ ] Debug tests passed with the release test traits.
- [ ] Release tests passed with Death Tests enabled.
- [ ] Documentation built with warnings treated as errors.
- [x] The transformed tree contains no unexpected SwiftPM files or manifest
  exclusions.

## Remote verification

- [ ] User pushed the release branch.
- [ ] Release-tree verification passed.
- [ ] Debug, Release, Address Sanitizer, and documentation jobs passed.
- [ ] The 2M performance comparison completed against the recorded previous
  release tag, with no regression of 30% or more.
- [ ] The 2M Set and Dictionary chart suites were uploaded with their source
  result JSON.
- [ ] The selected 16M charts (`successful lookups` and `random removals`) were
  uploaded with their source result JSON.
- [ ] Benchmark environment, executed binaries, symbols, and assembly were
  uploaded.
- [ ] CI duration and artifact sizes were reviewed for future release runs.

## Completion

- [ ] User accepted the release evidence.
- [ ] The annotated version tag points to the verified release-branch tip.
- [ ] User pushed the tag.
- [ ] Tag-triggered documentation deployment passed.
- [ ] No commit was added after the version tag.

For a rehearsal, leave release-only claims such as CHANGELOG acceptance, tag
creation, tag push, and deployment unchecked. Record the observed CI evidence,
then feed reusable corrections back into `prepare/release/template`.
