# タスク画面のViewModel化

## TL;DR（人間向け）
見取り図・独立タスク・カード一覧・編集状態も、表示状態を作る処理と描画を分ける。既存レイアウト、選択共有、入力中の内容、保存・更新・破棄の契約を維持し、試験と独立評価まで行う。新機能追加や全面書換えではない。

OPS-154 / ACTIVE / 2026-10-19。ユーザーが作業側VM化の対象外説明に対し「そっちもすすめて」と明示依頼。基準commit `5149327f5d4573b0568a255fc8b8e03e016150ea`。親OPS048。commitは別承認。

## 境界

Modelの正本/編集版/選択/UI入力からVMを導出し、ViewはDOM/SVGと操作意図を担当。既存のgraphLayout、independentGroups、cardListGroups、neighborhood等を活かす。変更履歴や保存契約を独自に再定義しない。入力配送/編集操作→Model、Model→VM、VM→View/操作を分ける。レイアウトと未保存データ保持は互換baselineと要求fixtureを併用。

## 姫への第1正式依頼 H-20261019-16

まず限定調査・作業内訳だけを返す。index.template.htmlのタスク経路と対応試験、既存保存契約を必要範囲で読み、最小VM境界と3〜5区切り、対象ファイル、試験/終了条件、壊しやすい境界を具体化する。作業側VMの受入経験（特に実配線と入力固定）を用いるが、別画面へ無理に同じ構造を押し付けない。ユーザーは段階実装・試験まで承認済みなので、合意後は区切りごとの割当で進む。

占有：本書の姫第1返却欄＋本人activity/continuityのみ。コード/Registry/他正本/commit/実サーバー再起動/ユーザー画面操作なし。返却後連続待機。実装は次の明示割当から。

## 姫第1返却

2026-10-19 姫・Opus 5.5。読んだのは、基準`5149327f`以降の作業版の`index.template.html`のタスク経路（`render`・`select`・`graphData`・`graph`・`independent`・`renderCards`・`renderNeighborhood`・`editor`系・保存と再開の周辺）と、それを試す`verify.cjs`・`test-usability-*.cjs`・`test-tooltip-scroll.cjs`。読んだだけで、何も変えていない。

### 現状（作業側との違い）

- **状態は大域変数に散らばっている**：`doc`（編集版）、`selected`、`dirty`、`formDirty`、`workspace`（保存の系列）、`planDraft`、`neighborCenter`と`neighborExpanded`、`graphZoom`。
- **DOMが状態を持っているもの**がある：版の選択（`versionPicker`）、カードの並び（`cardOrder`）、ホバーの有無（`graphHoverEnabled`）、編集中の入力欄の値。
- **`render()`が全部を作り直す**：入力の変化（入力欄の`input`で`formDirty=true`、752行）と選択のガード（`select`のconfirm）が、入力中の内容を守っている。
- **導出の多くは、すでに純粋**：`graphLayout`、`independentGroups(data)`、`cardListGroups`、`neighborhood`、`neighborhoodLayout`、`permanentMapData`、`versionView`、計画の`plan*`、`addProposal`など。ただし次の2つは違う。
  - `graphData()`と`delta()`は、大域の`doc`を読む。
  - `graph()`の中で、配置・線の経路・文字の折り返し（canvasの`measureText`）・SVGの組み立て・操作の結び付けが一体になっている。
- **作業側と違って、外からのsnapshotの配送はほとんどない**。入力は、ユーザーの編集操作・選択・タブと、保存と再開の結果、30秒ごとの正本更新の提案の確認（バナーだけを変える）。だから、作業側の「ソースごとの世代」をそのまま持ち込む必要はない。ModelはModelの編集版とUIの入力、という形で足りる。

### 最小のVM境界

