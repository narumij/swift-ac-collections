# C++ Behavior Comparison Matrix

> 状態: 現行のC++挙動比較正本(2026-10-06)。別版の標準ライブラリ実装を明示的に比較する場合、
> または比較契約を変更する場合だけ更新する。

この文書は公開API一覧ではなく、`CppBehaviorReferenceTests`がC++標準コンテナと
実際に比較した挙動の証拠表である。

`Documentation/Compatibility/`の型別4文書は、この証拠表を根拠に利用者向けの対応関係を
説明する派生文書である。比較作業の履歴は
`Maintanance/Archived/CPP_BEHAVIOR_COMPARISON_TASK.md`へ分離している。

## 判定基準

RedBlackTreeCollectionsはLLVM libc++の赤黒木実装を移植・適応したものであるため、
C++挙動一致の正本はLLVM libc++とする。macOS / Apple toolchainでlibc++を使った
比較結果を、移植元との一致および回帰判定に用いる。

GNU libstdc++など、その他のC++標準ライブラリ実装との比較は参考情報である。
これらは移植性、C++標準が許す実装差、利用者が遭遇し得る挙動の幅を確認するために
実行するが、libc++と異なることだけをSwift実装の不具合とは判定しない。逆に、複数実装で
一致していても、移植元libc++との不一致を正当化する根拠にはしない。

比較対象:

| Swift | C++ |
| --- | --- |
| `RedBlackTreeSet<Int64>` | `std::set<int64_t>` |
| `RedBlackTreeMultiSet<Int64>` | `std::multiset<int64_t>` |
| `RedBlackTreeDictionary<Int64, Int64>` | `std::map<int64_t, int64_t>` |
| `RedBlackTreeMultiMap<Int64, Int64>` | `std::multimap<int64_t, int64_t>` |

## 凡例

| 記号 | 証拠範囲 |
| --- | --- |
| ◎ | 共通する返却事実と操作後の全順序内容を比較 |
| ○ | API差または標準の非保証部分を除き、共通事実と全内容を比較 |
| △ | 関連経路は比較したが、そのAPI固有の返却事実は比較していない |
| — | 現在のC++比較契約には含まれない |

## 操作Matrix

| 操作 | Set | MultiSet | Dictionary | MultiMap |
| --- | :---: | :---: | :---: | :---: |
| 通常挿入 | ◎ inserted/member | ◎ member | ◎ inserted/entry/rank | ○ 全内容（共通rankなし） |
| hint挿入 | ◎ inserted/member | ◎ member/rank | ◎ inserted/entry/rank | ◎ entry/rank |
| `find` / 存在 / count | ◎ | ○ 個体rank除外 | ◎ entry/rank/count | ○ 個体value/rank除外 |
| `lower_bound` | ◎ element/end | ◎ element/rank | ◎ entry/rank | ◎ entry/rank |
| `upper_bound` | ◎ element/end | ◎ element/rank | ◎ entry/rank | ◎ entry/rank |
| `equal_range` | — | ○ 要素列（boundは別途比較） | ◎ bound rank/要素列 | ◎ bound rank/要素列 |
| key/valueによるerase | ◎ 削除有無 | ◎ 削除数 | ○ 削除数/全内容 | ◎ 削除数 |
| 現在rankのerase | — | ◎ 次rank | — | ◎ 次rank |
| 現在rankのremove | — | ◎ 削除要素 | — | ◎ 削除entry |
| mapped value更新 | — | — | ◎ previous value | ◎ previous value |
| subscript代入 | — | — | ○ 全内容 | — |
| default subscript更新 | — | — | ○ 全内容 | — |

すべての操作で、該当時点の完全なordered contentsも比較する。positionは保持した
iterator/indexを輸送せず、各操作直前に現在のzero-based rankからSwift indexとC++ iteratorを
それぞれ独立に解決する。

## 境界・状態Matrix

