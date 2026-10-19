# Registry V3 隔離DB読取実験（OPS-160）

## TL;DR（人間向け）

明示順のfixtureを、メモリ内のSQLiteへ読み込み、構造・順序・現在位置での読取範囲を取り出す、隔離の実験。現行のRegistry・Milestones・Studio・実DB・サーバーには触れない。更新と採番のAPIはない。正本は[TASK_REGISTRY_V3_READ_EXPERIMENT.md](../../../Current/TASK_REGISTRY_V3_READ_EXPERIMENT.md)。

## 実行

```sh
python3 -B Maintanance/RegistryApp/Experiments/registry_v3_read/test_registry_v3_read.py -v
python3 -B Maintanance/RegistryApp/Experiments/registry_v3_read/registry_v3_read.py Maintanance/RegistryApp/Experiments/registry_v3_read/fixtures/base.json [current|all]
python3 -B Maintanance/RegistryApp/Experiments/registry_v3_read/test_registry_v3_write.py -v   # 区切り2：更新契約
python3 -B Maintanance/RegistryApp/Experiments/registry_v3_read/test_shadow_import.py -v       # OPS-163：固定写しの照合（試験用の木）
python3 -B Maintanance/RegistryApp/Experiments/registry_v3_read/test_registry_v3_recovery.py -v  # OPS-164：世代・履歴・backup・復元
python3 -B Maintanance/RegistryApp/Experiments/registry_v3_read/test_studio_adapter.py -v       # OPS-165：Studio関数との接続（node要）
python3 -B Maintanance/RegistryApp/Experiments/registry_v3_read/test_browser_roundtrip.py -v    # OPS-166：隔離HTTP・headless WebKit（導入済みPlaywright要）
python3 -B Maintanance/RegistryApp/Experiments/registry_v3_read/test_change_groups.py -v        # OPS-168：複数taskの変更群
python3 -B Maintanance/RegistryApp/Experiments/registry_v3_read/test_registry_v3_structural.py -v  # OPS-169：構造の更新（K2）
python3 -B Maintanance/RegistryApp/Experiments/registry_v3_read/test_structural_groups.py -v      # OPS-170：保存の構造変更群
python3 -B Maintanance/RegistryApp/Experiments/registry_v3_read/shadow_import.py [--evidence FILE.json]   # 現行正本を読むだけ
```

Pythonの標準ライブラリだけを使う。DBはメモリ内に作る。現行の読取（`sync.py`の`build()`）との比較では、一時ディレクトリにRegistryとMilestonesの写しを書く。`sync.py`はモジュールとして読み込み、パスを差し替えて使う。`sync.py`そのものは変えない。

## ファイル

| ファイル | 内容 |
| --- | --- |
| `registry_v3_read.py` | 読み込み（`load`、1つのトランザクションで、拒否すると全部を取り消す）、派生の骨格（`skeleton`）、読取（`read`、`current`か`all`） |
| `fixtures/base.json` | 版A・B・C（0.1.0〜0.3.0）を明示順に並べたfixture。カード・ゲート・タスク5件と、管理・進捗・到達点の3つのグラフ |
| `registry_v3_write.py` | 区切り2（OPS-161）の更新契約。Pythonから呼ぶ`apply(conn, 操作ID, 要求)`だけで、HTTP・UI・Inboxにはつながない |
| `test_registry_v3_write.py` | 区切り2の試験。試験ごとに`TemporaryDirectory`のSQLiteファイルを使う。2接続の競合も試す |
| `test_registry_v3_read.py` | 期待値は、原型仕様と設計の表から手で書いた。共通の部分は、現行の読取とも比べる |

## モデル

- **ID**：`nodes`に、すべての種類（task・card・gate・start・end）のIDを1つの空間で置く。START-とEND-は、版から読み込み側が作る。fixtureからは書けない。
- **順序**：版の位置と、版の中のカードの順は、fixtureの並びのとおり。フォルダを比べる一般の規則は作らない。
- **派生の骨格**：保存しない。次のように導く。
  - 各版で、START→カード→END。
  - END→ゲート。ゲート→次の版のSTART。
  - ゲートのIDは識別子にすぎず、行き先を表さない。
  - ゲートのない版は、次の版につながらない。最後の版のゲートは、そこで終わる。