- **Model**：`doc`（編集版。保存の契約が読むもの）、`selected`、`dirty`・`formDirty`、UIの入力（地図のタブ・版の選択・カードの並び・ホバー・拡大率・近傍の中心と展開・`planDraft`）。保存と再開の`workspace`は、今のまま別に扱う（VMは読むだけ）。
- **VM（純粋）**：`taskScreenViewModel(model, measure)`。中身は次のとおり。
  - `graph`：ノードの位置・折り返した行・状態の帯・選択・正本へのリンク、線の経路、注記の文字
  - `independent`：独立タスクの一覧
  - `cards`：カード一覧のグループ
  - `permanent`：恒久タスクの地図
  - `neighborhood`：近傍の表示
  - `editor`：選んだものの種類、欄と選択肢、前提・到達点などの行

  文字の幅を測る関数`measure`は注入する（`neighborMeasure`と同じ扱い）。
- **View**：DOMとSVGの組み立て、スクロールと拡大率の適用、ホバーの表示。操作は意図として返すだけにする（選ぶ、適用する、前提を足す、つなぐ、など）。意図を受けたプレゼンターは、既存の純粋な変更関数（`addMilestoneRelation`・`plan*`・`addProposal`・`updateProposal`など）で`doc`を更新する。変更の履歴と保存の契約は、新しく決め直さない。

### 段階（事前固定と4区切り）

0. **事前固定**
   - 内容：タスク画面の表示を保存する。固定の匿名fixture（既存の`completed-document-layout-fixture.json`と、合成の小さい編集版）を使う。
   - 方法：生成した`index.html`を、隔離headlessのWebKitで開く。`measureText`は文字数に比例する決定的な関数に差し替え、TZとロケールも固定する。各タブ（依存図・恒久・保護・カード・近傍）と編集欄のDOMとSVGを、選択の列に沿って記録する。
   - 入力保持のfixture：入力欄に打つ→30秒の確認と同じ処理を起こす→値が残っている。
   - 終了条件：同じ機械で2回取って一致すること。
1. **地図のVM**（依存図・独立・恒久・カード）
   - 内容：`graph()`から配置・経路・折り返しを`graphViewModel(data, ui, measure)`へ、ボタンの文字・title・aria・選択を各一覧のVMへ移す。Viewは描くだけにする。
   - 対象：`index.template.html`、新しい`test-task-view-model-maps.cjs`、baseline
   - 終了条件：baselineが一致する。固定VM→SVG・DOMが一致する。`verify.cjs`がPASSする。
2. **近傍と、ホバーの文字のVM**
   - 内容：もともと純粋な部分が多い。文字の折り返しだけを注入する`measure`へ寄せる。
   - 終了条件：同上。近傍の展開と中心の入れ替えの意図の試験。
3. **編集欄のVMと操作の意図**（いちばん壊れやすい）
   - 内容：欄の構成・選択肢・行をVMから作る。押下は意図として返し、プレゼンターが既存の関数で`doc`を変える。
   - **入力中の値は、Modelではなくその場のDOMに残る**（今と同じ）。`formDirty`の間は、編集欄を作り直さない形を保つ。
   - 終了条件：入力保持のfixture、適用・取消・前提の追加・到達点の接続・計画の並べ替えと移動の結果が、前と同じ`doc`になる（`delta()`を比較する）。

4. **配線**：`render()`を、VMを1回作って各Viewへ配る形にする。タブ・版・並び・拡大率をUIの入力にする。

### 壊しやすい境界