| 条件 | Set | MultiSet | Dictionary | MultiMap |
| --- | :---: | :---: | :---: | :---: |
| 空／非空への挿入 | ◎ | ◎ | ◎ | ◎ |
| `startIndex` / `endIndex` hint | ◎ | ◎ | ◎ | ◎ |
| 正確／不適切な有効hint | ◎ | ◎ | ◎ | ◎ |
| 同値群の前／先頭／内部／末尾／後 | — | ◎ | — | ◎ |
| 重複または既存keyへの挿入 | ◎ | ◎ | ◎ | ◎ |
| 最小／最大／`Int64.min`／`Int64.max` | ◎ | ◎ | ◎ | ◎ |
| present／absent lookup・erase | ◎ | ◎ | ◎ | ◎ |
| 先頭／末尾／内部のposition操作 | — | ◎ | — | ◎ |
| erase-to-empty／再挿入 | ◎ | ◎ | ◎ | ◎ |
| 削除済みkeyの再挿入 | ◎ | ◎ | ◎ | ◎ |

## Seeded trace

| 項目 | 値 |
| --- | --- |
| PRNG | repository-local `SplitMix64`（既知系列テストあり） |
| Seeds | `1`, `2`, `3`, `0x5EED`, `0xC0FFEE` |
| 操作数 | 各container・各seed 300操作 |
| 状態遷移 | 40操作ごとのgrowing/shrinking phase |
| 再現性 | 同一seedから操作列とcoverageが一致することを検査 |
| 診断 | container、seed、operation番号、入力、両観測、失敗までのtrace |

curated boundary traceとseeded traceを合わせたsuiteは35 XCTest。

## C++標準ライブラリ実装別の結果

ここで分ける軸はコンパイラ名そのものではなく、比較先のC++標準ライブラリ実装である。
「正本」は一致判定に使う移植元、「参考」は標準上の実装差と移植性を観測する環境を表す。

| 位置付け | 比較環境 | 標準ライブラリ | 構成 | 共通契約の結果 | 実装差として観測した事項 |
| --- | --- | --- | --- | --- | --- |
| 正本 | macOS / Apple toolchain | LLVM `libc++` | Debug / Release | 35 XCTest成功 | MultiMap `find`がSwiftと同じ同値個体を選択した |
| 参考 | Ubuntu 24.04 CI | GNU `libstdc++` | Debug | 35 XCTest成功 | MultiMap `find`が同値群の先頭を選択し、Swiftと個体・rankが異なった |
| 対象外 | Windows | MSVC STL | 実施しない | 未検証 | 2026-10-04ユーザー決定。完成条件・追加検証に含めない |

`libstdc++`で見つかった差は、ordered contents、key、count、bounds、equal range、hint配置の
差ではない。C++標準が固定しない`find`の同値群内選択だけだった。この結果を受けて、両環境で
同一に検証できる共通契約からmapped occurrence identityとrankを除外した。

将来、別版のlibc++ / libstdc++や別の参考実装で実行する明示判断があった場合は、
結果を混ぜずこの表へ行を追加する。MSVC STL比較は現行計画では実施しない。

## 標準上の非保証と除外

- `std::multiset::find`と`std::multimap::find`が同値群内のどの個体を返すかは固定しない。
  MultiSetはrankを、MultiMapはmapped occurrence identityとrankを比較しない。
- MultiMapの通常挿入は両APIに共通する返却rankがないため、全内容で配置を比較する。
- Dictionaryの`removeValue(forKey:)`相当のSwift返却valueは、C++ `erase(key)`に対応する
  返却事実がないため比較しない。
- Setのposition eraseとSetの`equalRange`は現在のexecutor契約に含まれない。
- iterator表現、node address、木形、allocator、allocation戦略は比較対象外。
- invalid iteratorや未定義動作は互換要件にしない。
- randomized failureの自動shrinkingは未実装。

詳細な操作生成、coverage count、実行履歴は
`Maintanance/Archived/CPP_BEHAVIOR_COMPARISON_TASK.md`を参照する。