- **グラフ**：`management`（親→子）、`progress`（タスク→タスク）、`milestone`（タスクと到達点）を分けて持つ。循環は、管理の中と、作業の順（progress・milestone・骨格を合わせたもの）の中で拒否する。管理と進捗をまたぐ循環は、循環として扱わない。
- **focus**：読取の範囲を選ぶだけ。到達（DONE）は導かない。マイルストーンの状態は保存しない。
- **属性**（OPS-161の区切り1）：保存した値だけを返す。派生した値は返さない。
  - タスク：condition・detail・permanent・group
  - カードとゲート：名前・detail
  - カード：書かれたままのDONEの箱（`recordedDone`）。ゲートにはない。
  - 辺：flow・constraint（`edges`）。`relations`は、同じ辺の組だけを持つ。
- **出典**：`provenance`に、fixtureのどこから来たかを記録する。読取では、構造とは別に返す。範囲は次のとおり。
  - `current`：返したノード・境界の参照・辺・版の分だけ。
  - `all`：全部。

## 期待値の出どころ

- 原型仕様（`Milestones/DESIGN.md`）と、設計の「隔離読取試行へ渡す期待値」の表から、手で書いた。
- 共通部分（基本の構造、カードの並べ替え）は、現行の読取とも一致することを確かめる。対象：ID、タスクの欄、3つのグラフ、骨格、カードの順、ゲート。
- **既知の差**：次の3つは原型仕様を期待値にする。現行の読取の拒否は「KNOWN DEVIATION」として記録するだけで、成功の条件にはしない。
  - 任意の名前のゲート
  - ゲートの欠落
  - 末尾のゲート

## 限界

- タスクの位置は、つながっている到達点の版から決める。どこにもつながらないタスクは、`all`の読取にだけ出る。
- ゲートは、それを置いた版の範囲に入れる。focusの版より前の版のゲートは、境界の参照として返す。
- **現行の読取との比較**：
  - 比べるもの：タスクのすべての欄（condition・detail・permanent・groupを含む）、カードとゲートの名前とdetail、進捗の辺のflowとconstraint、到達点の接続のconstraint（`\|`を含む）。
  - 除くもの：
    - 状態の派生（HEADによるDONE）。そのため`recordedDone`も比べない。現行の読取は、派生した状態しか持っていない。
    - `raw`・`sourceLine`・`source`
  - 改行と縦棒の値は、実験の側だけで確かめる。Markdownの表のセルは改行を持てない。また現行の読取は、`\|`を到達点の接続でしか戻さない。
- **これは実験で、すべてを写す移行ではない**：
  - Markdown上の位置（raw・sourceLine）と、派生した状態は返さない。
  - 本番のschemaとの完全な互換は約束しない。
  - Studioの保存形式（`source.sha256`など）への変換は扱わない。
- 境界の参照は、ID・種類・所在だけ。属性は展開しない。
- 読み込みは、BEGINのあとに起きたどの失敗でも全部を取り消し、トランザクションを閉じる。
  - 構造の拒否は`Refused`、整合性の違反も`Refused`にする。
  - 欄の欠落などの不正な入力は、元の例外のまま返す。
  - 未知の読取範囲は`ValueError`で拒否する。
- 書込・採番・競合・再送・同時実行は扱わない（次の区切り）。

## 区切り2：更新契約（`registry_v3_write.py`）

- **1回の操作**：`BEGIN IMMEDIATE`のトランザクション1つで行う。データ・発行の記録・操作の記録・新しい改訂は、一緒に確定する。途中で失敗したら全部を取り消す。
- **再送**：操作IDと要求のSHA-256を残す。
  - 同じIDで同じ要求なら、前の結果（拒否も含む）を返し、何も書かない。
  - 同じIDで違う要求は`OperationMismatch`。
  - 拒否のあと内容を減らして出し直すときは、新しい操作IDを使う。
- **採番**（`register_task`）：prefixのhighwater+1を使う。
  - 発行済みの番号と、退役した番号は使わない。
  - 確定前の候補は外に出ない。失敗したら、その番号は発行されなかったことになる。
  - 提案のキー（`saveId`・`draftId`）は1回だけ正式IDに対応づける。同じキーをもう一度登録しようとすると拒否する。