1. **`verify.cjs`が、関数名の並びで切り出している**。`function graphData(`から`function graphLayout(`まで、`graphLayout`から`independentGroups`まで、`independentGroups`から`function independent(){`まで、`permanentMapData`から`function permanentMap(){`まで、`check`から`el`まで、`delta`から`banner`まで。この間に新しい関数を入れたり順を変えたりすると、verifyが壊れる。新しい関数は、これらの区間の外に置くか、区間内に置くなら自己完結させる。`verify.cjs`を直す必要が出たら、占有の追加を先にお願いする。
2. **その場での書き換えと参照の共有**：編集欄の適用（`t[k]=$(k).value`）は、`graphData()`が返すノードを直接変える。このノードは`doc.tasks`の同じオブジェクト。VMがコピーを返すと、編集が失われる。意図は「IDでModelを変える」にそろえ、VMの物を変えさせない。
3. **入力中の内容と`formDirty`**：今は入力欄のDOMが値を持つ。VM化で編集欄を作り直す時機が変わると、入力が消える。区切り0の入力保持fixtureを、全区切りの門にする。
4. **保存と再開の契約**：`workspace`の系列・head、`editsReflected`、`canonicalDifferences`、正本更新の提案、`beforeunload`は変えない。VMは`dirty`と提案の状態を読むだけ。
5. **文字の幅を測ること**：canvasのフォントに依存する。注入しないと、試験とbaselineが機械ごとに変わる。
6. **DOMが持つUIの状態**：版の選択の選択肢の作り直しの条件（`options.length`の比較）、拡大率の適用の順番、スクロールの保持。

### コストと限界

- 作業側より大きい。特に`graph()`（40行ほどの密なコード）と`editor()`。
- 区切り1（地図）と3（編集欄）が重い。2（近傍）は軽い。
- 今の試験は、`verify.cjs`が純粋関数を、usability系が一部の関数を見ているだけで、タスク画面のDOMの試験はほとんどない。区切り0のheadlessのbaselineが、互換性の主な証拠になる。
- headlessのbaselineは、文字の幅を差し替えたうえでの互換性で、実際のフォントでの見た目は、別に画像で確認が要る。
- 新しいframeworkは要らない。

**ユーザーに決めてもらう点**：なし。占有の確認だけある。どの区切りでも`verify.cjs`の切り出しに触れる必要が出たときは、占有の追加が要る（上の1）。


## Astra照合・H-20261019-17（事前固定と区切り1）

第1返却を受領。作業側の配送方式は流用せず、編集版＋UI入力を明示化する案に合意。未確定の入力文字はDOM保持のままでもよいが、formDirty中の再描画抑止と適用時のID解決を必須契約にする。VM値の参照をModelとして直接変更しない。全体配線は区切り4で一度deriveし同一revisionを対象Viewへ配る。

姫へ：0事前固定と1地図VM（依存図・独立・恒久・カード一覧）を実施。小さい匿名fixture/既存layoutfixtureの基準表示と入力保持を先に保存し、再取得2回一致。固定measure/TZ/localeのbaselineと意味契約fixtureを区別。graphData等の表示データ化を行い、VM→SVG/DOMの固定入力試験、選択共有の意図を確認。編集/保存の動作変更はしない。

占有：index.template.html、新規test-task-view-model-maps.cjsと必要な匿名fixture/baseline/隔離検証スクリプト、本書H17返却欄。verify.cjsは既存検査の意味を維持する切出し依存の最小修正に限り占有追加を許可（削除で通さず振る舞いassert維持）。既存test-tooltip-scroll/usability系は読取、変更必要なら対象を先に返す。生成syncは可。実サーバー/ユーザー画面なし、隔離headlessは可、Inboxと通信POSTは隔離/模擬。

返却は対象とhash、baseline条件、契約ケース、互換差/未確認を分ける。区切り2以降へ進まず返却後連続待機。commitなし。

## 姫H-20261019-17返却（事前固定と区切り1：地図VM）

2026-10-19 姫・Opus 5.5。事前固定と区切り1だけを行った。区切り2以降には進んでいない。commitなし。実サーバーとユーザーの画面には触れていない。

### 対象とhash（SHA-256、先頭8桁…末尾8桁）

- `index.template.html`：`704d18fa…`（基準`5149327f`と同じ）→`792180ed…4be12d63`
- 新規：
  - `test-task-view-model-maps.cjs`（`59d35b3d…1c43768c`）
  - `task-view-model-capture.cjs`（隔離での取得、`5ffd84f1…29d39155`）
  - `task-view-model-baseline.cjs`（digestの作成と照合、`0b5755f0…6727135d`）
  - `task-view-model-fixtures.py`（fixtureの作成、`0bc95454…c5c69a95`）
  - `task-view-model-fixture-b.json`（匿名、`91b32f6b…c9f17896`）
  - `task-view-model-maps.baseline.json`（`1069fa61…34c2294e`）
