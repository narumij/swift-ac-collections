# PermutationModule公開API名称採点 — 姫 Round 1

## 状態

Round 1初回採点用。採点者: 姫（Claude）。候補集合と意味・懸念は
`PERMUTATION_PUBLIC_API_NAMING_BALLOT.md`を正本とする。

他者のRound 1採点を読む前に記入する。各判断群の候補を同じ尺度で比較し、全行へ`1`〜`9`の
総合点と短い理由を記録する。点数は採用判断ではなく、合計・平均・多数一致で自動決定しない。
再評価はこの表を上書きせず、次roundへ分ける。

## Round 1採点表

| 対象surface | 候補シンボル | Candidate ID | Score（1〜9） | 支持理由 | 反証・懸念 | 他candidateとの関係 |
| --- | --- | --- | --- | --- | --- | --- |
| Module名 | `PermutationModule` | `MN-01` | 8 | 短く、他moduleの`〜Module`形式とそろう。利用者は通常`AcCollections`からimportするため、module名に機能の細部を載せる必要は薄い | 現行機能が辞書順の現在位置以降だけであることは伝えない | 入口・owner名がどれでも組み合わせられる |
| Module名 | `LexicographicPermutationModule` | `MN-02` | 3 | 辞書順という条件は正確 | 長い。全辞書順列挙と誤読しうる。将来Permutation APIを足すとscopeが合わなくなる。rename費用に見合う改善が小さい | `NE-02`・`NE-04`系の語彙と揃うが、それらの採否に依存しない |
| Module名 | `NextPermutationModule` | `MN-03` | 4 | 入口`nextPermutations()`・C++の`next_permutation`と対応し、検索しやすい | module名の利用場面が少なく、改善に比べてrename費用が大きい。単数`Next`と複数結果の関係を説明する必要がある | `NE-01`を維持する場合に最も整合する |
| 通常版入口 | `nextPermutations()` | `NE-01` | 7 | 短く、C++の`next_permutation`を知る主な利用者（競技プログラミング）には意味がすぐ通じる。swift-algorithmsの`permutations()`と衝突しないことが共存testで固定されている | 初回に現在の並びを返すことと`next`が食い違って読める。非`Sequence`であることは出ない。互換modeでは同じ綴りが別の`Sequence` APIを指す（ballot I） | `NO-01`・`BE-01`と同じ語幹のfamilyになる |
| 通常版入口 | `lexicographicPermutationSuffix()` | `NE-02` | 3 | 辞書順と現在位置以降を正確に表す | `suffix`がCollectionの`suffix(_:)`（要素の部分列）と衝突して読める。長い | `NO-02`・`BE-02`と機械的に対応するが、三つとも同じ誤読を共有する |
| 通常版入口 | `remainingPermutations()` | `NE-03` | 4 | 日常語で読みやすく、手動で進める残りという感覚は伝わる | 現在の並びを含むか、辞書順かが名前から分からない。swift-algorithmsの`permutations()`と並ぶと、全列挙の別名に見える | `NO-03`・`BE-03`と対応する |
| 通常版入口 | `lexicographicPermutationCursor()` | `NE-04` | 3 | 手動前進の状態を返すことを明示する | メソッド名が名詞`Cursor`で終わり、factoryとして読みにくい。長い。Swiftで`Cursor`の意味が統一されていない | `NO-04`と組む前提の名前 |
| 通常版入口 | `checkedNextPermutations()` | `NE-05` | 3 | runtime検査版であることは正確 | 既定経路の名前に`checked`が付くと、borrowed版が未検査に見える。検査の範囲（失効だけ）を広く約束するように読める | `NO-05`と組む。borrowed側は`BE-01`のままで、checked/borrowedの対比がずれる |
| 通常版入口 | `permutationsFromCurrentOrder()` | `NE-06` | 4 | 初回に現在の並びを含むことが名前から分かり、互換modeの同名APIと綴りが分かれる（姫提出） | 長い。辞書順であることは出ない。swift-algorithmsの`permutations()`と語頭が同じで補完で並び、全列挙と取り違える余地が残る。borrowed版の対応名がない | 対応するowner・borrowed名が未提出で、family全体の予測可能性は低い |
| 通常版owner | `NextPermutations` | `NO-01` | 7 | 入口と同じ語幹で、`var p = xs.nextPermutations()`の型として自然に予測できる。型名を書く場面は少ない | 複数形が値の集まり・`Sequence`に見え、`for-in`や`map`を試させる | `NE-01`と組むとき最も整合する |
| 通常版owner | `LexicographicPermutationSuffix` | `NO-02` | 3 | 辞書順の現在位置以降を表す | `suffix`の誤読と長さは`NE-02`と同じ | `NE-02`とだけ整合する |
| 通常版owner | `RemainingPermutations` | `NO-03` | 3 | 残りを保持する反復状態を示す | 複数形の集合・`Sequence`誤読は`NO-01`と同じで、入口と組まない限り語幹の利点もない | `NE-03`とだけ整合する |
| 通常版owner | `LexicographicPermutationCursor` | `NO-04` | 4 | 一つの位置を手動で進める型で、`Sequence`ではないことが伝わる | 長い。`Cursor`は非標準語で説明が要る | `NE-04`と整合。`NE-01`と組むと語幹がずれる |
| 通常版owner | `CheckedNextPermutations` | `NO-05` | 3 | runtime検査版であることは正確 | `NE-05`と同じく、検査範囲の過大な約束と、borrowed版が未検査に見える問題を持つ | `NE-05`と整合 |
| 通常版owner | `NextPermutationCursor` | `NO-06` | 5 | 入口を維持したまま、ownerが値の集まりではなく手動で進める状態であることを示す。複数形の誤読を避ける（姫提出） | 入口`nextPermutations()`と語幹がずれ、型の予測がしにくくなる。`Cursor`の説明が要る | `NE-01`・`BO-06`と組む提出（`PF-04`）。`NV-02`と組むと`NextPermutationCursor.View`になる |
| 通常版一時view | `Permutation` | `NV-01` | 6 | `while let permutation = p.next()`と自然に読め、順列という役割が短く伝わる。型名を書く場面は少ない | 独立した所有値に見え、次の`next()`で失効する一時性を伝えない | どのownerとも組める |
| 通常版一時view | `View` | `NV-02` | 6 | owner storageへの窓であることを、package内の既存語彙（RedBlackTreeの共有View）で示す。保存できるという誤読を減らす | 単独では順列であることが消え、owner名の文脈に頼る。失効条件までは出ない | ownerが`NO-01`なら`NextPermutations.View`、`NO-06`なら`NextPermutationCursor.View` |
| 通常版一時view | `CurrentPermutation` | `NV-03` | 5 | owner上の「今の」順列で、一時性と順列であることを両方残す | 長め。`Current`だけでは失効条件を特定できない | どのownerとも組めるが、`NO-06`と組むとCursorとCurrentで意味が重なる |
| 通常版一時view | `CurrentPermutationView` | `NV-04` | 4 | 現在状態へのviewであることを最も明示する | 長い。owner名と合わせると冗長（`NextPermutations.CurrentPermutationView`）。それでも失効条件は文書が要る | `NV-02`と`NV-03`の重ね合わせ |
| 通常版一時view | `EphemeralPermutation` | `NV-05` | 3 | 保存できない短命性を強調する | Swift APIで一般的な語ではない。何で失効するかは出ない | どのownerとも組めるが、語彙がpackage内で孤立する |
| borrowed版入口 | `borrowedNextPermutations()` | `BE-01` | 6 | 通常版と同じ語幹に接頭辞を足すだけで、補完と対応が予測しやすい。Swiftのownership語彙（`borrowing`）にも近い | `borrowed`が何に係るかが曖昧で、sourceを借りるように読める（実際はownerが結果を貸す）。borrowed版はSwift 6.4以上だけで、familyと提供範囲がずれる | `NE-01`・`BO-01`と整合する |
| borrowed版入口 | `borrowedLexicographicPermutationSuffix()` | `BE-02` | 2 | `NE-02`と機械的に対応する | 非常に長く、`suffix`の誤読を共有する | `NE-02`・`BO-02`とだけ整合 |
| borrowed版入口 | `borrowedRemainingPermutations()` | `BE-03` | 3 | `NE-03`と機械的に対応する | 辞書順か、現在を含むかが出ない | `NE-03`・`BO-03`とだけ整合 |
| borrowed版入口 | `borrowedLexicographicPermutationCursor()` | `BE-04` | 2 | `NE-04`と機械的に対応する | 非常に長く、名詞`Cursor`で終わるfactory名 | `NE-04`・`BO-04`とだけ整合 |
| borrowed版入口 | `nextPermutationSpans()` | `BE-05` | 4 | 返るものが`Span`であることが名前から分かる（姫提出） | borrowed版を選ぶ主な理由（寿命をcompilerが検査する）が名前から消える。複数形`Spans`がspanの集合を所有するように読める | `BO-05`と組む（`PF-03`）。通常版`NE-01`とは語幹の先頭が揃う |
| borrowed版入口 | `lendingNextPermutations()` | `BE-06` | 5 | ownerが自分のbufferから結果を貸すという構造を、`borrowed`より正確に表す。lending iteratorという既存の概念に合う | Swiftのownership語彙（`borrowing`）から離れ、Swift利用者には馴染みが薄い。対応owner名が未提出 | owner名が未定のため、familyとしては未完成 |
| borrowed版owner | `BorrowedNextPermutations` | `BO-01` | 6 | 入口`borrowedNextPermutations()`と同じ語幹で、型の予測がしやすい | owner自体が何かを借りている型に見える。複数形の`Sequence`誤読は`NO-01`と同じ | `BE-01`と整合する |
| borrowed版owner | `BorrowedLexicographicPermutationSuffix` | `BO-02` | 2 | `NO-02`と機械的に対応する | 非常に長く、`suffix`の誤読を共有する | `BE-02`とだけ整合 |
| borrowed版owner | `BorrowedRemainingPermutations` | `BO-03` | 3 | `NO-03`と機械的に対応する | 結果の集合を所有する`Sequence`に見える | `BE-03`とだけ整合 |
| borrowed版owner | `BorrowedLexicographicPermutationCursor` | `BO-04` | 3 | `NO-04`と機械的に対応する | 非常に長く、`Cursor`が非標準 | `BE-04`とだけ整合 |
| borrowed版owner | `NextPermutationSpans` | `BO-05` | 4 | 結果の型`Span`を名前に出す（姫提出） | spanの集合を所有するように読める。寿命検査という選択理由が消える | `BE-05`と組む |
| borrowed版owner | `BorrowedNextPermutationCursor` | `BO-06` | 4 | 手動で進める状態であることとborrowed経路を両方示す（姫提出） | 長い。入口`borrowedNextPermutations()`と語幹が完全には一致しない | `NE-01`・`NO-06`・`BE-01`と組む提出（`PF-04`） |
| 補助宣言名 | `Value` | `GP-01` | 6 | 現状で動いており、nested `Permutation`の`Element = Value`と衝突しない | borrowed版の`Element`と揃わず、DocCや診断で両ownerの対応が読みにくい | `GP-02`と排他。現行6 surfaceの選択とは独立 |
| 補助宣言名 | `Element` | `GP-02` | 5 | 両ownerのgeneric parameter名が揃い、DocC・診断で対応が分かる（姫提出） | nested `Permutation`はCollectionとして`Element`を持つため、名前の衝突を避ける実装の確認が必要（未確認） | `GP-01`と排他 |

## 採点完了確認

- 全候補を同じ`1`〜`9`尺度で採点した。
- シンボル名だけでなく、ballotの意図、誤読、互換コストを確認した。
- familyの整合に影響する場合は「他candidateとの関係」へ記録した。
- 他者のRound 1採点を読む前に完了した。