- **更新**（`update_task`）：変える欄ごとに基準の値を付ける。
  - 最新の値が基準と同じなら適用する。新しい値と同じなら「反映済み」とする。
  - それ以外は競合で、操作全体を拒否する。
  - 同じ基準から別の欄を変える操作は、どちらも残る。
- **退役**（`retire_task`）：IDは予約として残す。再利用しない。退役したタスクの編集と、退役したタスクへの辺の追加は拒否する。
- **辺の追加**（`add_edge`）：トランザクションの中で、確定済みの最新の状態に対して検査する。単独では通る2つの辺が、合わさると循環になるなら、後に来たほうを拒否する。管理の循環と、進捗の循環（到達点の接続と骨格を含む）は、別々に検査する。
- **拒否の記録**：拒否（`Refused`）が起きたときの扱い。
  - 業務の変更を`SAVEPOINT`まで戻し、同じトランザクションの中で記録してから確定する。
  - そのため、拒否と記録の間に、別の要求が同じ操作IDを取ることはない。
  - それ以外の例外は、トランザクション全体を取り消し、記録しない。
- **発行済みの台帳**：fixtureの`issuedThrough`（`{PREFIX: n}`）で、今はないIDも含めて、どこまで発行したかを渡せる。
  - highwaterは、今あるIDと台帳の大きいほう。
  - 台帳は、1..nの番号をすべて、再利用しない予約（ダミーの割当て）にするだけ。2026-10-19のユーザー指示による。過去のIDは再利用されたことがあり、復元すると危ないため。
  - ない番号については、タスクのノード・発行の行・過去の正体や文書との対応を作らない。ノードになるのは、fixtureにあるタスクの行だけ。
  - 予約かどうかは`is_reserved`で確かめる。
  - 今あるIDより小さい台帳、不正なprefix、整数でない値は拒否する。
  - 拒否したときは、作りかけのファイルを残さない。
  - すでにあるファイルには触れない（`FileExistsError`）。
  - 実際のRegistryは読まない。
- **項目名**：`item`を変えると、`nodes.name`も同じトランザクションでそろえる。

### 区切り2の限界

- 1つのプロセスの中で、Pythonから呼ぶ契約の試験だけ。HTTP・認証・Studio・実Inbox・本番DBはない。
- 競合の判定は、欄の値の比較だけ。条件の意味の変化は検出しない。
- 提案の対応は、固定のキーで試すだけ。Inboxの系列をまたいで同じ提案だと判定することはしない。曖昧な場合の扱いは決めていない。
- 退役は、読取（`registry_v3_read.read`）にまだ出ない。
- 辺の追加は、管理と進捗だけ。到達点の接続と、版・カードの操作はない。
- `operations`には、成功と拒否の結果をずっと残す。消し方や保存の期間は決めていない。

## OPS-163：現行正本の固定写しの照合（`shadow_import.py`）

1. **写す**：一時ディレクトリに写し、manifestに記録する。
   - 写すもの：Registry、Rules、`Milestones/README.md`、`HEAD.md`、版フォルダのすべての項目、それらの`# 正本`のリンク先。
   - 記録するもの：パス・役割・大きさ・SHA-256、Gitの基準（HEADのcommit、HEADのblob、写した内容のblob、未commitの差分）。
   - 写したあと元を読み直し、フォルダも数え直す。変化があれば`Drift`で止める。
2. **確かめる**：写しを、manifestのhashと照らす。合わなければ`Tampered`。
3. **読む**：写しだけを読む。現行の読取とは別の、独立した読取で読む。
   - 対象の節の表の行は、すべて取り込む。
   - 取り込めない形は`Unknown`で拒否する。
     - 列の数が違う、IDが逆引用符で囲まれていない
     - `###`の中の先行関係の行（現行の読取は黙って読み飛ばす）
     - DONEの箱が0個か2個以上のカード
     - 版フォルダの中の、知らないファイルやサブフォルダ
     - HEADや採番表の形の誤り
   - 対象の外の節にある表の行は、報告するだけ。タスクの行の形をした行は、`taskShapedOutOfScope`として別に挙げる。
   - 受入で見つかった誤った成功への対策（2026-10-19）：
     - 対象の4つの節は、それぞれちょうど1回だけ現れなければならない。節の名前の誤りや重複は拒否する。
     - 字下げした表の行：対象の節の中なら拒否する。対象の外の節なら`indented`として報告する。採番表の中なら拒否する。
     - 版フォルダそのもの（空のものを含む）を、manifestの`listing`・写し・確かめ・変化の検出に含める。空の版は照合でも落とさない。
   - 版の順は、現行の実装の順（`sync.vkey`）を、固定した入力として記録する。
