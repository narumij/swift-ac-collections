# Mapped Values Viewの範囲契約の判断

2026-10-16、Astra記録。RBT-026。

## 現在の依頼

ユーザーが、姫と議論して決めたい課題として復帰を指示した。ACTIVEのDECISIONとして扱う。AstraとClaude（姫）が判断材料と意見を整理し、最終判断をユーザーへ返す。状態・担当・依存関係の正本は[Task Registry](../ProgressV2/TASK_REGISTRY_V2.md)。2026-10-18、ユーザーの依頼によりAstraが現行照合を行い、下記の限定議論を姫へ正式依頼。契約変更は未実施。

## 決めること

Mapped Values Viewの範囲について、O(1)と呼び出し側事前条件による現行契約を維持するか。

既存taskに記録された論点は、View外でもbase treeでは有効なIndexを黙って読み書きし得ること。現行API・実装と照合し、具体的な成立条件を確かめてから判断する。現時点で製品の不具合や契約変更を確定しない。

## 議論に用意する材料

- RBT-014の現行API照合結果と、該当Viewの読み書き・範囲外Indexの具体例。
- 利用者が満たす必要のある事前条件と、誤用時の現行動作。
- 現行契約を維持する場合の説明・検査、および契約を変える場合の選択肢と性能・互換性への影響。

Astraと姫の意見は根拠とともに区別して残す。意見の一致だけを検証やユーザー判断の代わりにしない。必要な調査や実験の範囲は議論の準備時に具体化する。

## 完了と境界

RBT-014による判断材料の充足という先行依存は維持する。材料と両者の意見を提示し、ユーザーの判断・理由・適用範囲をこの正本へ記録して判断taskを閉じる。実装や公開契約文書への反映が必要なら、判断に従った後続作業として分ける。

## 参照

- [ViewのAPI Matrix](../../Sources/RedBlackTreeCollections/Documentation/API-Matrix-View.md)
- [API Matrix](../../Sources/RedBlackTreeCollections/Documentation/API-Matrix.md)
- [復帰前の記録](../Archived/RBT-026_BEFORE_REACTIVATION_2026-10-16.md)

## 議論とユーザー判断

未記入。

## 文書マイルストーンへの接続（2026-10-16）

旧RBT-014はユーザー指示で[文書マイルストーン](DOCUMENTATION_MILESTONES.md)へ移行した。関連する現行API照合が判断材料として必要な点は維持する。旧taskの整理を照合完了とせず、文書整備全体の達成待ちにも広げない。

## Astraの議論準備（2026-10-18）

入力の製品・試験・API Matrixはcommit `153c4b9a0e6f3da9657b48abadfd27598aa82f6b` に固定。以下はソース読解であり、今回の実行試験・計測はなし。パスはrepo相対。

| 確認した事実 | 固定版の根拠 |
| --- | --- |
| View内要素を指すIndexは呼び出し側の事前条件。操作ごとの所属検査をせず、明示的な `isElement(at:)` を案内 | `Sources/RedBlackTreeCollections/Documentation/API-Matrix-View.md:52-56` |
| subscript getterはtreeのaddress取得、setterはCoW準備後にaddress取得。View境界を渡していない | `Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeMappedValuesView.swift:143-163` |
| swapAtはCoW準備とtree側Index解決を行い、境界検査なしでmapped valueを交換 | 同ファイル `166-190` |
| isElementはIndex解決に加えてViewの半開範囲を検査し、最悪O(log n)を明記 | 同ファイル `349-376` |
| address取得は解決失敗をfatalErrorで拒否。範囲所属とIndexの解決可否は別 | `Sources/RedBlackTreeCollections/Implements/UnsafeTreeV2/UnsafeTreeV2+Subscript.swift:28-43` |
| Index解決にはALLOW_CROSS_TREE_INDEX等の分岐がある。別treeを一律拒否と一般化しない | `Sources/RedBlackTreeCollections/Implements/UnsafeTreeV2/UnsafeTreeV2.swift:162-184` |
| 範囲内swapとCoW保持、キー比較0回のsubscript/swap試験が存在する。存在確認であり今回のPASSではない | `Tests/RedBlackTreeTests/RedBlackTreeView/RedBlackTreeView_0_MappedValuesViewTests.swift:51-92,120-145` |

