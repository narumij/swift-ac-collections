# ASan＋Death Test実行経路の調査

## TL;DR（人間向け）

最小packageでmacOSのASan＋Death Test失敗を再現し、子プロセス生成前の環境復元で3件成功した調査。後のstrip_env=0証拠も限定受入したが、製品全体・Linux・別Swift版の保証や適用判断ではない。

Author: Astra. User investigation request, 2026-10-16. Task: RBT-033.

<a id="範囲"></a>
## Scope

Compare macOS success/failure records and explore a working launch route with isolated reproduction. Do not change product, existing tests or CI. Old evidence is in [0.6.0 evaluation evidence](../Quality/0.6.0-1/RedBlackTreeModule/Evidence/RBT-032-2026-10-15/README.md).

<a id="調査中"></a>
## During investigation

Swift 6.4 (swiftlang-6.4.0.34.1), arm64. Current ASan CI on Linux does not specify ENABLE_DEATH_TESTS, so CI success alone does not establish combined operation on macOS.

<a id="結果"></a>
## Results

Reproduced with a minimal Swift Testing package containing no product code.

| Condition | Result |
| --- | --- |
| Native build, ASan, no environment restoration | Both normal exit(0) and fatalError child processes received SIGABRT; 2 failures |
| Set DYLD_INSERT_LIBRARIES from shell | Same 2 failures |
| Launch swiftpm-testing-helper directly and inject runtime | Same 2 failures |
| Restore DYLD_INSERT_LIBRARIES during suite initialization | Normal exit(0) and SIGTRAP: 2 successes |
| Add a direct out-of-heap store after restoration | 3 successes; invalid store printed AddressSanitizer: heap-buffer-overflow to stderr and failed, confirming detector activity |

Even in the final shell-injected test, getenv during suite initialization was `<unset>`. Restoring the value before child creation succeeded. This supports an environment-inheritance problem but does not identify the code removing the variable.

The initial negative control used UnsafeMutablePointer.initialize(to:) out of bounds but exited normally without diagnosis. Changed to a direct subscript store and confirmed detection. Retained failed-control logs; do not claim ASan detects all unsafe operations.

<a id="再現"></a>
## Reproduction

Place Package.swift from the [evidence directory](ASAN_DEATH_TEST_EVIDENCE_2026-10-16) at the isolated directory root and Probe.swift under Tests/ProbeTests/.

```sh
CLANG_MODULE_CACHE_PATH=/tmp/astra-asan-module-cache swift test --package-path /tmp/astra-asan-probe --disable-sandbox --sanitize address --build-system native
```

Probe.swift's suite initializer is an investigative implementation that setenvs this environment's absolute runtime path. Do not adopt it unchanged as a shared product fixture. To reproduce failure, remove suite init and run only the normal-exit/trap cases. Each log includes a test summary/count. Confirmed exit status 0 for the final three.

<a id="過去記録との関係"></a>
## Relation to earlier records

- RBT-032 on October 15 retained full child-runtime late-load logs. This time, reproduced similar failure without product code.
- OptionalElementBuffer/ElementBuffer quality records report combined ASan/Death Test success. Their complete launch environments could not be recovered here; differences remain unresolved.
- Current Linux ASan CI does not specify ENABLE_DEATH_TESTS; it is separate evidence from macOS combined operation.

<a id="提案と境界"></a>
## Proposal and boundaries

Candidate: test-side preparation limited to ASan configurations, preserving/restoring the actually loaded runtime path before child creation (「ASan構成に限り、子プロセス生成前に実際にロードされたruntimeのパスを保持・復元する試験側の準備」). Adoption must avoid overwriting existing DYLD settings, process-global environment changes during parallel execution, and hard-coded runtime paths.

Evidence here is limited to three minimal-package cases. All four types' Death Tests, 姫's additions, Linux and other Swift versions are unverified. Product code, existing Tests, Package.swift, CI and CLAUDE_TASK were unchanged. Formal adoption/full verification belong to later implementation scope.

<a id="追加調査の受入2026-10-16--astra"></a>
## Acceptance of additional investigation (2026-10-16 / Astra)

Integrated CP-20261016-014 as additional evidence. Original: [strip_env investigation](Evidence/ASAN-strip-env-2026-10-16/ASAN_DEATH_TEST_STRIP_ENV_REPORT.md). Read Probe and compared its no-setenv normal-exit/trap/ASan-overflow setup, saved three-test success, and DeathTests 213 successes / 360 default-condition issues. No rerun here.

Accepted saved experimental evidence of improvement with strip_env=0 on macOS. compiler-rt internal cause, fixed-revision whole-product success and Linux CI effectiveness remain unverified. Keep RBT-033 DONE as initial investigation completion; separate added fixed-revision validation into RBT-049. No product/Tests/CI adoption.

## 根拠と更新条件の追記（2026-10-17 / 姫・Opus 5.5 / OPS-076第4区切り）

入力版`1175e583b1857819e9e0b07b83a1cb5fc8be657a`。本文・原返却は変えていない。確認は`git show <版>:…`等の固定treeの読み取りだけで、実行・再レビューはしていない。

| 主張 | 確認方法と結果（成立範囲） | 更新のきっかけ |
| --- | --- | --- |
| 11行目前半「現在のASan CIはLinuxでENABLE_DEATH_TESTSを指定していない」 | `ci.yml` 384行のASan実行に`--traits`はない（通常CIについては今も成立）。ただし`candidate.yml`の145行目のjob「Run death tests with Address Sanitizer」は、152〜153行で`--sanitize address`と`--traits ENABLE_DEATH_TESTS`を併用している（RBT-049の候補CI）。前半は「通常CIでは」に限れば成立 | `.github/workflows/ci.yml`・`candidate.yml`のASan jobの変更 |
| 11行目後半「CI成功だけではmacOSの併用成功を証明しない」 | 知識（推論）なので固定treeでは確かめられない。候補CIもLinux上のjobで、この推論の前提は変わっていない | CIにmacOSのASan＋death test jobが入ったとき |

GitHub上のCI実走の成否は見ていない（ref・外部結果に依存する）。