4. **照合する**：隔離したDBに読み込み、同じ写しを現行の読取（`sync.build()`）が読んだ結果と、意味で比べる。
   - 比べるもの：タスクの属性、親子、先行関係（flow・constraint）、到達点の接続（constraint）、版とカードの順、ゲート、骨格、カードの名前と正本。
   - `recordedDone`は、現行の読取が箱を使う版（HEAD以降）だけで比べる。HEADより前の版は、派生したDONEと並べて報告するだけ。
   - 採番：採番表の番号までを予約し、次の番号を報告する。過去のタスクは復元しない。
   - 除いたもの（`raw`・`sourceLine`・派生した状態・`source`の塊・関係の出典）は、理由と一緒に`excluded`へ出す。完全な互換とは呼ばない。
   - 原型仕様との既知の差は、`deviations`として別に報告する。

**証拠**：`evidence/shadow-a18395bfb.json`（HEAD `a18395bfb`、未commitの入力なし）。
- 結果：`equal=True`、差分なし、既知の差なし、採番表に欠けたprefixなし、対象の外の表の行は0。
- 取り込んだ件数：タスク77、親子34、先行10、到達点の接続26、版8、カード6、ゲート7、採番表のprefix18。
- 読取の範囲：focusは0.6.0。currentは45ノードで境界の参照が5、allは106ノード。

**限界**：
- 写しと比較は、1回だけの点検。正本はMarkdownのままで、DBは一時的なもの。
- Studioの形式（`source.sha256`・`raw`・行番号）は作らない。
- 採番表は、prefixごとの番号だけ。IDごとの過去の履歴ではない。
- 現行の読取がセルの中の`\|`を戻すのは、到達点の接続だけ。両方とも同じ写しを読むので一致するが、意味の上では未解決のまま。

## OPS-164：世代・変更履歴・backupと復元（`registry_v3_recovery.py`）

- **世代**：DBを作るときに世代ID（`db_meta.generation`）を付ける。
  - 要求は、`generation`・`actor`（自己申告。認証はしない）・`evidence`（根拠の参照の一覧）を持つ。
  - 世代が違う要求は、何も変えずに拒否する（`GenerationMismatch`）。記録もしない。
  - 改訂番号は、世代の中での順序。
- **操作の履歴**：`operations`に、次のものを変更と同じトランザクションで保存する。
  - 要求の本文・digest・結果・実行者・根拠・変更の前と後
  - 拒否も、要求と結果を残す。前と後はない。
  - 照会は`registry_v3_write.operation()`。
- **backup**：SQLiteのbackup APIで、整合した写しを新しいファイルに作る。
  - `<path>.manifest.json`に、schemaの版・世代・改訂・大きさ・SHA-256を記録する。
  - すでにあるファイルとmanifestは上書きしない。
  - 書き先は`O_EXCL`で排他的に確保する。確かめてから作るまでの間に別のファイルが現れても、それには触れない。
  - 失敗したときに消すのは、自分が作ったファイルだけ。
  - 写しはメモリへ取ってからserializeし、書いたバイト列そのもののhashをmanifestに記録する。
- **確かめ**：次のどれかが合わなければ拒否する。
  - バイト列とmanifest
  - `PRAGMA integrity_check`
  - DB自身のschemaの版・世代・改訂と、manifest
- **復元**：確かめたbackupから、新しいファイルへ写す。
  - backupのバイト列とmanifestは1回だけ読み、確かめたバイト列をメモリ（`deserialize`）に固定して、それを写す。確かめたあとでファイルが差し替えられたり消されたりしても、確かめていないバイト列が入ることはなく、`lineage`が指すhashとも食い違わない。
  - 新しい世代を発行し、元の世代・改訂・backupのhashを`lineage`に記録する。
  - 古い操作の記録は、照会できるように残す。
  - 古い世代の要求と、新しい世代の同じ操作IDは、再実行しない（`OperationFromEarlierGeneration`）。
