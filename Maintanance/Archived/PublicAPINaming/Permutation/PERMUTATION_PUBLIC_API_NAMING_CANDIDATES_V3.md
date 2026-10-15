# PermutationModule公開API名称候補 — V3

## 提出情報

| 項目 | 記録 |
| --- | --- |
| 提出者 | V3（Codex） |
| 提出日時 | 2026-10-15 |
| 他の二者の候補を読む前か | いいえ。ユーザーと姫の今回提出は未読だが、提出表の設計時にArchivedの過去候補を読んだ |
| 扱い | 独立票ではなく、過去候補を見た後のV3候補。候補の出典境界を保ったまま集計対象にできる |
| 照合範囲 | 現行通常版・borrowed版source、module DocC、利用者向け本文、公開surface・列挙・所有・失効・共存testの検索結果 |

候補は順位順ではない。現行の列挙範囲、所有、寿命、失効検査、`Span`、非`Sequence`という契約を
固定して、名称だけを比較する。過去資料で見た案との一致・派生は独立発見として扱わない。

## A. Module名候補

| 提出者内ラベル | 候補 | 意図する意味 | 利点 | 誤読・懸念 | 互換コスト |
| --- | --- | --- | --- | --- | --- |
| `V3-A1` | `PermutationModule`（現行維持） | 順列生成APIを収めるmodule | 短く、現在のimportと文書名を維持でき、将来のPermutation APIも収容できる | 現在の提供物が辞書順の現在位置以降だけであることは伝えない。`swift-algorithms`の全順列APIとの違いをmodule名だけでは判別できない | なし |
| `V3-A2` | `LexicographicPermutationModule` | 辞書順による順列遷移を提供するmodule | 現行アルゴリズムの順序条件を明示し、一般的な全順列生成との違いを出せる | 長い。将来、辞書順でないPermutation APIを同居させにくい | module・target・import・依存記述・文書のrenameが必要 |
| `V3-A3` | `NextPermutationModule` | C++の`next_permutation`に近い反復機能を中心とするmodule | 既知のアルゴリズムとの対応を検索・推測しやすい | singularの「次の一件」と、複数結果を返す現行APIの関係を説明する必要がある。将来scopeも狭める | module・target・import・依存記述・文書のrenameが必要 |

## B. 公開API family候補

| 提出者内ラベル | 通常版入口 | 通常版owner | 通常版一時view | borrowed版入口 | borrowed版owner | 意図する意味 |
| --- | --- | --- | --- | --- | --- | --- |
| `V3-B1` | `nextPermutations()` | `NextPermutations` | `Permutation` | `borrowedNextPermutations()` | `BorrowedNextPermutations` | 現行維持。C++の`next_permutation`系の語彙を使い、borrowed経路だけprefixで区別する |
| `V3-B2` | `lexicographicPermutationSuffix()` | `LexicographicPermutationSuffix` | `CurrentPermutation` | `borrowedLexicographicPermutationSuffix()` | `BorrowedLexicographicPermutationSuffix` | 入力の現在位置から始まる辞書順列の「残り区間」を明示する |
| `V3-B3` | `remainingPermutations()` | `RemainingPermutations` | `CurrentPermutationView` | `borrowedRemainingPermutations()` | `BorrowedRemainingPermutations` | 全順列ではなく、現在の並びを含む残りだけを反復することを日常語で示す |
| `V3-B4` | `lexicographicPermutationCursor()` | `LexicographicPermutationCursor` | `CurrentPermutationView` | `borrowedLexicographicPermutationCursor()` | `BorrowedLexicographicPermutationCursor` | 非`Sequence`の手動`next()`と、一つの可変位置を進める性質をcursorとして示す |
| `V3-B5` | `checkedNextPermutations()` | `CheckedNextPermutations` | `CurrentPermutationView` | `borrowedNextPermutations()` | `BorrowedNextPermutations` | 通常版はruntime失効検査、borrowed版はcompiler寿命検査という選択軸を両入口へ出す |

## C. Family候補の比較材料

