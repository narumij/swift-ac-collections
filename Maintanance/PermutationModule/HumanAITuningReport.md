# 人間とAIによる実提出チューニング報告

## 目的

この文書は、Swift 6.2向け`NextPermutations`実験実装を実際の組合せ列挙問題へ組み込み、人間とAIが
仮説、機械語、Time Profiler、ローカル反復測定、およびAtCoder実提出を往復して性能差を分解した過程を
記録する。

正式な外部性能assessment、製品版の採用判断、DSUの公開API提案、または安全性評価ではない。会話の中で
得た知見を失わず、後から結果だけを見て誤った原因へ帰属しないための探索報告である。

## 結論

実提出は、調査開始前のSwift 203ms、調査対象となった実験版の約150msから、最速80msまで短縮した。
同じ問題で報告されたC++実提出はClang 67ms、GCC 83msであり、最速のSwift実験版はGCCと同程度だった。

主要な差は`NextPermutations`の順列更新そのものではなかった。C++版との移植条件に、次の非対称性が
残っていた。

- Swift版は候補ごとにDSUのstorageを確保・解放していたが、C++版は一度確保して内容だけを戻していた。
- Swift版は`same`の後に`merge`を呼び、同じ辺についてleader探索を重複させていたが、C++版は一回の
  `unite`で閉路判定と結合を行っていた。
- Swift版のleader探索は再帰だったが、このworkloadでは反復実装のほうが速かった。
- 安全な`Permutation` subscriptの検査コストは、macOS ARM64よりAtCoderのLinux x86_64で強く現れた。

この結果は、DSUのpointer storageや`NextPermutations`のアルゴリズムが本質的に遅いことを示さない。
比較対象の構造を揃えずにend-to-end値だけを順列APIへ帰属していたことが、最初の大きな誤りだった。

## 比較条件

### 実提出

対象問題は、最大で28要素の二値選択状態から7要素を選ぶ1,184,040候補を列挙し、各候補をDSUで判定する。
提出値は単発のjudge観測であり、runnerの揺れを含む。

### ローカル測定

macOS 27.0.1、Apple Silicon上でSwift 6.2 Release buildを使用した。差を見やすくするため、プロファイルと
反復測定には36辺の固定入力を使った。これはAtCoderの制約入力ではなく、処理構成を観測するための負荷である。

したがって、ローカルARM64の順位は仮説生成に使い、Linux x86_64における採否は実提出で確認した。

## 性能の推移

### AtCoder実提出

| 構成 | 実行時間 | 扱い |
| --- | ---: | --- |
| 旧Swift互換版 | 203ms | 過去基準 |
| 新しいsourceを貼った初期版 | 162ms | 過去観測 |
| runtime-check View実験の初期 | 158ms | 参考 |
| inline指定の調整 | 153ms | 小幅改善 |
| `@inlinable`中心の版 | 150ms | 調査基準 |
| ViewからGateKeeper所有を除去 | 150ms | 効果なし、安全性を失うため製品候補ではない |
| DSU再利用＋単一`unite` | 101ms | C++との移植条件を修正 |
| 反復leader | 88ms | 採用した実験枝 |
| 辺走査を`while`化 | 93ms | 改善を再現せず棄却 |
| 選択状態をpointerから直接取得 | 80ms | 最速、安全性を落とした原因切り分け |
| 辺配列もunsafe buffer化 | 81ms | 改善を再現せず棄却 |

C++実提出はClang 67ms、GCC 83msだった。80msと83msの差は単発測定の揺れより小さい可能性があり、
Swiftが一般にGCCより速いという主張には使わない。一方、このworkloadでSwift実験版がGCCと同程度まで
到達可能であることは確認できた。

### macOS ARM64反復測定

同一の36辺入力を7回ずつ実行した中央値は次のとおりだった。

| 構成 | 中央値 |
| --- | ---: |
| 初期基準 | 0.82s |
| DSU storage再利用 | 0.64s |
| 単一`unite`まで適用 | 0.54s |
| 反復leader | 0.48s |
| `for`を`while`へ変更 | 0.46s |
| 選択状態をpointerから直接取得 | 0.46s |
| 辺配列もunsafe buffer化 | 0.45s |

ローカルでは小さく改善した`while`と辺unsafe bufferは、実提出では改善を再現しなかった。ARM64の結果だけで
x86_64向けの枝を採用しない理由となった。