- **書込は閉じたまま始まる**：backupは、その後に発行した番号を含まないことがある。そのため、復元したhighwaterが安全だとは言わない。
  - 書込を開けるのは、明示的な`enable_writes(conn, actor, evidence, issued_through)`だけ。
    - `issued_through`は、すべてのprefixについて、highwaterを下げない値でなければならない。
    - 呼んだ人・根拠・値を`lineage`に記録する。
  - 自動では開けない。ファイルを開き直しても閉じたまま。

### OPS-164の限界と、決まっていないこと

- **決まっていないこと**：
  - 本当の復旧で、`issued_through`（最後に発行した番号の境界）を誰がどこから得るか。
    - 試験`test_the_api_cannot_know_the_real_boundary`が示すこと：backupのhighwaterのまま開けると、backupの後に元のDBで発行された`TASK-007`が、別の仕事として再び発行される。
  - 新しい世代で、前の世代と同じ操作IDを使ったら拒否するのか。この実験では一律に拒否する。名前空間を分けるかどうかは決めていない。
- **manifestには署名がない**。ページの中身だけを変え、manifestもそれに合わせて作り直したものは、`integrity_check`では見抜けない。見抜けるのは構造の壊れだけ。
- 1つのプロセスの中の、Pythonから呼ぶ契約の試験だけ。保存の期間、保管の場所、実際の運用での復旧手順は扱わない。

## OPS-165：Studioとの隔離接続（`studio_adapter.py`・`studio_harness.cjs`）

**これは関数harnessで、ブラウザでの確かめではない。** 本物のStudioの関数を、読むだけの`index.template.html`から名前で切り出し、stubのDOMを付けてnodeのvmで動かす。原本のtemplate・sync・serve・Inboxは変えない。

- **export**（`export_doc`）：範囲はall。focusは`milestoneHead`として保つ。
  - `source`は`{kind: 'v3-export', generation, revision, payloadHash, payloadHashOf}`。
    - `source.sha256`は作らない。旧来の意味（Registryのファイル）に新しい意味を入れないため。
    - `payloadHash`は、何のhashかを明示した別の値。
  - `raw`は`''`。行番号と引用はない。どちらも`v3.absent`で明示する。空の値は互換のためで、出典があるという主張ではない。
  - マイルストーンの状態は、focusから表示用に導く（`v3.derived`）。カードには`recordedDone`も付ける。
  - 版のパス（`gate`）は表示用（`v3.displayOnly`）。編集の根拠にはしない。
  - 退役したタスクは`tasks`に入れず、`v3.retired`に挙げる。それにつながる辺は`v3.hiddenEdges`に挙げる。
- **harness**（`edit`・`resume`）：
  - `edit`：
    1. ページと同じ手順で読み込む（`check`・`initializeRelationBaseline`）。
    2. 本物の編集欄（`editorViewModel`・`drawEditor`・`editorAct`）で、担当と状態を変えて適用する。
    3. 保存ボタンと同じ形の保存JSONをファイルに書く。
  - `resume`：保存JSONを読み戻し、bannerと三者比較（`canonicalDifferences`・`editsReflected`）を出す。三者は、保存の基準・保存・最新のexport。
  - **互換のための変更**。harnessの中だけで行い、それぞれ切り出したソースにちょうど1回だけ当たることを確かめる。結果にも毎回、一覧を出す。
    - P1 `check()`：`source.kind`が`v3-export`で、世代と整数の改訂があるときに限って、`sha256`なしを受け入れる。
    - P2 `banner()`：DBの世代・改訂・payloadHashを出す。Gitの「コミット済み版」「未コミット差分」は出さない。
    - P3 `banner()`：基準の比較を、世代と改訂で行う。
  - **まねたもの**：
    - M1 保存の中身：保存ボタンの処理は名前のない矢印関数なので、切り出さずにまねた。
    - M2 読み込みの手順
  - **試していないもの**：serve.pyの`/save`とInbox（`source.sha256`を要求するので、V3のexportは拒否される）、HTTPでの再開、ブラウザ。
  - 原本のtemplateがV3のexportをそのまま受け入れる、とは主張しない。原本の`check()`は拒否する（試験で確かめた）。