### Astraの暫定意見

現行の呼び出し側事前条件を維持し、必要時に明示検査する方式が第一候補。範囲内Indexの利用とIndex自体の解決失敗を分けた設計が、文書・実装・既存試験で読み取れるため。ただし、View外かつbase tree内の有効Indexでどこまで読み書きできるかは、今回実行しておらず姫の照合に残す。事前条件違反の結果を新たな保証として固定しない。

キー比較0回は操作全体のO(1)の証明ではない。setter/swapAtの `_ensureUnique()` によるコピー費用を分け、範囲検査の追加費用と混同せず議論する。測定なしに性能差を数値化しない。

## 姫への正式依頼：範囲契約の限定議論（RBT-026）

2026-10-18ユーザー承認の議論準備に基づく依頼。最終判断はユーザーへ返す。今回の成果は調査結果と意見であり、製品修正ではない。

1. 上記固定版の関係箇所を確認し、Astraの事実認識に誤りがあれば根拠付きで指摘する。
2. Dictionaryの部分範囲valuesを代表に、View内・View外だがbase内・Viewのendがbaseの実要素である場合を、getter/setter/swapAtについて整理する。CoW前後・Index解決分岐に依存する範囲を明記。原則ソース読解でよい。実行が必要なら隔離した一時再現だけとし、製品・既存試験は変更しない。実行しないものは予測と明記する。
3. 現行維持、毎回の所属検査、明示検査API利用の選択肢を比較し、推奨と理由・不確かさを短く返す。既存 `isElement(at:)` で足りるかも含める。全API監査・性能計測・契約変更へ広げない。

編集占有は本書の下記「姫 Return」のみ。作業前に短い内訳を書き、指定範囲なら続行可。Sources・Tests・Registry・他正本・Studioの編集、サーバー再起動、commitなし。根拠はcommit・パス・行位置、事実と推測と提案を分ける。範囲を越える確認が必要なら不足と必要な調査を返して止める。返却後はAstra受入待ち。

## 姫 Return

2026-10-18 姫・Opus 5.5。固定版`153c4b9a0e6f3da9657b48abadfd27598aa82f6b`（作業時のHEADと同じ。Sources・Package.swiftの差分なし）。Sources・Tests・Registry・Studioは変更していない。commitなし。

作業内訳：(1) Astraの表を固定版で読み直す。(2) 部分範囲valuesで3つの場合 × getter・setter・swapAtを整理する（隔離した一時再現を1回）。(3) 3案を比べる。

### 1. Astraの事実認識

表の7行は、固定版の該当行と一致した。誤りは見つからなかった。補足が3点ある。

- `ALLOW_CROSS_TREE_INDEX`は既定で有効（`Package.swift` 25行、無効化は「実質deprecated」と注記）。`__purified_`は、同じ木ならそのまま、別の木ならtag（「千本引き」）で引き直す（`UnsafeTreeV2.swift` 162〜176行）。
- setterとswapAtは、Indexを解決する**前に**`_ensureUnique()`を呼ぶ（`RedBlackTreeMappedValuesView.swift` 158・176行）。そのため、解決できないIndexでも、共有中ならコピーが先に起きてからfatalErrorになる（ソース読解からの予測、未実行）。
- Viewの`_ensureUnique()`は、コピーが起きたとき、View自身の始点・終点をtagで引き直す（同 85〜96行）。渡されたIndexのほうは、上の`__purified_`の引き直しで新しい木に解決される。

### 2. 3つの場合の整理（Dictionary、`d[lo..<hi].values`）