- `verify.cjs`：変更なし（`40dad763…`）。関数名で切り出す区間に影響しない置き場所にした。新しい純粋関数は区間の外か、宣言だけを区間の中に置いた。
- 既存の`test-tooltip-scroll`・usability系：変更なし。両者がソースの文字列で確かめている箇所（`function show(t,x,y){if(!$('graphHoverEnabled').checked)…`、縦線の`d:x===u?…`）は、同じ文字列のまま残した。
- 変更前の写し：`/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/tmp.I2dIB4mGYk/template-before-stage1.html`。受入まで残す。

### baselineの条件（互換の証拠）

- **取得の方法**：生成した`index.html`の写しのseedをfixtureに差し替え、`file://`で開く（通信の経路はすべて無効）。
- **固定したもの**：
  - WebKit、画面の大きさ1400×900
  - `TZ=UTC`、ロケール`ja-JP`
  - `measureText`は1文字7pxに差し替え
  - `confirm`は常にOK
- **fixture**：
  - a：既存の`completed-document-layout-fixture.json`。退役した`relation`だけを外して、今の形式にした。文字は変えていない。
  - b：今のRegistryの構造（ID・状態・依存・マイルストーン・ゲート・親子・恒久）だけを残し、文字をすべて同じくらいの長さの置き換えにした匿名版に、追加案を1件足したもの。
- **記録した段**（aは7段、bは8段）：
  - 読み込み
  - 版「全体」、bは版0.5.3も
  - 依存図のノードを選択、ホバーの説明
  - カードをID順
  - カードの選択
  - 独立タスクの選択
- **記録した部分**：依存図、独立、恒久、カード一覧の各HTMLのSHA-256と長さ、件数、版の選択肢と値、選択中の見出し、説明の文字。
- **入力保持**：編集欄に打つ→地図のタブを往復→カードの並びを変える→版を変える、の各時点の値。
- **繰り返しの一致**：同じ機械で2回取って一致した（a・bとも）。
- **ファイルの扱い**：baselineはdigestだけ（23KB）。全文の取得は`/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/tmp.I2dIB4mGYk/cap-*.json`。
- **限界**：実際のフォントは測っていない。保護タブと近傍タブは対象外。これは「前と同じ出力」の証拠で、正しさの証明ではない。

### 区切り1の変更

- **共通**：
  - `wrapLines`：純粋な折り返し。依存図と恒久で同じ手順だったものを1つにした。
  - `drawSvgSpec`：SVGのVMを、順序どおりに組み立てる描画器。`action`は「押せるまとまり」の共通の扱い（tabindex・role・aria・cursor・title、EnterとSpaceはクリック）で、意図を描画側の受け手へ渡す。
- **依存図**：`graphViewModel({data, version, selected, measure, hasDocuments})`（純粋）を作った。中身は、配置、版でのしぼり込み、線のない版、線の経路、注記、ノードの強調・帯・折り返し・説明の文字、正本へのリンク。
  - `edgeEntryOffsets`は、OPS-126のコメントと字下げのまま、この中に置いた（usability-finalの切り出しの印を保つ）。
  - `graph()`は、版の選択肢の同期（DOMが持つUIの状態）、文字の幅の計測、描画、意図から既存の操作への変換（`select`・`editRelation`・`openTaskDocuments`・説明の表示と隠し）だけを受け持つ。
- **独立タスク**：`independentViewModel`（純粋）。class・見出し・文字・状態・title・正本の有無を作る。
- **カード一覧**：`cardListViewModel`（純粋）。空のグループの除外、件数つきの見出し、各カードのclass・見出し・文字・正本の道筋を作る。
- **恒久タスク**：`permanentMapViewModel`（純粋）。図全体をSVGのVMとして作り、意図は「選ぶ」「タスクの正本」「1つの文書」の3つ。
- **Modelを変えない**：VMは、データの物を参照するだけで変えない（試験で、前後のdeep比較をした）。意図は描いた辺とノードそのものを運ぶが、変更は既存の操作関数が`doc`に対して行う。編集・保存・選択の動作は変えていない。