- **適用**（`plan_save`・`apply_save`）：
  - 1回の保存で、1つのタスクのstateとownerだけを適用する。2つの欄は、既存の`apply`の1つのトランザクションで適用する。
  - 書く前に、保存全体を拒否する場合。部分的な反映は作らない。
    - 旧い保存（V3の基準がないもの）
    - 世代の違い
    - 2つ以上のタスク
    - ほかの欄
    - タスクの集合の変化
    - 辺・到達点の接続・計画・提案の変化
  - 操作IDは保存のバイト列から作る。同じ保存をもう一度適用すると、前の結果を返す。
  - **閉じる側に倒す**（受入での補正、2026-10-19）：
    - exportの基準には、比べるすべての欄（tasks・edges・milestoneRelations・milestones・milestoneHead）を入れる。
    - 保存か基準に欄が1つでも欠けていれば、形式の誤りとして拒否する。基準に欄がないことを「変わっていない」とは見なさない。
    - IDや関係の重複は、まとめずに拒否する。
    - 知らない欄は拒否する。
    - `source`と`v3`の世代・改訂は一致しなければならない。改訂は整数で、DBより新しくてはならない。
    - focus（`milestoneHead`）の変更は、未対応として拒否する。

### OPS-165の限界

- 関数harnessだけ。実際のブラウザ・サーバー・Inboxでは確かめていない。
- 旧い保存は拒否するだけ。manifestによる移行はしていない。
- 範囲currentでの境界のstub、計画・接続・提案の書込はない。
- 版のパスは表示用に作ったもので、ファイルは存在しない。

## OPS-166：隔離HTTP・headlessブラウザでの往復（`v3_studio_server.py`・`browser_roundtrip.cjs`）

- **エンジン**：導入済みのPlaywright 1.64.1（`/opt/homebrew/lib/node_modules/playwright`）のWebKit 2370を、headlessで使う。何も新しく導入しない。PythonのPlaywrightはないので、ブラウザの操作はnodeのスクリプトで行う。
- **server**（`V3StudioServer`）：
  - `127.0.0.1`に、OSが割り当てたportで立てる。状態はすべて試験の`TemporaryDirectory`に置く（fixtureのDB、`saves/`）。
  - 試験が起動し、失敗したときも`addCleanup`で止める。serve.py・sync.py・inbox.pyは使わず、templateは読むだけ。
  - `GET /`：ページを、templateを読んだものからメモリ上で作る。
    - seedは、その時点の`export_doc`。そのため、開き直すと最新のDBが見える。
    - 文書の束と採番待ちのqueueは空にする。
    - 互換のための変更P1〜P3を当てる。
  - `POST /save`：ページ自身の保存。`saves/`に、新しいファイルとして保存するだけ。**DBには書かない**。V3でない文書は拒否する。
  - `GET /workspace`：最新の保存を返す。ページ自身の`resumeWorkspace()`が、そのまま動く。
  - `POST /v3/apply`：DBに書く唯一の経路。試験が明示的に呼ぶ。
  - `GET /v3/latest`：最新のexport。
  - それ以外はすべて404。`/sync`は404なので、「更新」と「正本から始める」は何もできない。
- **送る前に遮る**：`context.route('**/*')`で、隔離したoriginでないリクエストは送る前に`abort`し、記録する。
  - 否定対照として、`http://blocked.invalid/`へのfetchが送られずに失敗することを確かめた。
  - 本番の8088には、どの段階でも接続しない。
  - ページが送ったリクエストと、serverが受けたリクエストの両方を記録し、決まった一覧の中に収まることを確かめる。
- **互換のための変更**：OPS-165のP1・P2・P3の3つだけ。メモリ上のページに当て、それぞれちょうど1回だけ当たることを確かめる。新しい変更はない。
  - URLは変えていない。隔離したserverが、自分で`/save`と`/workspace`を返すため。
  - 採番待ちのqueueは、`entries: []`の空のqueueとして渡した。これは変更ではなく、seedの中身。
