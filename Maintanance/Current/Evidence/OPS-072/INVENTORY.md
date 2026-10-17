# OPS-072 棚卸し記録（限定試行・3文書）

2026-10-17 / 姫（Opus 5.5）。入力版 `fec74691`。ユーザーが対象3文書と着手を指定（「おすすめ3本でいいかな」「あってるなら着手で」）。

この記録は正本ではない。対象文書は書き換えず、修正・失効は「案」として返す（対象文書の占有は姫にない）。状態の正本はTask Registry。

## 欄の意味

- **種別**：仮判断／本判断／仮契約／本契約（判断＝見立て・決定、契約＝委任・待ち条件）
- **スコープ**：その記述が及ぶ範囲
- **占有**：その記述を今変えてよい者。持ち主は常にユーザー
- **確認済みの範囲**：見たもの。不在は証明しない
- **結果**：有効／修正案／失効案／未決
- **寿命と見直しのきっかけ**
- **先へ進むのに要るもの**（COMMONS「探索の打ち切り」の言い方）

---

## A. `ASAN_DEATH_TEST_INVESTIGATION.md`（RBT-033、Astra、2026-10-16）

### A-1 「現在のASan CIはLinuxでENABLE_DEATH_TESTSを指定していないため、CI成功だけではmacOSの併用成功を証明しない」

- 種別：本判断（事実の記述＋そこからの推論）／スコープ：CIの証拠能力
- 占有：Astra（文書）／確認済み：`.github/workflows/ci.yml`のASan jobは`--traits`なし（2026-10-17時点で事実のまま）。`candidate.yml`には2026-10-17に`address-sanitizer-death-tests`（Linux、`--traits ENABLE_DEATH_TESTS`）が追加済み（`8631a031`）
- 結果：**修正案**。前半の事実は「常時CI（ci.yml）」に限れば有効、候補CI（candidate.yml）では変わった。後半の推論「Linuxの成功はmacOSの成功を証明しない」は有効
- 寿命：事実部分はCI定義が変わるたび。推論部分は長命
- 先へ進むのに要るもの：なし（修正文の採否だけ）

### A-2 「Linux、別Swift版では未検証」（提案と境界）／「Linux CIでの有効性は未確認」（追加受入）

- 種別：本判断（未検証の宣言）／スコープ：ASan＋death testの成立範囲
- 占有：Astra
- 確認済み：CP-20261017-006にユーザー報告「とおりました」（候補CIでLinux ASan＋death testが成功）。姫はCIログを直接見ていない
- 結果：**修正案**。「Linuxは候補CIで成功（ユーザー報告、run未記録）」へ。「Linux CIでのstrip_envの有効性」という問い自体は、strip_envがmacOSのDYLDの話でLinuxでは不要だったため**失効案**（問いが成立しない）
- 寿命：CIの実行1回ごと。別Swift版は未検証のまま
- 先へ進むのに要るもの：run URLか対象commit（証拠として固めるなら）

### A-3 「候補は、子プロセス生成前にruntimeのパスを保持・復元する試験側の準備」

- 種別：仮判断（解決策の候補）／スコープ：macOSでのASan＋death testの成立手段
- 占有：Astra（文書）、採否はユーザー
- 確認済み：同文書の追加受入とRBT-049（DONE）で、`ASAN_OPTIONS=strip_env=0`だけで成立することが固定版で確認済み
- 結果：**失効案**（より単純な手段が確認され、候補としての役目を終えた）。ただし「setenvで復元すると成功する」という観察は事実として残す（捨てるのは候補という判断だけ）
- 寿命：短命だった（翌日のstrip_env特定で終了）
- 先へ進むのに要るもの：なし

### A-4 「OptionalElementBuffer/ElementBufferの品質評価にあるASan＋Death Test成功記載との違いは未確定」

- 種別：仮判断（未決の宣言）／スコープ：過去の品質証拠の解釈
- 占有：Astra
- 確認済み：品質評価の原文は読んでいない（打ち切り）
- 結果：**未決**のまま。strip_envの判明で「当時はLinuxだったのか、strip_env相当の条件だったのか」という仮説は立つが、確かめていない
- 寿命：その品質評価を再利用するまで
- 先へ進むのに要るもの：当時の実行環境（OS・ASAN_OPTIONS）の記録。無ければ無理に埋めない

---

## B. `EXTERNAL_TYPE_EXTENSION_AUDIT.md`（Codex、2026-10-07）

