# Permutation module移行計画

作成者：Astra。2026-10-15。基準：`6f101a27`。
入力：[調査受入・統合記録](../Archived/PermutationMigration_2026-10-16/PERMUTATION_MIGRATION_INVESTIGATION_ACCEPTANCE.md)、[名称決定](PUBLIC_API_NAMING_DECISIONS.md)、[性能CI変更手順](PERFORMANCE_CI_CHANGE_GUIDE.md)。
段階：計画。以下のユーザー確認済み方針と、Astraが具体化した工程案を区別する。本書は実装完了やCI成功の記録ではない。

## ユーザー確認済みの方針

2026-10-15、ユーザーが「旧名は互換用」「2はギリギリまで遅らせる」と確認し、計画の継続を指示した。

- 主入口は`NextPermutationModule`。旧`PermutationModule`はmainに互換入口として残す。
- 新名に実装を置き、旧名は同じ実装を再公開する薄い入口とする。実装・型を二重に定義しない。
- benchmark名の整理は後段まで遅らせる。module移行の前提や完了条件にしない。実施日・release期限はまだ定めない。
- 旧入口と既存CI互換を削除しない。名称決定は公開契約やSequence採否を変更しない。

## 具体構成案

`AcCollections` productは維持する。target依存を以下とし、facade sourceは新名を再公開する。

```text
AcCollections target → NextPermutationModule（実装）
                    → PermutationModule（互換）→ NextPermutationModule
```

実装とDocCを`Sources/NextPermutationModule/`へ移し、旧入口は`Sources/_PermutationModule/`の小さいtargetとして明示pathを与える案とする。旧入口のsourceは`@_exported import NextPermutationModule`を基本とする。新名を仮の再公開targetとして先行追加し、後で依存を反転する工程は設けない。

通常版と`COMPATIBLE_ATCODER_2025`の条件付き実装は同じ実装target内に維持する。現在のcompiler条件・settingsを保持する。新旧module名の互換と2025互換modeは別々に検証する。

この構成で外部clientの新旧importと型同一性が成立することは、次工程の実測条件である。未確認のまま成立扱いにしない。

## module移行の工程案

| 工程 | 作業とまとめる範囲 | 次へ進む証拠・停止条件 |
| --- | --- | --- |
| 1. 実装前の対象固定 | 現在のHEAD・差分、名称決定、通常版generic parameterの`Element`、新旧入口の保証範囲を照合する。現行説明の「互換未決」は、存続決定と具体方式の区別へ整える | 調査後の変更があれば影響を再照合する。新しい仕様判断が必要ならその点で止める |
| 2. 一つの整合した変更を作る | manifest、実装配置、旧shim、facade、通常版generic parameter、関連import、test／compiler fixture、DocC catalog・見出し、DocC matrix、現行品質説明を揃える。benchmark sourceのimportも新名へ揃えるが、登録title・library・測定処理は保つ | 実装は一組、target cycle・source重複なし。新旧とfacadeを同時に利用可能にする。途中で壊れた状態をmainへ入れない |
| 3. ローカル受入 | 対象テスト、compiler正常・期待拒否、外部clientの新名・旧名・facade経路、型の受渡し、通常／2025互換mode、benchmark release buildと登録task一覧、DocC生成を確認する | 検査の実行件数・条件・結果を残す。失敗・未実行を成功で代用しない。型の分裂、契約変化、title差分があれば止めて修正 |
| 4. PRで継続経路を確認 | 上記を整合したPR単位として提出する。通常テスト、対象別DocC、旧baselineを使う性能CIの測定・比較完走を確認する | 各jobの実結果を確認する。DocCは`continue-on-error`のため、PR全体のgreenだけでは成功としない。candidate経路はそのworkflowに適した候補refと実行条件で確認し、未実行なら明記する |
| 5. main到達後の確認・引渡し | ユーザーによるmerge後、到達commit、入口、検証証拠、現行文書、残課題を記録する | 新名が主入口、旧名が互換入口として成立し、benchmark名を保った比較が継続すること。旧名削除やbenchmark名整理は要求しない |

工程2は編集順を細分化してよいが、manifestだけを先にmergeするなど、途中で成立しない公開状態には分割しない。コミット・push・mergeの実施はrepositoryの操作権限に従う。今回の計画作成では実行しない。

## 入口ごとの確認

- 外部の小さいclient packageから`AcCollections` productだけに依存し、新名直接import、旧名直接import、facade importをそれぞれ確認する。
- 新旧を同時にimportしたclientで、旧入口経由の値を新入口側の型として受け渡せること、extensionが曖昧にならないことを確認する。
- 通常版のnoncopyable・直接初期化不可・非Sequence契約と一時Viewの失効、borrowed版の寿命制約を既存検査で維持する。2025互換modeへ通常版の証拠を流用しない。
- 新moduleをDocCの主たるAPI説明とし、旧shimには互換入口と新moduleへの案内を置く案とする。新旧両targetをDocC matrixに含め、重複symbol・未解決linkを確認する。旧入口の廃止予定やdeprecated指定は追加しない。
- READMEの通常例`import AcCollections`は維持し、新旧入口の役割を説明する。SPI URLは登録後の実在確認まで作らない。
- 過去のbuild・DocC・性能結果は当時の名称のまま残す。現行説明と将来の実行pathだけ更新する。

## benchmark名整理の後段

当面は着手せず、今回のmodule移行を妨げない。後段で必要になった時点でユーザーと時期・対象を確定する。旧PERM-063・064の凍結は本計画では解除しない。

実施時は、完全titleと同一workloadを照合し、PR用`ci.yml`・release candidate用`candidate.yml`双方へ入力変換と結果正規化を先に入れる。その変更がgreenになってから、source登録名とlibrary指定を同時に変更し、旧baselineとの比較完走を確認する。baselineへcurrent sourceを移植しない。既存のArray系互換は維持する。

## 次に具体化する作業

工程案を実行単位へ落とし、現在状態と採番表を確認したうえで、担当・編集範囲・検証・返却先を用意する。計画の中で列挙した検証項目を、そのまま別々のtaskへ増やさない。実装担当への発注はまだ行っていない。

## 実行への接続（2026-10-15）

ユーザーの「では、すすもう」を受け、工程2・3を一体のローカル実装task `PERM-076`として登録した。[ワーカー依頼書](../Archived/PermutationMigration_2026-10-16/PERMUTATION_MODULE_MIGRATION_IMPLEMENTATION.md)を1体へ渡す。調査用3体は完了済みであり再起動しない。remote CI・main到達は今回のワーカー範囲に含めず、返却の受入後に扱う。

## 工程完了記録（2026-10-15）

工程1〜3はローカル受入、工程4はPR #196の全11 job成功、工程5はmain到達commit `3ef37fc2`の照合をもって完了した。実装は`1f87e37a`、文書・ローカル受入記録は`4cd0ebc2`に保存済み。証拠と確認範囲は[受入記録](../Archived/PermutationMigration_2026-10-16/PERMUTATION_MODULE_MIGRATION_ACCEPTANCE.md#pr-cimain到達確認2026-10-15)に記す。

新名を主入口、旧名を互換入口とする今回のmodule移行は完了。candidate CI経路は未実行であり、その成功を含めない。benchmark名整理は後段に残し、本完了によって着手・凍結解除しない。