- **試験**（`test_browser_roundtrip.py`、7件）：
  - 往復：実際の編集欄で担当と状態を変える→保存する（DBは変わらない）→新しい文脈で開き直す（ページ自身が再開し、値と基準の表示が保たれる）→明示的に適用する→もう一度適用すると前の結果を返す。
  - 別の欄の変更：bannerに「DBが更新されています」、通知に競合なしの行。
  - 同じ欄の競合：通知に「【競合の可能性あり】」が出て、適用は拒否される。
  - 世代の変更：拒否する。
  - UIでの未対応の混在した編集：拒否する。
  - 遮断の否定対照
  - 受けたpathの一覧と、P1〜P3が当たっていること
- **証拠**：`evidence/ops166/`（`reopen.png`と`roundtrip.json`）。`OPS166_EVIDENCE=<dir>`を付けて往復の試験を走らせると、保存される。

### OPS-166の限界

- WebKitだけ。作業の区域（活動・連絡・承認）、文書の表示、server状態の取得は404か空にしている。
  - そのためページの上に「サーバーの更新状態を確認できない旧バージョンです」と出るが、これは本番の文言で、この実験では意味がない。
- Inbox、IMPORTS、複数のタブにまたがる系列の扱いは、parent/branchedの最小限だけ。
- 保存したときの報告の文（「AIに『Inboxを取り込んで』と…」）は、本番の文言のまま。
- 実際のフォントでの見た目は、画像1枚で確かめただけ。

## OPS-168：複数タスクの変更群（`studio_adapter.plan_groups`・`apply_groups`）

- **群**：変わったタスクごとに1つの群（`task:<ID>`）を作る。そのタスクのstateとownerの変更は、1つの操作でまとめて反映する。片方の欄だけが反映されることはない。
- **選んだ群だけを適用する**：`apply_groups(conn, save, selected, actor, evidence)`。
  - 操作IDは`save:<saveId>:<groupId>`。`saveId`は保存したときに付いたもので、ないと拒否する。
  - 同じIDで中身が違う要求は`changedContent`として拒否し、何も書かない。
  - 結果は次のどれか1つに分ける：`applied`・`alreadyReflected`・`replayed`・`conflict`・`refused`・`changedContent`・`unselected`。
  - `complete`が真になるのは、すべての群が適用されたか、反映済みか、再送で同じ結果を返したときだけ。そうでなければ、保存全体を反映済みとは扱わない。
- **保存全体を拒否する場合**（そのまま残している）：旧い保存・形式の誤り・世代の違い・重複・知らない欄・構造や提案や計画やfocusの変更が混ざったもの。
- 選択が不正な場合（知らない群、重複）と、変更がない場合は、書く前に拒否する。
- 1タスクずつの経路（`plan_save`・`apply_save`）と、ブラウザでの試験は、そのまま残している。
- **採用していないこと**：OPS-167の発行の記録（journal）案。正しい形のまま末尾だけが切れたものは、hashの連鎖だけでは見抜けない。また、古いけれど互いに矛盾しない2つの写しは、最新であることの証明にならない。この問題は未解決のまま残し、K3は実装していない。

## OPS-169：構造の更新（K2、`registry_v3_write.py`の`STRUCTURAL`）

- **操作**：
  - `remove_edge`：progressかmanagementの辺を消す。
  - `set_edge`：progressの辺のflowと条件文を変える。
  - `rewire_edge`：辺をつなぎ替える。消すことと足すことを、1つの操作で行う。
  - `add_milestone_link`・`remove_milestone_link`・`set_milestone_link`・`rewire_milestone_link`：到達点への接続を足す・消す・変える・つなぎ替える。
  - `set_task_group`：タスクの区分を変える。
- **共通**：
  - どの操作も、頼りにする今の値（`base`）を示す。対象がない、または値が違えば、競合として拒否する。
  - `base`は厳密に確かめる（受入での補正）。欠けている・一部だけ・知らない欄がある・形が違うものは、何かを変える前に拒否する。
    - 消す操作とつなぎ替える操作：progressは`{flow, constraint}`のすべて、到達点の接続は`{constraint}`。managementは明示した`{}`。
    - 値を設定する操作：変える欄とちょうど同じ欄（区分は`{group}`）。
  - 値を設定する操作は、残る辺や接続を扱うので、端点が退役していないことを求める。消す操作は、片付けとして、退役した端点のものも消せる。
  - 変更したあとの構造で、次のことを確かめる。端点があり種類が合うこと、新しい端点が退役していないこと、重複がないこと、循環がないこと。循環は、managementと、progress・接続・骨格を合わせたものとで、別々に確かめる。
  - 途中で失敗したら、全体を取り消す。試験では、消してから足すまでの間（`between`）に失敗を入れて確かめた。
  - 同じIDでの再送は前の結果を返す。前と後を記録する。