### B-1 「`Result: @retroactive Comparable`は削除済み」

- 種別：本判断（完了記録）／スコープ：外部所有型への適合
- 占有：Codex（文書）
- 確認済み：`Sources`全体で`@retroactive Comparable`は0件
- 結果：**有効**
- 寿命：長命（再び足されたら）

### B-2 「`Result._NodePtr`を`@usableFromInline package`へ縮小」

- 種別：本判断（完了記録）
- 確認済み：`unsafe_node+pointer+safe.swift:322-326`が`extension Result { @usableFromInline package typealias _NodePtr }`
- 結果：**有効**

### B-3 「残る`_LazyTieWrap`、`_NodePtrSealing`、`_LazyTie`はDebug限定Comparable」

- 種別：本判断（現状の記述）＋本契約（再開条件「Indexの`Comparable`方針確定後」）
- 確認済み：`_LazyTieWrap: Comparable`は`_LazyTieWrap.swift:51`の`#if DEBUG`内、`_NodePtrSealing: Comparable`は`_NodePtrSealing.swift:156-182`の`#if DEBUG`内。`_LazyTie`という型名は`Sources`で見つからなかった（`_LazyTiedPtr`はある）。それ以上は探していない
- 結果：2件は**有効**。`_LazyTie`は**未決**（改名済みか、別名の指し方か。不在は証明しない）
- 寿命：再開条件（Index Comparable方針）が動くまで
- 先へ進むのに要るもの：`_LazyTie`が何を指していたか（履歴版`../Archived/EXTERNAL_TYPE_EXTENSION_AUDIT_HISTORY_2026-10-07.md`に答えがある可能性。未読）

### B-4 Main sources「`Sources/PermutationModule/NextPermutations.swift`」

- 種別：事実の記述（参照）
- 確認済み：そのパスは無い。`Sources/NextPermutationModule/NextPermutations.swift`がある（0.5.4の主モジュール変更、CHANGELOG記載）。他の4つのパスは存在
- 結果：**修正案**（パスを`Sources/NextPermutationModule/NextPermutations.swift`へ）
- 寿命：モジュール配置が変わるまで

### B-5 「SignedDistance：access-only縮小は言語制約上成立しないことを実験済み」

- 種別：本判断（実験に基づく）
- 確認済み：再実験していない（打ち切り。価値に対して重い）
- 結果：**未決**（今回は確かめない）。Swift版が上がると言語制約が変わる可能性があり、寿命はtoolchain更新まで
- 先へ進むのに要るもの：再開指示が来たときに、その時点のtoolchainで再実験

---

## C. `PERMUTATION_SEQUENCE_INVALID_VIEW_ISSUE.md`（PERM-060、Astra、2026-10-16）

### C-1 「現行の通常公開型と借用公開型はSequence非準拠と明記されている」

- 種別：本判断（現状の記述）
- 占有：Astra（文書）／PERM-060の調査はCodex（Registry上の担当）
- 確認済み：`NextPermutations.swift:57`「intentionally does not conform to `Sequence`」、`BorrowedNextPermutations.swift:48`同旨
- 結果：**有効**

### C-2 参照先（実験記録・テスト・公開型・凍結時原文）

- 確認済み：5つのパスすべて存在。テスト内に`RuntimeCheckedPermutationSequence: Sequence`がある
- 結果：**有効**（0.5.4のモジュール改名後のパスで書かれている）

### C-3 「`Array(sequence)`へ渡すと失効し、要素を読めなくなる」

- 種別：仮判断（過去の実験に基づく。文書自身が「今回の再実行結果にはしない」と明記）
- 占有：PERM-060の調査担当（Codex）
- 確認済み：再現は行っていない。再現はPERM-060そのものの作業で、姫の占有の外
- 結果：**未決**（占有の外なので触らない）
- 寿命：PERM-060の再現まで
- 先へ進むのに要るもの：PERM-060の担当による現行toolchainでの再現

---

## 集計

| 文書 | 有効 | 修正案 | 失効案 | 未決 |
| --- | --- | --- | --- | --- |
| A ASan | 0 | 2 | 1（＋A-2内の問い1つ） | 1 |
| B 外部型Extension | 3（B-3の2件を含む） | 1 | 0 | 2 |
| C PERM-060 | 2 | 0 | 0 | 1 |

所要：ツール呼び出し約15回。読んだのは3文書と、その中で名前の出たソース・yml・Registry行だけ。