### 確認した契約のケース（`test-task-view-model-maps.cjs`、挙げたもので網羅ではない）

- `wrapLines`：幅の限界、行数、収まる省略記号
- **依存図**：
  - 導出でデータが変わらないこと
  - 選択だけが強調され、マイルストーンは別の色になること
  - 線の意図は描いた辺そのものと見える線を運び、経路が同じであること
  - 正本へのリンクは、正本があるタスクだけに付くこと
  - 各ノードが説明の文字を持つこと
  - 純粋（同じ入力から同じVM）
  - 版でしぼったときの注記
- **独立タスク**：件数、選択のclass、追加案の見出し・説明・正本なし、空のとき
- **カード一覧**：件数、空のグループを出さないこと、件数つきの見出し、選択、マイルストーンの印
- **恒久タスク**：件数、意図の種類、選択の太線
- **選択の共有**：同じ選択のIDが、依存図・恒久・カードのVMのどれでも強調されること
- **固定VM→SVGと意図**：
  - 描く順序と属性
  - `action`が子のあとにtabindex・role・label・cursor・titleを付けること
  - 単純な意図は描くときに受け手へ渡り、`action`はクリックとEnterで意図を返し、ほかのキーでは何もしないこと
- **ソース検査**：4つのViewが、配置・版でのしぼり込み・折り返し・色の決定をしていないこと

### 検証

- baselineの照合：変更後のページで、a・bとも全段が一致した（`task-view-model-baseline.cjs check`）。
- 否定対照：一時コピーで選択の色を1文字変えると、契約の試験と、baselineの照合（8件の差）の両方で落ちた。
- `node test-*.cjs`：20本すべてPASS。`sync.py`（`verify.cjs`を含む）は成功、`--check`はずれなし、`git diff --check`は問題なし。
- 取得のときのページのエラーは0件。

### 見つかったこと（直していない、互換差ではない）

- **入力保持**（Astraの必須の契約との食い違い）：編集欄に打ったあとで版の選択を変えると、`render()`が編集欄を作り直し、確定していない値が消える（今の動作。baselineの`inputRetention.afterVersionChange`に記録した）。地図のタブの往復とカードの並びの変更では、値は残る。
- 「formDirtyの間は再描画しない」は、区切り3（編集欄）か区切り4（配線）で入れる必要がある。今回は、編集の動作を変えない指示に従って、手を付けていない。

### 未確認

- 実際のフォントでの見た目、狭い画面の幅。
- 保護タブと近傍タブ（区切り2の対象）。
- 実サーバーでの表示。
- Python側の試験。

## H17受入保留・限定補正 H-20261019-20

独立評価[ROUND1](Evidence/OPS-154/ROUND1.md)の2件を実装側・通常（本区切り受入前に補正）として採用。互換baselineは保存し、次の2点を補正してください。

- graphViewModelからversionView/isMilestoneLink/linkLabelを辿っても大域docへ依存しないよう、必要な版/接続情報を明示入力にする。同じ引数で大域docだけ変えても同じVMになる試験を追加。
- 独立/カード一覧のViewはVMのdocuments・状態装飾を忠実に使い、helper内部で再判定しない。固定VMの文書フラグや色を変えた場合にそのままDOMへ出る試験を追加。クリック後の編集はModel側で行う。

占有はindex.template.html、test-task-view-model-maps.cjsと必要最小のbaseline照合脚本、自身返却欄。既存見た目/操作・保存契約維持。版変更時の未確定入力消失は既存の残件として区切り3/4で直す（今は広げない）。隔離試験のみ、実サーバー/ユーザー画面/commitなし。返却後連続待機。