実行：隔離した一時パッケージ（リポジトリ外、`.package(path:)`で固定版を参照、Swift 6.4、debug・release同結果、終了後に削除）。辞書は1〜6のキー、Viewはキー2..<5で、endはキー5の実要素。

| 場合 | getter | setter | swapAt | isElement |
|---|---|---|---|---|
| View内（キー3） | 値を返す | 書き込む | 交換する | true |
| View外・base内（キー1、6） | **base要素の値を返す**（実行） | **View外のbase要素に書き込む**（実行） | **View外の要素と交換する**（キー3と6で実行） | false |
| Viewのend＝baseの実要素（キー5） | **キー5の値を返す**（実行） | **キー5に書き込む**（実行） | 同様（予測） | false |

- CoW前後：共有中のコピーを取ってから、View外に書き込むと、コピー側は元のまま、元の辞書のView外の要素だけが変わった（setter・swapAtとも実行）。値の意味は保たれ、誤った要素が書き換わる点は共有の有無で変わらない。
- Indexの解決分岐：別の辞書（同じ形で作ったもの）のIndexが、tagでこの辞書の要素に解決された。`isElement`もtrueを返し、setterはこの辞書の要素に書き込んだ（実行）。「別の木のIndexは一律に拒否」とは言えない。これは`ALLOW_CROSS_TREE_INDEX`の設計どおりで、本件の範囲契約とは別の論点として残す。
- 下層で拒否されるもの：解決できないIndex（無効化済み・世代不一致など）は`fatalError`（`UnsafeTreeV2+Subscript.swift` 36〜42行）。今回は実行していない。
- debugの内部検査（`AC_COLLECTIONS_INTERNAL_CHECKS`）でも、範囲所属は検査されなかった（debugの実行結果がreleaseと同じ）。

### 3. 選択肢の比較

| 案 | 費用 | 誤用時 | 互換性 |
|---|---|---|---|
| A：現行維持（呼び出し側の事前条件＋必要時に`isElement`） | O(1)のまま（setter・swapAtのCoW費用は別） | View外・endの実要素を黙って読み書きする。メモリ安全は保たれる | 変更なし |
| B：毎回の所属検査 | 所属判定は最悪O(log n)（`isElement`の明記）。subscript・swapAtのO(1)契約を外すことになる | 範囲外をtrapできる | 公開契約の変更。現在View外のIndexを使う呼び出しがあれば壊れる（有無は未調査） |
| C：明示検査API（`isElement`）を使ってもらう | 使うときだけO(log n) | Aと同じ。検査した呼び出しだけ守られる | 既存APIで足りる。新しいAPIは不要 |

参考：標準のArraySliceは添字で範囲を検査するが、その検査はO(1)。ここでは同じ検査がO(log n)になるので、同列には比べられない（推測を含む比較）。

### 4. 推奨（提案）

**A＋C（現行維持で、範囲所属の確認には`isElement(at:)`を案内する）**を推奨する。

- 理由：
  - 文書・実装・既存試験が、「範囲所属は呼び出し側」「Index自体の安全性は下層」という分担でそろっている。
  - 誤用でも壊れるのは値の取り違えで、メモリ安全は保たれる。
  - Bは、O(1)を約束した2つの操作を、すべての利用者についてO(log n)にする。
  - `isElement`は、View内／View外／end／解決不能をすでに区別できている（実行で確認）。
- 不確かさ：
  - 「View外・endの実要素は黙って読み書きされる」ことは、今の文書（API-Matrix-View 52〜56行）では「事前条件」とだけ書かれている。誤用時の具体的な挙動は書かれていない。これを文書に書くかどうかは、新しい保証にしない書き方を含めて、ユーザーの判断。
  - 別の辞書のIndexがtagで解決される点（`isElement`もtrue）は、範囲契約とは別の判断で、今回は扱っていない。
  - 実利用で、View外のIndexを使っている呼び出しがあるかは調べていない。

参照したキャッシュ：なし。

## 追加委任：姫からStudioへの進行連絡試行（2026-10-18）