## Time Profilerによる分解

Time Profilerは1ms samplingで取得した。数値は自己時間のsample集計であり、厳密なwall-clock内訳ではない。

| 世代 | CPU sample合計 |
| --- | ---: |
| 初期基準 | 814ms |
| DSU再利用＋単一`unite` | 556ms |
| 反復leader | 494ms |
| 選択状態のpointer直接取得 | 488ms |

初期基準では、DSU探索・結合が約284ms、malloc/freeなどの領域管理が約141msを占めた。DSU再利用と
単一`unite`の後は候補ごとのallocationがほぼ消え、DSU処理も約174msへ減った。反復leaderによって
`DSU._leader`は112msから78msへ減った。

選択状態をpointerから直接取得すると、`Permutation.subscript`として観測されていた72msは消えた。
しかしARM64のsample合計は494msから488msへの変化に留まり、AtCoder x86_64では88msから80msへ短縮した。
同じsource-level境界でも、architectureとoptimizerによって費用の現れ方が異なる実例となった。

## 探索した枝

### inline指定

提出用単一fileへ移した際、library版にあったinline情報を落としていた。機械語ではhot loopから
`NextPermutations.next()`を呼び、View返却に伴うretain/releaseも残っていた。`next()`へ`@inlinable`と
`@inline(__always)`を併記すると関数呼び出しは消えたが、実提出の差は数msに留まった。

inline不足は実在したが、150ms級の主因ではなかった。

### GateKeeper所有

ViewからGateKeeperとgenerationを完全に除き、pointerとcountだけを返す実験を行った。実提出は150msの
ままで、Viewの所有ARCは支配項ではなかった。この版は所有者破棄後や次の`next()`後のView利用を検出できず、
正式実装には採用できない。

### `element(at:)`

安全なsubscriptの代わりに、同じbounds preconditionを持つ`element(at:)`を追加した。ARM64の中央値は
0.82sのままで、compilerは実質的に同じ実装へ統合した。API名やmethod境界だけを変えても検査コストは
消えなかった。

### DSU storage再利用

C++版と同様、DSUを候補列挙の外で一度だけ生成し、各候補では全要素を`-1`へ更新した。ARM64中央値は
0.82sから0.64sへ短縮した。Time Profilerでもmalloc/free群の消滅を確認した。

### 単一`unite`

`same`と`merge`を別々に呼ぶ代わりに、leaderを一度ずつ求めて閉路判定と結合を行う`unite`へ統合した。
ARM64中央値は0.64sから0.54s、実提出は150msから101msへ短縮した。順列実装を疑う前に、C++との処理構造を
揃える必要があった。

### 反復leader

再帰的な経路圧縮を反復実装へ変更した。親を祖父へ圧縮しながら走査位置は親へ進める版が0.48sで最速だった。
走査位置も祖父へ飛ばす、よりC++の式に近い版は0.51sだったため棄却した。実提出は101msから88msへ短縮した。

### Range iterator除去

Time Profilerでは`for i in 0..<M`から`Range.formIndex(after:)`、`IndexingIterator.next()`、
`Collection._failEarlyRangeCheck`へ至るsampleが48msあった。手動`while`はARM64で0.48sから0.46sへ短縮したが、
実提出は88msから93msとなった。x86_64での改善を支持しないため棄却した。

### 選択状態のpointer直接取得

`selected[i]`を、同じfile内の実験として`selected.elements[i]`へ変更した。ARM64では0.48sから0.46sの小差だったが、
実提出では88msから80msへ短縮した。安全なCollection contractを迂回した結果であり、公開APIへそのまま
採用する案ではない。安全検査に性能差があることを確認する反証・上限値として扱う。

### 辺配列のunsafe buffer化

`edges`を`withUnsafeBufferPointer`のscopeへ置き、`baseAddress[i]`から取得した。ARM64では0.46sから0.45sへ
短縮したが、実提出は80msから81msだった。改善を再現しなかったため、通常の`edges[i]`へ戻した。

## 協業の進め方

今回うまく機能したのは、最初から正解を合意したことではなく、互いに異なる観測能力を持ち寄って探索graphを
更新したことだった。

### 人間が担ったこと

- 実際のC++提出、Swift提出、およびjudge値を外部の答えとして持ち込んだ。
- 「IntとInt32の差」「Viewの所有」「subscript」「DSUの使い方」など、アンカリングが外れた時点で新しい枝を
  提示した。
