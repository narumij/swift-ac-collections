# 完了・除外task記録（2026-10-14）

この文書は、2026-10-14に`Maintanance/PROGRESS_OVERVIEW.md`の現行Task Registryから履歴化した
`DONE`・`EXCLUDED` task行、充足済みprecedence、および完了した中間ゴールの記録である。
現行task状態、所有者、依存、再開条件の判断には使用しない。

## 完了した中間ゴール

### 0.5.3 release

2026-10-10、main merge commit `139ffef8`のCI greenを確認し、annotated tag `0.5.3`を同commitへ作成・pushして
remote到達を確認した。release後の記録用branchとして、同tagから`develop/misc/55`を作成した。

### Array系benchmark、OptionalElementBuffer opt-in、および名称移行

BareArrayとOptionalArrayの多次元access workloadをBenchmarkへ追加し、実装を先にmergeした後、通常CI libraryへの
登録だけを独立PRで合流した。PR #190でperformance jobのgreenを確認した。PR #191のjob全体はPermutationの
borrowed版からruntime-check版への方式切替を回帰として検出したため、同PRのmerge commitを方式切替後のbaselineとし、
PR #193で方式差を通常回帰から分離した比較契約のall greenを確認した。

PR #194ではOptionalElementBufferの`mutating`追従によるLinux性能回帰を三境界比較で特定し、一般提供のまま
回帰を受け入れず、`ENABLE_OPTIONAL_ELEMENT_BUFFER` traitによるopt-in提供へ限定して更新APIを`nonmutating`へ
戻した。続くPR #195・#196でElementBuffer系target・module名を移行し、旧facadeを削除した。DocC landing page、
利用者向けdraft、trait説明、Maintenance管理folder・監査文書名・全管理pathを現行module名へ統一し、独立検査を
受け入れた。Swift 6.4以降の一般提供方式と外部性能assessmentは後続とする。

## Task Registryから移した行

| ID | 状態 | 担当 | 項目 | 完了・除外結果 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `ARRAY-015` | `DONE` | Codex | [DISCOVERY] ElementBuffer系target・module名移行境界 | 新module名、旧名互換facade、移行対象を確定 | `ARRAY_MODULE_TARGET_MIGRATION.md` / `PERFORMANCE_CI_CHANGE_GUIDE.md` / `Package.swift` |
| `ARRAY-016` | `DONE` | Codex | [EXECUTION] ElementBuffer系target・module名移行 | 新moduleへ実装・testを移し、中間互換facade、再公開、benchmark import、DocC CIを検証 | `ARRAY_MODULE_TARGET_MIGRATION_EXECUTION.md` / `Package.swift` |
| `ARRAY-017` | `EXCLUDED` | Codex | [EXECUTION] benchmark task名rename互換の終了 | 互換処理はbaselineでno-opとなり将来renameにも利用できるため削除を不採用 | `PERFORMANCE_CI_CHANGE_GUIDE.md` / `.github/workflows/ci.yml` |
| `ARRAY-018` | `DONE` | Codex | [EXECUTION] 旧ElementBuffer系互換targetの削除 | 旧facadeを削除し、DocC・draft・trait説明・Maintenance管理pathを補修して独立検査を受入 | `ARRAY_MODULE_COMPATIBILITY_TARGET_RETIREMENT.md` / `Package.swift` / `.github/workflows/ci.yml` |
| `OPT-053` | `EXCLUDED` | User | [DECISION] OptionalArrayがC++番兵手法に匹敵すると判定する性能比の上限 | opt-in実験提供へ限定したため、1.0適合用固定閾値の現在決定を不要とした | `OptionalElementBufferModule/CurrentQualityAssessment.md` / `Sources/OptionalElementBufferModule/Documentation/Quality-Profile.md` |
| `OPT-054` | `EXCLUDED` | Codex | [EXECUTION] OptionalArray外部性能アセスメントの実測・判定 | 前提判断を除外し、既存暫定測定とCI workloadだけを性能証拠として保持 | `OptionalElementBufferModule/CurrentQualityAssessment.md` / `Sources/OptionalElementBufferModule/Documentation/Quality-Profile.md` |
| `OPT-070` | `DONE` | Codex / Claude | [DISCOVERY] OptionalArray mutating追従後のperformance CI回帰調査 | 三境界比較で`mutating`化を回帰境界、escaping capture除去を部分回復と確認 | `OptionalElementBufferModule/CurrentQualityAssessment.md` / `Benchmarks/_Artifacts/PerformanceCI/` |
| `OPT-071` | `DONE` | Codex | [EXECUTION] OptionalElementBufferのopt-in化とnonmutating復帰 | trait opt-in化、nonmutating復帰、test・benchmark build・短縮実測を受入 | `Package.swift` / `Sources/OptionalElementBufferModule/OptionalElementBuffer.swift` / `OptionalElementBufferModule/CurrentQualityAssessment.md` |
| `BARE-007` | `EXCLUDED` | Codex | [EXECUTION] BareArray外部性能アセスメントの実測・判定 | 1.0提供対象外の保守moduleへ1.0適合判定を課さず、既存benchmarkを保持 | `ElementBufferModule/CurrentQualityAssessment.md` / `Sources/ElementBufferModule/Documentation/Quality-Profile.md` |
| `BARE-032` | `EXCLUDED` | User | [DECISION] BareArrayがC++ nested vectorに匹敵すると判定する性能比の上限 | 1.0提供対象外としたため固定閾値の現在決定を不要とした | `ElementBufferModule/CurrentQualityAssessment.md` / `Sources/ElementBufferModule/Documentation/Quality-Profile.md` |

## 充足済みprecedence

| 後続task | 前提task | Flow | 制約 |
| --- | --- | --- | --- |
| `ARRAY-016` | `ARRAY-015` | `SEQUENCE` | 調査で確定した名称、互換facade、変更境界に従って移行を実行した |
| `ARRAY-017` | `ARRAY-016` | `SEQUENCE` | 中間状態をmainへ固定後に検討し、互換削除を除外した |
| `ARRAY-018` | `ARRAY-016` | `SEQUENCE` | 中間状態をmainへ固定後、旧名2 targetを削除した |
| `DOC-026` | `ARRAY-016` | `SEQUENCE` | SPI登録前に新moduleへの移行と検証を完了した |