ユーザー「やってみよう」により、RBT-026に限り既存activity経路への追記を委任する。上のStudio編集禁止に対する例外は、下記コマンドによる進行イベントの追記だけ。依頼本文・成果物の占有範囲は変えない。着手済みの場合も作業をやり直さず、追加手順を読んだ時点から適用し、過去イベントを捏造しない。

repoルートで、実際にその段階になった時だけ実行する。

```sh
# 着手時
python3 -B Maintanance/RegistryApp/activity.py --task RBT-026 --event work --owner '姫' --reason '範囲契約の限定議論に着手'
# 相談が必要で停止する時（先に姫 Returnへ論点を書く）
python3 -B Maintanance/RegistryApp/activity.py --task RBT-026 --event work --owner '姫' --reason '相談待ち：正本の姫 Returnを確認してください'
# 成果を姫 Returnへ保存し終えた時
python3 -B Maintanance/RegistryApp/activity.py --task RBT-026 --event return --owner '姫' --reason '議論材料を正本の姫 Returnへ返却。Astra受入待ち'
```

現行イベント種別に相談待ちはないため、今回はworkの説明で表す。正本は `Maintanance/Current/MAPPED_VALUES_VIEW_CONTRACT_DECISION.md`。詳細はReturnへ、帯には短い連絡だけを書く。実行結果が成功したことを確認し、失敗なら通常の会話で連絡してReturnに失敗を残す。成功扱いで黙って終えず、権限回避・サーバー修正・再起動はしない。

イベントはGit対象外の共有履歴へ排他追記され、稼働中Studioが既存の定期取得で表示する。syncや画面操作は不要。Registryの状態変更、受入済み認定、commit承認・実行は含まない。Astraは作業再開時・受入確認時に該当イベントを読み、正本の返却内容を確認してから受入を行う。イベントだけで完了にしない。通知によるAstraの自動起動・常時監視は今回含めない。

試行の確認点：姫の実イベントが帯へ表示され、タスク番号から返却先が特定でき、ユーザーによる完了伝言を省けること。まだ姫の実送信・表示は未確認。

## Astra受入（2026-10-18）

議論材料として補正付き受入。姫の原Returnは保持する。Package.swiftの既定設定、Index再解決分岐、setter/swapAtでCoWが先行する順序を独立にソース照合し、準備時の範囲検査不在の確認と整合した。今回Astraは実行試験をしていない。姫の一時再現はソース・完全ログが保存されていないため、debug/releaseの実行結果は担当者報告として受領し、独立再現済みの証拠にはしない。

受入時の読み替え：
- 「メモリ安全は保たれる」は全ケースの保証として受け入れない。本件で読んだ実装には解決失敗の拒否があり、base内の要素へ範囲外アクセスし得ることと区別する。今回メモリ安全性の全面検証はしていない。
- 推奨理由の「解決不能も実行で確認」は、Return自身の未実行記述に従い、解決不能はソース読解のみとする。
- O(log n)は既存isElement方式による所属検査の最悪計算量。あらゆる代替方式の下限を証明したものではない。O(1)はCoW等の費用と区別する。
- ArraySlice比較は本判断の独立確認済み根拠に使わない。

Astraの推奨は現行維持＋必要時isElementのまま。範囲外利用の具体的結果を新たな公開保証にしない。製品変更なし。姫への追加依頼なし。RBT-026は材料がそろったためWAITING_USERとし、ユーザーの契約判断後に閉じる。

連絡試行：Activity履歴で姫のwork（2026-10-18 15:36:52 JST）とreturn（15:39:21 JST）を確認。直接保存と受入側での読み取りは成立。Safariの帯表示は未確認。今回はユーザーの完了連絡で受入を開始しており、自動起動や中継不要まで実証したものではない。

コミット事前承認2件を確認。今回の文書記録を範囲照合後にcommitし、承認履歴へSHAを記録する。参照したキャッシュ：なし（今回の受入）。