- 改善が小さい枝でも、実提出する価値と操作コストを判断した。
- ローカルがARM64、judgeがx86_64であることを指摘し、ローカル結果の過剰一般化を止めた。

### AIが担ったこと

- Swift 6.2用の再現環境を作り、Release buildと機械語を確認した。
- 一度に一条件だけを変え、ローカル反復測定で枝を事前評価した。
- Time Profiler XMLを同じ方法で集計し、次の候補を自己時間から選んだ。
- 改善を再現しない枝を戻し、最良点を保持した。
- 当初の「DSU allocationが主因」という強すぎる推定を、profile結果に従って訂正した。

### 答えを持つものへ聞いた順序

この探索では、会話上の納得を証拠にしなかった。

1. compilerへ、Swift 6.2で成立する宣言と最適化結果を聞いた。
2. assemblyへ、inline、ARC、witness dispatch、およびallocationが残る場所を聞いた。
3. Time Profilerへ、実時間が集中する場所を聞いた。
4. 同一条件の反復測定へ、局所変更の方向を聞いた。
5. AtCoderのLinux x86_64実提出へ、対象環境で改善が成立するか聞いた。

答えが食い違った場合は、対象環境に近い証拠を優先した。macOS ARM64の結果は枝の発見に有用だったが、
Linux x86_64で改善しなかった枝を採用する根拠にはしなかった。

## 今回の失敗と訂正

- 最初はend-to-endの差を順列実装へ強く帰属した。C++とSwiftのDSU利用構造を先に照合すべきだった。
- assemblyから候補ごとのallocationを見つけた時点で、それを主因と表現した。profile後、DSU探索、検査、
  順列更新も大きく、allocationだけでは説明できないと訂正した。
- `Permutation.subscript`のsampleを見て`element(at:)`を提案したが、同じpreconditionを持つmethodへの改名では
  機械語が変わらなかった。
- ARM64で改善した`while`と辺unsafe bufferを期待したが、x86_64実提出では再現しなかった。

これらは隠すべき失敗ではなく、次の枝を狭めた証拠である。

## 再利用できる知見

1. 外部実装との性能比較では、対象APIだけでなく周辺アルゴリズムのallocation、初期化、重複探索、早期終了を
   先に対称化する。
2. end-to-end値とcomponent benchmarkを混同しない。順列単体が速くても、利用コードのDSUやaccessorが
   支配することがある。
3. assemblyは「何が残ったか」、profilerは「何が支配したか」、実提出は「対象環境で成立したか」を答える。
   一つの証拠で三つすべてを決めない。
4. 一枝ずつ変更し、改善しない枝を戻す。複数変更を混ぜると、採否と復旧の境界が失われる。
5. architectureをまたぐ最適化では、ローカル計測を候補探索、対象環境を受入証拠として使い分ける。
6. 安全性を外した上限実験は、正式案ではなく「安全性の費用がどこにあるか」を示す比較点として保存する。

## 現在の実験sourceの扱い

`Maintanance/User/PermutationBorrowedSpanExperiment.swift`は、80msへ到達したunsafeな上限実験をそのまま
製品候補にせず、runtime-check付き一時Viewへ戻した収束後の状態を保持する。DSU再利用、単一`unite`、
反復leaderは提出側の最適化として残す一方、ViewはGateKeeperとgenerationを保持し、要素accessも公開subscriptを
経由する。80ms枝の内容と結果は本書およびcommit履歴に保存する。

Swift 6.4 Releaseで36辺の固定入力を7回実行したところ、unsafeな80ms枝相当、安全なViewへ戻した版、
`next()`から`@inline(__always)`を外した版、GateKeeperの`closeCurrentView()`を製品版と同じ
`@inline(never)`へ戻した版は、いずれも中央値0.46秒だった。出力もすべて一致した。ARM64ローカル測定の
分解能では追加inline指定、安全検査の除去、およびDSU宣言順に差を確認できなかった。

したがって、製品版Permutationには今回の探索を理由とする変更を追加しない。大幅な短縮は、DSU再利用、
単一`unite`、反復leaderによってC++版との周辺処理構造を揃えた成果として分離する。選択状態のpointer直接取得で
AtCoder実提出が88msから80msへ短縮した事実は、安全な公開契約を迂回した上限値であり、製品実装の採用根拠には
しない。
