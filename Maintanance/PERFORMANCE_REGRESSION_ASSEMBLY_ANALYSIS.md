# Performance Regression Investigation — Assembly Diff Review

> **Accepted independent review (2026-10-09).** This review was performed after
> Claude's investigation by a third-party AI (“Chappy”) and was explicitly adopted
> by the user. Claude's artifact analysis separately found that the measured
> sequential-access hot loop has identical instructions and differs in placement.
> This review identifies broader binary structure and generic getter differences.
> Keep both findings: their causal relationship to the measured regression remains
> unresolved and requires the verification steps below.

## Status

- Status: Accepted independent investigation
- Severity: High
- Symptom: Benchmark performance regression exceeding 30%
- Platform: Linux x86_64
- Target: Release
- Primary suspect: `PermutationModule.NextPermutationsSequence`

## 1. Background

Benchmark testing has detected a performance regression exceeding 30%.

Two disassembled Release binaries were provided for comparison:

- `benchmark_base.asm` — BASE revision
- `benchmark_head.asm` — HEAD revision

The objective is to identify machine-code differences that could explain the regression.

This document records an independent review intended to complement Claude's investigation.

## 2. Assembly Comparison Summary

Both disassembly files contain approximately 631,000 lines.

A function-level comparison, excluding address differences and other non-semantic changes, identified the following:

| Category | Result |
|---|---|
| Existing functions with changed instruction sequences | 6 |
| Newly introduced functions in HEAD | 1 |
| Primary affected component | `NextPermutationsSequence` |
| Notable affected function | `lastAscentIndex` |
| Most other functions | Normalized instruction sequences unchanged |

The significant differences appear concentrated in `PermutationModule`.

### Important qualification

Instruction-sequence differences do not necessarily imply equivalent changes in runtime cost.

The analysis must distinguish:

1. Actual additional work
2. Relocation of existing work into a separate function
3. Optimization opportunities lost across function boundaries
4. Changes in control flow or memory access patterns

## 3. Primary Finding: Buffer Subscript Getter

### BASE

Element access within `NextPermutationsSequence.Buffer` is implemented directly in the calling function.

The generated assembly performs operations including:

- Calling `__storage_ptr`
- Calculating the element offset
- Copying the element through the Value Witness Table

### HEAD

Element access has been moved behind a newly generated getter:

```text
PermutationModule.NextPermutationsSequence.Buffer.subscript.getter
```

This getter was not present as a separate function in BASE.

The newly introduced getter contains approximately 33 assembly instructions.

Its implementation includes:

```asm
call __storage_ptr
call swift_getAssociatedTypeWitness
...
jmp *%rcx
```

The final indirect jump dispatches through a function pointer associated with value operations.

### Interpretation

The key structural difference is an additional function boundary.

BASE performs element-access operations directly in the caller.

HEAD invokes a separate getter that performs those operations.

This suggests that an operation previously expanded into the caller is no longer being inlined.

This is the leading hypothesis, not yet a demonstrated root cause.

## 4. Notable Caller: lastAscentIndex

The `lastAscentIndex` implementation is particularly important.

### BASE

Element-access logic appears directly in the function.

### HEAD

The implementation calls the new `Buffer.subscript.getter`.

Two getter call sites were identified in the HEAD implementation.

Because permutation algorithms repeatedly compare adjacent elements, element-access overhead may be amplified within the search loop.

### Potential performance consequences

Possible consequences include:

- Additional function-call overhead
- Additional register preservation or restoration
- Reduced optimization across function boundaries
- Reduced common-subexpression elimination
- Repeated loading of metadata or associated-type witnesses
- Reduced ability to optimize memory access
- Additional indirect calls or jumps

These are possible consequences, not individually verified regressions.

In particular, BASE already performs calls involving storage access and value witnesses.

It would therefore be incorrect to attribute the entire regression merely to one additional function call.

## 5. Primary Hypothesis

### H1: Loss of inlining causes the regression

The most likely explanation is that introducing or retaining a separate `Buffer.subscript.getter` prevents the compiler from optimizing element access as effectively as before.

The performance impact may come from both:

1. The direct overhead of getter calls.
2. Optimization opportunities lost when element-access operations are no longer visible in the calling function.

The second possibility may be more important than the first.

### Confidence

- Structural assembly difference: High
- Getter involvement in the affected code: High
- Performance impact of the difference: Plausible
- Explanation of the entire 30%+ regression: Not yet established

## 6. Recommended Investigation

### Step 1: Inspect the Swift source diff

Identify changes affecting:

- `NextPermutationsSequence.Buffer`
- `Buffer.subscript`
- `lastAscentIndex`
- Storage pointer access
- Generic constraints
- `@inlinable` and `@inline(__always)` annotations

Determine why the getter is no longer inlined into the caller.

Do not assume that the getter's source implementation itself has changed.

### Step 2: Investigate the inlining decision

Check whether the changed function boundary results from:

- Source-level refactoring
- Access control
- Generic specialization
- Cross-module optimization
- Changes to protocol requirements
- Changes in compiler visibility
- Changes to ownership conventions
- Changes in emitted SIL

Compare optimized SIL if practical.

The goal is to determine whether the compiler is unable or unwilling to inline the getter, and why.

### Step 3: Verify hot-path relevance

Confirm whether the regressed benchmarks actually execute:

```text
NextPermutationsSequence.lastAscentIndex
```

and the newly generated:

```text
NextPermutationsSequence.Buffer.subscript.getter
```

The assembly difference alone does not prove that these functions account for the measured regression.

If the regressed benchmarks exercise another algorithm, investigate that algorithm independently.

### Step 4: Conduct a minimal A/B experiment

Test a minimal change intended to restore the previous inlining behavior.

Possible experiments:

1. Add `@inline(__always)` to the getter, if permitted.
2. Restore the previous element-access implementation.
3. Compare the optimized SIL.
4. Compare the resulting assembly.
5. Run the same benchmark under identical conditions.

Treat `@inline(__always)` as a diagnostic experiment rather than an automatic permanent solution.

The experiment should answer:

> Does restoring the previous machine-code structure also restore benchmark performance?

### Step 5: Check benchmark reproducibility

Ensure both revisions use identical:

- Swift compiler versions
- Optimization flags
- Build configuration
- Benchmark inputs
- Execution environment
- Measurement methodology

Re-run measurements sufficiently to distinguish a persistent regression from benchmark noise.

## 7. Acceptance Criteria

The investigation is complete when:

- [ ] The specific regressed benchmarks are identified.
- [ ] Their relationship to the changed functions is established.
- [ ] The reason for the getter's separate code generation is understood.
- [ ] A minimal source-level experiment is performed.
- [ ] The resulting assembly is compared with BASE.
- [ ] Benchmark performance is measured again.
- [ ] The root cause is supported by both generated code and measurements.

A successful fix should restore performance without sacrificing correctness, memory safety, or maintainability.

## 8. Current Assessment

The current evidence points toward an inlining-related optimization regression in:

```text
PermutationModule.NextPermutationsSequence.Buffer
```

The most important observed change is the introduction of a separately compiled subscript getter.

The affected `lastAscentIndex` implementation now contains calls to that getter.

This creates a plausible mechanism for increased overhead in repeated element comparisons.

However, the assembly difference has not yet been causally linked to the measured 30%+ regression.

**Recommended next action:**

Perform a minimal A/B experiment that restores the previous element-access code generation, then compare benchmark results.

## 9. Instructions for the Coding Agent

Please independently verify the findings above against the supplied assembly files and current source tree.

Priorities:

1. Confirm the reported assembly differences.
2. Identify the precise source change responsible.
3. Determine whether the changed getter is on the regressed benchmark's hot path.
4. Inspect optimized SIL and generated assembly.
5. Propose the smallest corrective change.
6. Validate the change through benchmarks.

Do not assume the hypothesis is correct merely because it is documented here.

Distinguish confirmed observations from interpretations and unverified hypotheses.

Do not perform unrelated refactoring.

Report:

- Confirmed root cause, or remaining uncertainty
- Relevant source locations
- Relevant assembly excerpts
- Minimal proposed fix
- Before/after benchmark results
- Any remaining risks
