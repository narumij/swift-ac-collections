# ASan＋Death Test実行経路の調査

作成者: Astra。2026-10-16、ユーザーの調査依頼。Task: RBT-033。

## 範囲

macOSの成功記録と失敗記録を比較し、隔離再現で成立する起動経路を探索する。製品・既存試験・CIは変更しない。旧証拠は[0.6.0評価の証拠](../Quality/0.6.0-1/RedBlackTreeModule/Evidence/RBT-032-2026-10-15/README.md)に保存済み。

## 調査中

Swift 6.4 (swiftlang-6.4.0.34.1)、arm64。現在のASan CIはLinuxでENABLE_DEATH_TESTSを指定していないため、CI成功だけではmacOSの併用成功を証明しない。

## 結果

製品コードを含まないSwift Testing最小packageで再現した。

| 条件 | 結果 |
| --- | --- |
| native build、ASan、環境復元なし | 正常exit(0)とfatalErrorの両子プロセスがSIGABRT。2件失敗 |
| シェルからDYLD_INSERT_LIBRARIESを指定 | 同じ2件失敗 |
| swiftpm-testing-helperを直接起動しruntimeを注入 | 同じ2件失敗 |
| suite初期化でDYLD_INSERT_LIBRARIESを復元 | 正常exit(0)とSIGTRAPの2件成功 |
| 復元後、heap領域外の直接storeも加える | 3件成功。異常storeはAddressSanitizer: heap-buffer-overflowをstderrに出して失敗終了し、検出器が有効であることを確認 |

シェルから注入した最終試験でも、suite初期化時のgetenvは`<unset>`だった。子プロセス生成より前に値を復元すると成功する。この観測は環境継承の問題を支持するが、変数を消したコードの特定まではしていない。

初期の負例はUnsafeMutablePointer.initialize(to:)による領域外初期化だったが、診断されず正常終了した。直接subscript storeへ変えて検出を確認した。失敗した負例もログを保持し、ASanが全てのunsafe操作を検出するとは主張しない。

## 再現

[証拠フォルダ](ASAN_DEATH_TEST_EVIDENCE_2026-10-16)のPackage.swiftを隔離ディレクトリの根へ、Probe.swiftをTests/ProbeTests/へ配置する。

```sh
CLANG_MODULE_CACHE_PATH=/tmp/astra-asan-module-cache swift test --package-path /tmp/astra-asan-probe --disable-sandbox --sanitize address --build-system native
```

Probe.swiftのsuite初期化は、この環境のASan runtime絶対パスをsetenvする調査用実装である。製品用の共通fixtureとしてそのまま採用しない。失敗の再現はsuiteのinitを除去し、正常終了とtrapの2件のみを実行する。各ログは試験内容の要約と件数を含む。最終3件は終了status 0を確認した。

## 過去記録との関係

- 10月15日のRBT-032は子プロセスruntime遅延ロードの完全ログを保存済み。今回、製品を含まない試験でも同種の失敗を再現した。
- OptionalElementBuffer/ElementBufferの品質評価にはASanとDeath Testの成功記載がある。成功時の完全な起動環境は今回復元できず、今回との違いは未確定。
- 現行Linux ASan CIはENABLE_DEATH_TESTSを指定していない。macOS上の併用確認とは別の証拠である。

## 提案と境界

候補は「ASan構成に限り、子プロセス生成前に実際にロードされたruntimeのパスを保持・復元する試験側の準備」。採用時には既存DYLD設定を上書きしないこと、並列実行中のprocess-global環境変更を避けること、runtimeパスの固定を避けることが必要。

今回の成立証拠は最小packageの3件に限る。4型の全Death Test、姫の追加試験、Linux、別Swift版では未検証。製品コード、既存Tests、Package.swift、CI、CLAUDE_TASKは変更していない。正式適用と全体検証は後続の実装範囲とする。

## 追加調査の受入（2026-10-16 / Astra）

CP-20261016-014を本調査への追加証拠として統合。原報告は[strip_env調査](Evidence/ASAN-strip-env-2026-10-16/ASAN_DEATH_TEST_STRIP_ENV_REPORT.md)。Probeを読み、setenvによる復元なしで、正常終了・trap・ASan領域外検出を確認する構成であること、保存ログの3件成功およびDeathTests 213件成功／既定条件360 issuesを照合した。今回は再実行していない。

受入範囲はmacOSでstrip_env=0により改善した保存実験の証拠。compiler-rt内部の原因確定、版を固定した製品全体の合格、Linux CIでの有効性は未確認。元のRBT-033 DONEは初回調査の完了として維持し、追加の固定版検証はRBT-049へ分離する。製品・Tests・CIへの適用は行わない。


## 根拠と更新条件の追記（2026-10-17 / 姫・Opus 5.5 / OPS-076第4区切り）

入力版`1175e583b1857819e9e0b07b83a1cb5fc8be657a`。本文・原返却は変えていない。確認は`git show <版>:…`等の固定treeの読み取りだけで、実行・再レビューはしていない。

| 主張 | 確認方法と結果（成立範囲） | 更新のきっかけ |
| --- | --- | --- |
| 11行目前半「現在のASan CIはLinuxでENABLE_DEATH_TESTSを指定していない」 | `ci.yml` 384行のASan実行に`--traits`はない（通常CIについては今も成立）。ただし`candidate.yml`の145行目のjob「Run death tests with Address Sanitizer」は、152〜153行で`--sanitize address`と`--traits ENABLE_DEATH_TESTS`を併用している（RBT-049の候補CI）。前半は「通常CIでは」に限れば成立 | `.github/workflows/ci.yml`・`candidate.yml`のASan jobの変更 |
| 11行目後半「CI成功だけではmacOSの併用成功を証明しない」 | 知識（推論）なので固定treeでは確かめられない。候補CIもLinux上のjobで、この推論の前提は変わっていない | CIにmacOSのASan＋death test jobが入ったとき |

GitHub上のCI実走の成否は見ていない（ref・外部結果に依存する）。
