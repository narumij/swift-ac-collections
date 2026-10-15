# PermutationModule公開API名称採点 — V3 Round 1

## 状態

Round 1初回採点用。採点者: V3（Codex）。候補集合と意味・懸念は
`PERMUTATION_PUBLIC_API_NAMING_BALLOT.md`を正本とする。

他者のRound 1採点を読む前に記入する。各判断群の候補を同じ尺度で比較し、全行へ`1`〜`9`の
総合点と短い理由を記録する。点数は採用判断ではなく、合計・平均・多数一致で自動決定しない。
再評価はこの表を上書きせず、次roundへ分ける。

## Round 1採点表

| 対象surface | 候補シンボル | Candidate ID | Score（1〜9） | 支持理由 | 反証・懸念 | 他candidateとの関係 |
| --- | --- | --- | --- | --- | --- | --- |
| Module名 | `PermutationModule` | `MN-01` | 7 | 短く既存module体系と整合する | 辞書順後続という限定は名前に出ない | 互換性重視なら有力 |
| Module名 | `LexicographicPermutationModule` | `MN-02` | 5 | 辞書順条件を明示する | 長く将来scopeを狭める | 精度は高いがmodule名として過剰 |
| Module名 | `NextPermutationModule` | `MN-03` | 8 | C++由来で探索しやすい | 単数名と複数結果の関係は説明が要る | NE-01との語幹整合が強い |
| 通常版入口 | `nextPermutations()` | `NE-01` | 8 | 短く既知の語彙で現行互換 | 初回が現在値で非Sequenceとは出ない | MN-03とNO-01に自然 |
| 通常版入口 | `lexicographicPermutationSuffix()` | `NE-02` | 5 | 辞書順と現在以降を明示する | suffixが要素部分列に見えて長い | NE-01より正確だが重い |
| 通常版入口 | `remainingPermutations()` | `NE-03` | 4 | 残りという日常語は分かりやすい | 現在包含と辞書順が不明 | NE-02より短いが情報不足 |
| 通常版入口 | `lexicographicPermutationCursor()` | `NE-04` | 5 | 手動前進するcursorを示す | factory名として長くCursorが非標準 | owner名にはより適する |
| 通常版入口 | `checkedNextPermutations()` | `NE-05` | 4 | runtime検査版を区別する | checkedの範囲を過大に読ませる | borrowed版がuncheckedにも見える |
| 通常版入口 | `permutationsFromCurrentOrder()` | `NE-06` | 6 | 現在の並びを含むことを明示する | 長く辞書順とborrowed対応がない | 互換modeとの区別には強い |
| 通常版owner | `NextPermutations` | `NO-01` | 6 | 入口と同語幹で短い | 複数形がSequenceに見える | NE-01との整合は最良 |
| 通常版owner | `LexicographicPermutationSuffix` | `NO-02` | 4 | 辞書順の残区間を表す | 長くsuffixがCollectionに見える | NE-02採用時に限り整う |
| 通常版owner | `RemainingPermutations` | `NO-03` | 4 | 残りの反復状態と読める | 結果集合やSequenceに見える | NE-03依存 |
| 通常版owner | `LexicographicPermutationCursor` | `NO-04` | 7 | 非Sequence ownerを正確に表す | 非常に長くCursorが非標準 | NO-06より説明的 |
| 通常版owner | `CheckedNextPermutations` | `NO-05` | 4 | runtime検査経路を識別できる | 検査範囲を過大に約束する | NE-05と同じ弱点 |
| 通常版owner | `NextPermutationCursor` | `NO-06` | 8 | 手動nextする状態機械を簡潔に表す | 入口との語幹が少しずれる | NV-02と好相性 |
| 通常版一時view | `Permutation` | `NV-01` | 5 | 順列という役割を短く示す | 独立所有値に見えて一時性を隠す | 互換維持以外はNV-03に劣る |
| 通常版一時view | `View` | `NV-02` | 7 | storageへの窓を簡潔に示す | owner文脈なしでは対象不明 | NO-06配下なら明瞭 |
| 通常版一時view | `CurrentPermutation` | `NV-03` | 8 | 現在状態かつ順列と示す | 失効条件は文書依存 | 意味と長さの均衡が良い |
| 通常版一時view | `CurrentPermutationView` | `NV-04` | 7 | 現在状態へのviewを明示する | 長くても失効境界は示せない | NV-03より説明的 |
| 通常版一時view | `EphemeralPermutation` | `NV-05` | 5 | 短命性を強く警告する | Ephemeralが一般的でない | 警告力は高いが語彙が不自然 |
| borrowed版入口 | `borrowedNextPermutations()` | `BE-01` | 8 | 通常版と同語幹で短い | borrowedの係り先が曖昧 | BO-01との予測性が高い |
| borrowed版入口 | `borrowedLexicographicPermutationSuffix()` | `BE-02` | 4 | NE-02と機械的に対応する | 極端に長くsuffix誤読もある | NE-02依存 |
| borrowed版入口 | `borrowedRemainingPermutations()` | `BE-03` | 4 | NE-03と機械的に対応する | 辞書順と現在包含が不明 | NE-03依存 |
| borrowed版入口 | `borrowedLexicographicPermutationCursor()` | `BE-04` | 4 | cursor familyを対称化する | call siteが長すぎる | ownerでcursorを示す方が良い |
| borrowed版入口 | `nextPermutationSpans()` | `BE-05` | 6 | 結果がSpanだと分かる | Span集合の所有に見える | BO-05とは整合する |
| borrowed版入口 | `lendingNextPermutations()` | `BE-06` | 5 | 結果を貸す側だと明確 | Swift ownership語彙として馴染みが薄い | 対応ownerがなくfamily未完成 |
| borrowed版owner | `BorrowedNextPermutations` | `BO-01` | 7 | 通常版との対応が明瞭 | 型自身が借用するように見える | BE-01と組めば理解可能 |
| borrowed版owner | `BorrowedLexicographicPermutationSuffix` | `BO-02` | 4 | NO-02と対称になる | 非常に長くsuffix誤読も残る | NO-02とBE-02依存 |
| borrowed版owner | `BorrowedRemainingPermutations` | `BO-03` | 4 | NO-03と対称になる | 結果集合やSequenceに見える | NO-03とBE-03依存 |
| borrowed版owner | `BorrowedLexicographicPermutationCursor` | `BO-04` | 5 | borrowedとcursorを両方示す | 長すぎる | NO-04との対称性は高い |
| borrowed版owner | `NextPermutationSpans` | `BO-05` | 5 | Spanを返す状態と示す | 複数Spanの所有集合に見える | BE-05とは整合する |
| borrowed版owner | `BorrowedNextPermutationCursor` | `BO-06` | 7 | borrowed経路とcursorを示す | まだ長く入口と語幹がずれる | NO-06との対称性が高い |
| 補助宣言名 | `Value` | `GP-01` | 4 | nested Elementとの衝突を避ける | borrowed版と語彙が揃わない | 実装都合を優先 |
| 補助宣言名 | `Element` | `GP-02` | 8 | 両ownerの要素型語彙を統一する | nested typealiasとの衝突回避が必要 | 実装可能なら一貫性が高い |

## 採点完了確認

- [x] 全候補を同じ`1`〜`9`尺度で採点した。
- [x] シンボル名だけでなく、ballotの意図、誤読、互換コストを確認した。
- [x] familyの整合に影響する場合は「他candidateとの関係」へ記録した。
- [x] 他者のRound 1採点を読む前に完了した（2026-10-15）。

