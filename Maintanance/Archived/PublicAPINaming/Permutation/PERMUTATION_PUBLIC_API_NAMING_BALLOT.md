# PermutationModule公開API名称 ballot案

## 状態

三者の候補を出典つきで集計したRound 1固定ballot。2026-10-15のユーザー指示により、三者分の
シンボル名つき採点表を作成して固定した。採点結果による採用、rename、公開契約変更はまだ行わない。

## 採点前に固定する条件

- 列挙範囲は、入力の現在の並びを初回に含め、その辞書順後続だけとする。
- 通常版は一つのbufferを所有し、一時viewの失効をruntimeで検査する。
- borrowed版は一つのbufferを所有し、compilerが寿命を検査する`Span`を貸す。
- 両ownerは非コピー型で、`Sequence`には適合しない。
- module、入口、owner、一時view、borrowed入口、borrowed ownerを別の判断単位とする。
- familyとして提出された組合せは「提出されたfamily対応」で保存するが、組合せ自体を一票にしない。

## A. Module名

| ID | 候補 | 出典 | 意図・利点 | 主な懸念 | 互換コスト |
| --- | --- | --- | --- | --- | --- |
| `MN-01` | `PermutationModule` | 姫 `A-1`、V3 `V3-A1`、現行 | 短く、Permutation API全般を収容でき、他moduleの`〜Module`形式とそろう | 現行機能が辞書順の現在位置以降だけであることは伝えない | なし |
| `MN-02` | `LexicographicPermutationModule` | 姫 `A-2`、V3 `V3-A2` | 辞書順という現行アルゴリズムの条件を明示する | 長く、全辞書順列挙と誤読しうる。将来scopeを狭める | target、import、依存、DocC URL等のrename |
| `MN-03` | `NextPermutationModule` | ユーザー `U-A1`、V3 `V3-A3` | C++の`next_permutation`との対応を推測・検索しやすい | singularの「次の一件」と複数結果の関係を説明する必要がある。ユーザー記載の「順列全列挙」が現行の列挙範囲と同じ意味か要確認 | target、import、依存、DocC URL等のrename |

## B. 通常版入口

| ID | 候補 | 出典 | 意図・利点 | 主な懸念 | 互換コスト |
| --- | --- | --- | --- | --- | --- |
| `NE-01` | `nextPermutations()` | ユーザー `U-B1`、姫 `B-1`〜`B-4`、V3 `V3-B1`、現行 | C++系の語彙を短いcall siteで使う | 初回に現在の並びを返すこと、非`Sequence`であることは出ない。互換modeで異なるAPIを指す | なし |
| `NE-02` | `lexicographicPermutationSuffix()` | V3 `V3-B2` | 辞書順と現在位置以降を明示する | `suffix`が要素列の部分列や`Collection`に見える。長い | 全通常版call site等のrename |
| `NE-03` | `remainingPermutations()` | V3 `V3-B3` | 現在を基準にした残りを日常語で示す | 現在の並びを含むか、辞書順かが不明 | 全通常版call site等のrename |
| `NE-04` | `lexicographicPermutationCursor()` | V3 `V3-B4` | 手動前進するcursorを生成すると示す | Swiftで`Cursor`の意味が統一されず、長い | 全通常版call site等のrename |
| `NE-05` | `checkedNextPermutations()` | V3 `V3-B5` | runtime失効検査版であることを入口に出す | 順列・bounds等も広く検査する名前に見え、borrowed版がuncheckedとも読める | 全通常版call site等のrename |
| `NE-06` | `permutationsFromCurrentOrder()` | 姫 `C-1` | 初回に現在の並びを含むことを明示し、互換modeの同名APIと分ける | 長く、辞書順は出ない。borrowed版との対応名が未提出 | 全通常版call site等のrename |

## C. 通常版owner

| ID | 候補 | 出典 | 意図・利点 | 主な懸念 | 互換コスト |
| --- | --- | --- | --- | --- | --- |
| `NO-01` | `NextPermutations` | ユーザー `U-B1`、姫 `B-1`〜`B-3`、V3 `V3-B1`、現行 | 入口と同じ短い語幹を使う | 複数形が値の集まりや`Sequence`に見える | なし |
| `NO-02` | `LexicographicPermutationSuffix` | V3 `V3-B2` | 辞書順の現在位置以降を表す | `suffix`が要素列の部分列に見え、長い | owner型、明示型参照、DocC等のrename |
| `NO-03` | `RemainingPermutations` | V3 `V3-B3` | 残りの順列を保持する反復状態と示す | `Sequence`や保存済み結果の集合に見える | 同上 |
| `NO-04` | `LexicographicPermutationCursor` | V3 `V3-B4` | 一つの位置を手動で進める非`Sequence`性を示す | `Cursor`が非標準語で長い | 同上 |
| `NO-05` | `CheckedNextPermutations` | V3 `V3-B5` | runtime検査版であることを示す | 検査範囲を広く約束するように見える | 同上 |
| `NO-06` | `NextPermutationCursor` | 姫 `B-4` | 現行入口を保ちながら反復状態をcursorと示す | 入口`nextPermutations()`と語幹がずれる | 同上 |