- **条件文**：新しい辺や接続には、明示した条件文が要る。`conditionReview`は保存しない。古い条件文を黙って引き継がない。条件文をDBに保存することは、その文を承認したという意味ではない。
- **正本に根拠がある拒否**：版ゲートと結ぶ接続（どちらの向きも）。
- **この実験で対応していないもの**（正式に禁じたのではなく、OPS-167で決めることが残っている）：
  - 接続の向きのうち、END→タスクとタスク→STARTなど、`LINK_SUPPORTED`の外にあるもの
  - `reparent`
  - `set_task_permanent`
  - managementの辺に、親を1つに限る制約は足していない。今のモデルのまま。
- 版とカードの構造の更新、発行の記録（journal）、Studioの保存からの構造の群の扱い、本番への接続は行っていない。

## OPS-170：保存の構造変更群（`plan_groups`・`apply_groups`の拡張）

- **保存に残るもの**：辺にはIDがなく、つなぎ替えは配列の同じ位置を上書きする。そのとき古い条件文が残り、`conditionReview`が付く。削除すると位置がずれる。そのため、保存の前と後の差分だけでは、つなぎ替えを確定しない。
- **群**：
  - `edge-remove:` / `link-remove:`：基準の値をすべて付けて消す。同じグラフに追加がなければ、すぐ適用できる（ready）。
  - `edge-add:` / `link-add:`：いつも相談待ち（consultation）。保存しただけでは`conditionReview`を解かない。
  - 同じグラフに削除と追加が混ざると、両方とも対応の確認待ち（pairing）になる。追加だけを選んでも適用しない。
- **解決**（`resolutions`）：
  - `{"standalone": {groupId: {...}}}`：単独の削除は`{}`。単独の追加は、相談で決めた`constraint`と`evidence`を付ける。
  - `{"pairs": [{remove, add, constraint, evidence}]}`：削除1つと追加1つを、同じグラフの1つの`rewire:<graph>:<old>=><new>`にする。原子的なつなぎ替えになり、両方を使い切る。
  - 次のものは、書く前に拒否する：知らない群、同じ側を2回使うこと、グラフをまたぐ対、形の違い、空の条件文や根拠、対の片側だけを選ぶこと。
- **使い切りの安定**：操作の要求に`consumes`を入れ、同じ保存の以前の操作（成功も拒否も）から、どの差分を使ったかを読む。
  - 対を適用したあとに、その片側を単独で使うことはできない。別の相手と対にし直すこともできない。単独で適用したあとに、対にすることもできない。いずれも、閉じる側に倒して拒否する。
  - 解決の中身も要求に入るので、同じIDで解決を変えると`changedContent`になる。
  - **強制するのは書込のトランザクションの中**（受入での補正）。`registry_v3_write.apply`が、`BEGIN IMMEDIATE`の中で`consumption_claims`（scopeと差分と操作）を確かめる。
    - ほかの操作が使い切った差分を求める操作は、`ConsumedElsewhere`として拒否して記録する。この操作は差分を使い切らない。
    - 拒否された操作も、それが求めた差分を使い切る。
    - adapterの事前の確かめは、早く分かりやすい知らせを出すためだけに残す。
    - 2つの接続を決まった順に交互させる試験で、確かめた。
  - 操作IDは`save:<%で逃がしたsaveId>:<unitId>`。`%`・`_`・`:`を含む別々のsaveIdが混ざらない。SQLのLIKEは使わない。
- **順序**：削除、つなぎ替え、追加、タスクの順に1つずつ適用する。これは決まった順序であって、群が独立だという保証ではない。群をまたぐ原子性は扱わない。一部だけが成功した結果も、そのまま返す。
- **1タスクずつの経路**（`plan_save`）は、今までどおり構造の変更を拒否する。
- 試験のharnessに`remove`と`rewire`の操作を足した（M3）。関係のdialogの「適用」と「除去」の行を、DOMを作らずに直接呼ぶ。
- 版・カード・計画、提案の採番、親子のUI、恒久の区分、本番への接続は扱っていない。