| 提出者内ラベル | 代表call site | familyとしての予測可能性 | 誤読・懸念 | 互換コスト |
| --- | --- | --- | --- | --- |
| `V3-B1` | `var p = values.nextPermutations()` | 入口とowner、borrowed prefixの対応は短く規則的 | `next`が初回に現在の並びも返すこと、返り値が非`Sequence`のownerであること、一時viewであることは名前に出ない | なし |
| `V3-B2` | `var suffix = values.lexicographicPermutationSuffix()` | 列挙順と「現在以降」を一組で表す。通常版とborrowed版も機械的に対応する | `suffix`が要素列の部分列、または返り値が`Collection`だと読まれうる。全名称が非常に長い | 公開5 surfaceと全call siteのrename。型名・symbol link・test・benchmarkへの波及が大きい |
| `V3-B3` | `var remaining = values.remainingPermutations()` | 現在を基準にした有限の残りというmental modelは得やすい | 「remaining」が現在の並びを含むか不明。辞書順条件を名前から失い、どこかですでに消費した状態にも聞こえる | 公開5 surfaceと全call siteのrename。module名との語彙対応も弱くなる |
| `V3-B4` | `var cursor = values.lexicographicPermutationCursor()` | `next()`による手動前進と非`Sequence`性を最も予測しやすい。view名も現在位置との関係を示す | Swiftで`Cursor`の意味が統一されておらず、indexや編集位置と誤読されうる。borrowed owner自身はcursorから`Span`を貸すため、view型対応が左右非対称 | 公開5 surfaceと全call siteのrename。最長のcall siteになる |
| `V3-B5` | `var checked = values.checkedNextPermutations()` | runtime検査版とborrowed版を選ぶ理由が入口に現れる | `checked`が順列の妥当性、bounds、overflowまで検査すると広く読まれうる。通常版だけが安全でborrowed版はuncheckedという誤読も起こる | 通常版入口・owner・viewと関連call siteをrename。borrowed側は維持できる |

## D. Surface単位の補足候補

| 提出者内ラベル | 対象surface | 候補 | 意図する意味 | 利点 | 誤読・懸念 | 互換コスト |
| --- | --- | --- | --- | --- | --- | --- |
| `V3-C1` | 通常版一時view | `CurrentPermutationView` | ownerの現在bufferを参照する一時view | 値として独立したPermutationではなく、現在状態のviewだと伝えやすい | `Current`だけでは次の`next()`で失効する強さまでは表せない。長い | nested public type、明示型参照、DocC link、test名等のrename |
| `V3-C2` | 通常版一時view | `EphemeralPermutation` | 次の前進までしか使えない短命性を強調する | 保存可能な値との取り違えを最も直接避ける | Swift APIで`Ephemeral`は一般的でなく、失効条件を名前だけで特定できない | nested public type、明示型参照、DocC link、test名等のrename |
| `V3-C3` | borrowed版prefix | `lending`（例：`lendingNextPermutations()`） | ownerが`Span`を貸す動作を表す | owner自身がsourceから借りるのではなく、結果を貸す構造に文法上は合う | Swiftのownership用語として`borrowing`との距離が生じ、利用者が機能を検索しにくい | borrowed入口・ownerの語彙体系と全call siteのrename |

## E. 未解決事項・契約変更案

| 提出者内ラベル | 発見・案 | 名称候補と分離する理由 | 必要な確認またはユーザー判断 |
| --- | --- | --- | --- |
| `V3-D1` | moduleを将来のPermutation総合moduleとするか、辞書順後続API専用とするか | module名の広さは将来の製品scopeを約束しうるため、現行実装だけでは決まらない | 将来scopeを名称判断へ含めるかユーザーが決める |
| `V3-D2` | 通常版とborrowed版のどちらをprefixなしの主経路にするか | 既定経路の変更は名前だけでなくtoolchain提供方針とsource互換性を変える | 今回は現行どおり通常版を既定として固定するかユーザーが確認する |
| `V3-D3` | owner型を公開したまま名前で強く説明するか、factory中心にして利用者から目立たなくするか | public surfaceの削減は名称変更ではなくAPI提供範囲の変更になる | 今回のballot外とするかユーザーが確認する |

## F. 出典境界と完了確認

- 今回のユーザー案および姫の返却案は読んでいない。
- 過去のArchived候補で、現行維持、後続を`successor`で表す案、通常viewを`CurrentView`とする案、
  borrowed版を既定にする案を見ている。このため、本書全体を独立提出とは扱わない。
- `V3-B2`〜`V3-B5`と`V3-C1`〜`V3-C3`も、過去案から完全に独立して生じたとは主張しない。
- 六つの現行surfaceは、維持案または変更案のいずれかに含めた。
- 契約変更を伴う論点はEへ分離し、候補の順位付け、採点、採用はしていない。