## D. 通常版一時viewのleaf名

選んだownerのnested typeとして比較する。たとえば`NV-02`は`SelectedOwner.View`となる。

| ID | 候補 | 出典 | 意図・利点 | 主な懸念 | 互換コスト |
| --- | --- | --- | --- | --- | --- |
| `NV-01` | `Permutation` | ユーザー `U-B1`、姫 `B-1`・`B-3`、V3 `V3-B1`、現行 | 順列という値の役割を短く示す | 独立所有値に見え、一時性を伝えない | なし |
| `NV-02` | `View` | 姫 `B-2`・`B-4` | owner storageへの窓であることをpackage内語彙で示す | 何のviewかはowner文脈に依存し、失効条件までは出ない | nested型、明示型参照、DocC等のrename |
| `NV-03` | `CurrentPermutation` | 姫 `C-2`、V3 `V3-B2` | ownerの現在状態であることと順列であることを残す | 長く、`Current`だけでは失効条件を特定できない | 同上 |
| `NV-04` | `CurrentPermutationView` | V3 `V3-B3`〜`V3-B5`・`V3-C1` | 現在状態へのviewであることを最も明示する | 長く、それでも次のmutating `next()`で失効することは文書が要る | 同上 |
| `NV-05` | `EphemeralPermutation` | V3 `V3-C2` | 保存不能な短命性を強調する | Swift APIで一般的な語ではなく、具体的な失効条件は出ない | 同上 |

## E. Borrowed版入口

| ID | 候補 | 出典 | 意図・利点 | 主な懸念 | 互換コスト |
| --- | --- | --- | --- | --- | --- |
| `BE-01` | `borrowedNextPermutations()` | ユーザー `U-B1`、姫 `B-1`・`B-2`・`B-4`、V3 `V3-B1`・`V3-B5`、現行 | 通常版と同じ語幹にownership上の差をprefixで加える | ownerはsourceを借りず、自分のbufferから結果を貸すため、`borrowed`の係り先が曖昧 | なし |
| `BE-02` | `borrowedLexicographicPermutationSuffix()` | V3 `V3-B2` | `NE-02`と機械的に対応する | 非常に長く、`suffix`の誤読を共有する | borrowed call site等のrename |
| `BE-03` | `borrowedRemainingPermutations()` | V3 `V3-B3` | `NE-03`と機械的に対応する | 辞書順と現在を含むかが出ない | 同上 |
| `BE-04` | `borrowedLexicographicPermutationCursor()` | V3 `V3-B4` | `NE-04`と機械的に対応する | 非常に長く、`Cursor`の意味が非標準 | 同上 |
| `BE-05` | `nextPermutationSpans()` | 姫 `B-3` | 貸す結果が`Span`であることを明示する | compiler寿命検査という選択理由が消え、Spanの集合を所有するようにも見える | 同上 |
| `BE-06` | `lendingNextPermutations()` | V3 `V3-C3` | ownerが結果を貸す構造を動詞で表す | Swift ownership語彙の`borrowing`から離れる。対応owner名が未提出 | 同上 |

## F. Borrowed版owner

| ID | 候補 | 出典 | 意図・利点 | 主な懸念 | 互換コスト |
| --- | --- | --- | --- | --- | --- |
| `BO-01` | `BorrowedNextPermutations` | ユーザー `U-B1`、姫 `B-1`・`B-2`、V3 `V3-B1`・`V3-B5`、現行 | 現行入口と同じ語幹でownership差を示す | owner自体が何かを借りる型に見える | なし |
| `BO-02` | `BorrowedLexicographicPermutationSuffix` | V3 `V3-B2` | `NO-02`と機械的に対応する | 非常に長く、`suffix`の誤読を共有する | owner型、明示型参照、DocC等のrename |
| `BO-03` | `BorrowedRemainingPermutations` | V3 `V3-B3` | `NO-03`と機械的に対応する | 結果集合を所有する`Sequence`に見える | 同上 |
| `BO-04` | `BorrowedLexicographicPermutationCursor` | V3 `V3-B4` | `NO-04`と機械的に対応する | 非常に長く、`Cursor`の意味が非標準 | 同上 |
| `BO-05` | `NextPermutationSpans` | 姫 `B-3` | 結果型`Span`を名前に出す | Spanの集合を所有するように見える | 同上 |
| `BO-06` | `BorrowedNextPermutationCursor` | 姫 `B-4` | ownerの手動反復性とborrowed経路を示す | 長く、入口との語幹が完全には一致しない | 同上 |

`BE-06`に対応するborrowed owner名は提出されていないため、familyとしては未完成である。

## G. 提出されたfamily対応

