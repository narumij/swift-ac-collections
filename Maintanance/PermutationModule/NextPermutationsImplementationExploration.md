# NextPermutations実装探索レポート

## 目的

この文書は、`NextPermutations`の通常実装を選ぶまでに調べた候補、反証、および暫定性能値を記録する。
正式な品質適合判定やTest as Specificationの代わりではない。同じ候補を根拠なく再提案したり、採用理由を
会話から復元したりしなくて済むよう、探索結果を保存する。

## 結論

現時点で探索した候補の中では、次の構成を通常経路とする。

- `NextPermutations`は、要素bufferを所有する`~Copyable struct`とする。
- `next()`は、現在のbufferを読む`Permutation` Viewを返す。
- iteratorごとに一つの`GateKeeper`を持ち、すべてのViewが共有する。
- `next()`とiteratorの破棄時に門番の世代を進め、古いViewをpreconditionで失効させる。
- Swift 6.2の`IteratorProtocol`適合は行わず、外側は`while let`で反復する。

Swift 6.4のLifetimesと`Span`を用いる実装は、Viewを省略できるかと到達可能な性能を調べた特殊経路として
`Sources/PermutationModule/BorrowedNextPermutations.swift`の`borrowedNextPermutations()`として、
runtime-check付き通常経路と分離して提供する。

これは絶対的な最適性の証明ではない。下記候補の中で、所有権、Swift 6.2互換性、失効検査、および性能を
最もよく両立したという結論である。

## 探索した候補

### 借用`Span`

Swift 6.4では、`next()`から借用`Span`を返す実装が成立し、今回の候補中で最速だった。`Span`自体が
`Iterable`であるため、返却後の要素走査には`for-in`を使える。

一方、Swift 6.2では、`mutating` methodから`~Escapable`な結果を返す宣言にLifetimesのexperimental
featureが必要になる。`Span`の検討目的は独自Viewの省略であり、通常経路にViewが必要と判明した後で
Spanを追加併存させる利益は小さい。このため、通常経路ではなく特殊経路として保持する。

### Viewごとに門番を生成

Swift 6.2互換の`Permutation` Viewを返し、次の`next()`で前の門番を閉じる実装は、型検査、列挙、および
失効検査に成功した。ただし、順列を一件返すたびに`ManagedBuffer`製の門番を生成するため、28要素中7要素を
選ぶ条件では約118万回のallocationが発生した。

3 cyclesの暫定平均は、28要素で49.26ms、32要素で144.80msだった。同じ測定のC++は19.22ms、
61.33msであり、通常経路としては遅い。

### 共有門番と世代番号

門番をiteratorごとに一つだけ生成し、Viewが発行時の世代番号を保持する構成へ変更した。`next()`または
iterator破棄時に門番の世代を進め、Viewの世代と一致しなければ、bufferへ触れる前にpreconditionで停止する。

これにより、順列ごとのallocationを除去しながら、次の二つを維持できた。

- 次の`next()`へ進んだ後の旧Viewは停止する。
- iteratorが破棄された後に残ったViewも停止する。

当初、世代更新methodを`@inlinable`にすると、Swift 6.4 Releaseコンパイラの`CopyPropagation`がownership
errorでクラッシュした。世代更新を`@usableFromInline @inline(never)`へ分離し、header pointerを直接更新する
形ではDebug／Releaseともbuildできた。この回避は、製品挙動ではなくコンパイラ最適化上の制約による。

### クラスによる`IteratorProtocol`／`Sequence`適合

Swift 6.2の`IteratorProtocol`は`Copyable`を継承するため、`~Copyable NextPermutations`はそのままでは
適合できない。実際のSwift 6.2 compilerは、次の診断で拒否した。

```text
type 'NextPermutations<Value>' does not conform to protocol 'Copyable'
```

`NextPermutations`を`final class`にすると、同じ型を`IteratorProtocol`と`Sequence`へ適合させ、`for-in`で
利用できた。Swift 6.2 typecheck、Release build、列挙、およびView失効testも成立した。

ただし、5 cyclesの暫定平均は28要素で30.50ms、32要素で90.56msとなり、`~Copyable struct`版より
約1.41倍・約1.36倍遅かった。また、代入した参照が同じ反復状態を共有する契約になる。`for-in`だけのために
所有契約と性能を変える利益は小さいため、不採用とした。

## 暫定性能比較

環境はmacOS、Swift 6.4、Release。入力は`0`を`size - 7`個、`1`を7個並べた昇順二値列で、重複しない
lexicographic successorを最後まで列挙し、位置加重checksumを計算する。入力準備は測定外、入力copy、列挙、
checksumは測定内である。

| 実装 | 28要素 | 32要素 | 備考 |
| --- | ---: | ---: | --- |
| 借用Span特殊経路 | 16.01ms | 51.37ms | 5 cycles |
| `std::next_permutation` | 19.24ms | 61.24ms | 5 cycles |
| `~Copyable struct`＋共有門番 | 21.61ms | 66.39ms | 5 cycles |
| `final class`＋共有門番 | 30.50ms | 90.56ms | 5 cycles、別run |
| `~Copyable struct`＋Viewごとの門番 | 49.26ms | 144.80ms | 3 cycles、別run |

通常版`~Copyable struct`は、同じ5-cycle runのC++に対して28要素で約1.12倍、32要素で約1.08倍だった。
測定値は実装探索用であり、正式な外部性能assessmentや品質上の受入判定ではない。

測定例:

```console
cd Benchmarks
swift run --disable-sandbox -c release benchmark run \
  --filter '^(Permutations binary selection checksum|Borrowed Span iterator binary selection checksum|std::next_permutation binary selection checksum)$' \
  --sizes 8 12 16 20 24 28 32 \
  --cycles 5 \
  --mode replace-all \
  /tmp/permutation-runtime-view-5cycles.json
```

## 成立確認

- Swift 6.2 toolchain、Swift 6 language mode、strict memory safetyで通常sourceをtypecheckした。
- 重複要素を含む`[0, 0, 1]`が3順列を返すことをSwift 6.2実行で確認した。
- Swift 6.4のDebug／Releaseで`PermutationModule`をbuildした。
- 次の`next()`後の旧Viewと、所有者破棄後のViewがpreconditionで停止することを確認した。
- 通常列挙と上記失効条件の暫定testを`PermutationTests/EtcTests.swift`へ置いた。

## 残る作業

- 旧Test as Specificationを新しい一時View契約に対して棚卸しする。
- 暫定testを通常test、Death Test、所有・破棄testへ分類する。
- 公開型名、コメントドック、および一時Viewの利用契約をレビューする。
- Swift 6.2向けversion-specific manifestが必要かを、package全体の成立条件から再評価する。
- 正式な外部性能assessmentと受入判断は、凍結中の性能taskを再開した場合に別途行う。