## 姫H-20261019-20返却（地図VMの限定補正2件）

2026-10-19 姫・Opus 5.5。ROUND1の2件だけを直した。見た目・操作・保存の契約は変えていない。commitなし。実サーバーとユーザーの画面には触れていない。

1. **依存図VMの大域`doc`への依存をなくした**：
   - `graphViewModel`に、明示の入力`source`（描いた元の編集版。マイルストーンとHEADを持つ）を足した。
   - `versionView(data, v, source)`・`versionFolders(source)`・`linkLabel(e, data)`は、この`source`を受け取る。既定値は今までどおり`doc`なので、`verify.cjs`とページの他の呼び出しは変わらない。
   - ページは`graph()`から`source:doc`を渡す。
   - 試験：同じ引数のまま、大域の`doc`だけを別のもの（HEADを`9.9.9`、マイルストーンを空）に替えて、版「全体」「@head」「先頭の版」の3通りでVMが完全に同じになること。
   - 否定対照：一時コピーで`versionView`のHEADを大域`doc`に戻すと、「@head」で落ちた。
2. **独立タスクとカード一覧のViewの忠実性**：
   - VMの各項目に、状態の帯`band`（`{text, bg, fg}`、`stateBandModel`）を足した。
   - 描画を`drawIndependent(strip, count, vm, intents)`と`drawCardList(box, count, vm, intents)`に分け、文書の有無（`documents`・`paths`）と帯の色を、渡されたとおりに描くようにした。帯は`bandView(band)`で描き、色を決めない。
   - クリックとリンクは、意図（`select`・`openDocuments`・`openDocument`、複数の文書の選択）として返すだけ。編集はModelの側（既存の`select`など）で行う。
   - 独立タスクは`cardWithDocuments`を使わなくなった。同じDOM（`task-shell`と、`正本`のリンク）を、VMから直接作る。`cardWithDocuments`は、保護タブ（区切り外）で今も使っている。
   - 試験（固定のVM→DOM）：
     - 文書の印があれば、文書の道筋がなくてもリンクが出る。印がなければ出ない。
     - 帯の文字・背景・色が、渡したまま出る。
     - クリックとリンクが意図だけを返す。
     - カード一覧で、文書が複数あれば選択が意図になる。
     - ソース検査：2つのViewが`stateStyle`・`stateBand`・`taskDocumentPaths`・`cardDocumentPaths`・`cardWithDocuments`を使わないこと。
   - 否定対照：一時コピーで、帯を`stateBand(c.state)`に戻すと色の検査で、リンクの条件を`c.node.detail`に替えると文書の印の検査で、それぞれ落ちた。

**検証**：
- `node test-*.cjs`：20本すべてPASS。`sync.py`（`verify.cjs`を含む、`verify.cjs`は無変更）は成功、`--check`はずれなし、`git diff --check`は問題なし。
- 互換のbaseline：補正後のページを隔離で取り直した（`/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/tmp.I2dIB4mGYk/h20-*.json`）。a・bとも全段が一致した。

**hash**：
- `index.template.html`：`792180ed…`→下の値
- `test-task-view-model-maps.cjs`：更新
- `task-view-model-maps.baseline.json`：変更なし（`1069fa61…`）

**残件**：版を変えると確定していない入力が消える件は、区切り3・4で扱う（広げていない）。
- `Maintanance/RegistryApp/index.template.html`：`440f70b4…8712144a`
- `Maintanance/RegistryApp/test-task-view-model-maps.cjs`：`5a76bf7a…5cb5e191`

## 区切り0/1技術受入（2026-10-19 Astra調整）

H20と独立ROUND2を照合し、地図VM区切りを受入。明示sourceで大域doc変更の影響を除去、独立/カードViewがVMの文書情報と帯を描くことを確認。baseline互換証拠と契約試験を区別する。既知の版変更時未確定入力消失・近傍・編集・共通配線は残り2〜4で対処、OPS154はACTIVEを維持。実サーバー/実フォント/狭幅未確認。