この表は候補の由来と組合せを保存する。採点時にfamily全体へ一票を与える表ではない。

| Family | 出典 | 通常入口 | 通常owner | view | borrowed入口 | borrowed owner |
| --- | --- | --- | --- | --- | --- | --- |
| `PF-01` | ユーザー `U-B1`、姫 `B-1`、V3 `V3-B1` | `NE-01` | `NO-01` | `NV-01` | `BE-01` | `BO-01` |
| `PF-02` | 姫 `B-2` | `NE-01` | `NO-01` | `NV-02` | `BE-01` | `BO-01` |
| `PF-03` | 姫 `B-3` | `NE-01` | `NO-01` | `NV-01` | `BE-05` | `BO-05` |
| `PF-04` | 姫 `B-4` | `NE-01` | `NO-06` | `NV-02` | `BE-01` | `BO-06` |
| `PF-05` | V3 `V3-B2` | `NE-02` | `NO-02` | `NV-03` | `BE-02` | `BO-02` |
| `PF-06` | V3 `V3-B3` | `NE-03` | `NO-03` | `NV-04` | `BE-03` | `BO-03` |
| `PF-07` | V3 `V3-B4` | `NE-04` | `NO-04` | `NV-04` | `BE-04` | `BO-04` |
| `PF-08` | V3 `V3-B5` | `NE-05` | `NO-05` | `NV-04` | `BE-01` | `BO-01` |

## H. 補助的な宣言名

現行6 surfaceの選択とは独立して扱う。

| ID | 対象 | 候補 | 出典 | 利点 | 懸念 |
| --- | --- | --- | --- | --- | --- |
| `GP-01` | 通常版ownerのgeneric parameter | `Value`（現行維持） | 現行 | nested `Permutation.Element = Value`と衝突しない | borrowed版の`Element`と揃わない |
| `GP-02` | 通常版ownerのgeneric parameter | `Element` | 姫 `C-3` | 両ownerのDocC・診断で対応が分かる | nested Collectionの`Element`との衝突回避を実装で確認する必要がある |

## I. 採点対象から分離する論点

| 論点 | 分離理由 | 扱い |
| --- | --- | --- |
| AtCoder 2025互換modeで同じ`nextPermutations()`が別の`Sequence` APIを指す | build設定による公開契約の切替であり、名前の好みだけでは解けない | 名称決定時の互換影響として残し、互換mode変更は別判断 |
| 初回に現在の並びを含む契約を変える | 列挙範囲の変更 | 今回は固定し、名前と文書の伝達力だけを評価する |
| borrowed版をprefixなしの既定経路にする | toolchain提供方針とsource互換性を変える | 今回は通常版を現行どおり既定と仮定する。変更するなら別のユーザー判断 |
| owner型を非公開にする | 公開surface削除 | 今回のballot外 |
| `Sequence`へ適合する | 寿命・所有契約の変更であり、凍結task `PERM-060`の範囲 | 凍結を解除しない。名称結果を自動的に同taskへ反映しない |
| borrowed版のSwift 6.4以上という提供範囲 | toolchain境界 | 名前で解消せず文書・提供方針の論点として残す |

## J. 採点方法案

固定後は三者がこの同じ候補集合を別々の採点票へ転記し、他者の初回採点を読む前に採点する。
採点票にはIDだけでなく、対象surfaceと候補シンボルを各行へ事前展開する。採点者にIDと候補表の
往復を要求しない。

- `1`〜`9`の総合点を付ける。点は順位ではなく、その候補を公開名としてどの程度支持できるかを表す。
- 意味の正確さ、call siteの読みやすさ、familyの予測可能性、誤読耐性、互換コストを理由に含める。
- 互換コストだけで機械的に減点せず、名前の品質とのtrade-offを文章で残す。
- 合計・平均・多数一致を採用判断にしない。
- 再評価する場合は初回点を上書きせず、roundを分けて理由を残す。

採点票の一行は次の形式とする。

| 対象surface | 候補シンボル | Candidate ID | Score（1〜9） | 支持理由 | 反証・懸念 | 他candidateとの関係 |
| --- | --- | --- | --- | --- | --- | --- |
| Module名 | `PermutationModule` | `MN-01` |  |  |  |  |

## K. Round 1固定時の扱い

- `MN`、`NE`、`NO`、`NV`、`BE`、`BO`を別々に採点し、`PF`は組合せ資料に留める。
- `MN-03`も現行の列挙契約を固定して採点する。「全順列へ契約変更する案」とは扱わない。
- 対応owner名が未提出の`BE-06`は、borrowed版入口単独の候補として採点する。
- generic parameter名`GP-01`・`GP-02`も補助宣言名としてRound 1に含める。
- 三者の採点表には対象surface、候補シンボル、Candidate IDを全行へ事前展開する。

## L. Round 1採点表

- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_SCORE_USER_ROUND1.md`
- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_SCORE_HIME_ROUND1.md`
- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_SCORE_V3_ROUND1.md`
