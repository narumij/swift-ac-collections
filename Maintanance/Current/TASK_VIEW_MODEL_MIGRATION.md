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

## 姫の結果（区切り2：近傍とホバーのVM、2026-10-19）

2026-10-19 姫・Opus 5.5。依頼は連絡DBの`LTR-20261019-B3FF8B6BD1114E09859180DD6D617615`（v1を読んで受領）。返答もその連絡に記録する。区切り3・4（編集欄・配線）には触れていない。ユーザーの画面・実サーバー・実DB・AGENTS.mdには触れていない。commitなし。

### 変更（`index.template.html`：`7aa08935…`→`e99382ee…2fcc880b`）

- **`neighborhoodViewModel({data, center, expanded, measure, documentPaths})`**（純粋）を作った。
  - 中身：局所の見取り図のSVGのVM（`drawSvgSpec`の木）、見出し、中心の本文、3つの欄（前提・後続・展開した先）の行。
  - 行は、矢印・種類と条件・相手・「ここを中心に」と「この先を展開」を出せるかを持つ。
  - **ホバー**：カードと線の全文はSVGの`title`で、VMに入っている。依存図のホバーの説明（`graphTip`の文字）は、区切り1から既にVMにある（`intent.tip`）。ホバーを出すかどうかの切り替え（`graphHoverEnabled`）は、ホバーの時点でViewが読むUIの状態のまま。
  - 文字の幅は注入する（`measure`。nullなら、既存の文字数による見積もり）。
  - 大域の`doc`は読まない。データを変えない。
- **`drawNeighborhood(box, count, vm, intents)`**：描くことと、意図を返すことだけ。意図は`select`・`documents`・`reset`・`center`・`expand`。見取り図の中心を横方向に寄せるscrollは、Viewが行う。
- **`renderNeighborhood`**：中心がまだなければ、選んでいるものを中心にする（今までどおりのUIの状態）。VMを作ってViewへ渡し、意図を既存の動作（中心の変更、展開、1段に戻す、選択、文書を開く）に結ぶ。
- **変えていないもの**：配置、選択の共有、展開と折りたたみ、ホバーの切り替え、未確定の入力（編集欄は区切り3）。

### 試験と証拠

- **新しい`test-task-view-model-neighbor.cjs`**（`f7960f56…ffc2202d`）：
  - **互換のbaseline**：`task-view-model-neighbor.baseline.json`（`8746193b…ff4992ac`）。抽出の前のコードから、stubのDOM・文字数の見積もり・匿名のfixture bで取得した7つの場面をそのまま比べる。7つの場面は次のとおり。
    - 線の多いタスク
    - 展開して先が増える場面（6ノード・5本）
    - マイルストーンが中心
    - 文書のあるタスク
    - 線のない追加案
    - 中心が未設定で、選んでいるものになる
    - 未知の中心
  - **VMの契約**：
    - データを変えない
    - 中心の強調と「· 中心」
    - カードと線のホバーの全文
    - 純粋
    - 注入した幅で折り返しが変わる
    - 欄の構成、展開した相手は「中心に」だけを出す
    - 文書のリンクの有無（追加案にはない）
    - 未知の中心
    - 大域の`doc`を変えてもVMは同じ
  - **固定VM→DOM**：要素の並び、空の欄は「ありません。」、意図（カードのクリックとEnter、文書、1段に戻す、中心に、展開）だけを返すこと、空のVM。Viewのソースが、導出の関数と大域の状態を参照しないこと。
- **否定対照**（一時コピー）：VMで大域の`doc`を読む、1段に戻すの意図を取り違える、ホバーの全文を短くする。どれも落ちた。
- **そのほか**：`sync.py`（verify.cjsを含む）は成功。`node test-*.cjs`は`test-usability-cards.cjs`を除いてPASS（下）。
- **隔離headless**（WebKit、`file://`、fixture b、証拠は`/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/tmp.bSHhJ4Gfmp/`）：
  - 依存図のノードを選び、「接続を見る」→2ノード・1本
  - 「この先を展開」→4ノード・3本
  - 「ここを中心に」→中心がMS-VALIDATIONに
  - 1段に戻す、カードのクリックで選択
  - ページのエラーは0件

### 止まっている点（許可が要る）

**`test-usability-cards.cjs`の22・23行が落ちる**：
- この試験は、ソースの文字列そのものを確かめている。`svg('title',{},n.id+' '+(t.item||''))`と`g.onclick=()=>select(n.id);`。
- 守っている中身（カードの全文のtitle、カードのクリックで選ぶこと）は保たれている。baselineの一致と、上の契約・DOMの試験で確かめた。抽出によってコードの形が変わったため、文字列が一致しなくなった。
- 依頼の占有には、usability系の試験が入っていない。前の区切りでも「変更が要るなら、先に対象を返す」とされた。だから、この2行は直していない。
- 直す案：2行を、新しい形の同じ意味の確かめに置き換える。全文のtitleは`{tag:'title',attrs:{},text:n.id+' '+(t.item||'')}`、クリックは`node.onclick=()=>intents.select(intent.id)`。許可があれば直す。

### 追補：usability試験の2行を振る舞いの確認に置き換えた（2026-10-19）

依頼は`LTR-20261019-1F6F5C08FC414F36915C9E9CE99F3993`（v1を読んで受領）。占有の範囲は`test-usability-cards.cjs`のこの2つの確認だけ。

- **`test-usability-cards.cjs`**（`be702c9f…`→`0d9a4d96…972448d8`）：文字列の一致による2つの確認を、振る舞いの確認に置き換えた。
  - 方法：fixture bから、線のある、題名が2行の幅を超えるタスクを選ぶ。`neighborhoodViewModel`から`drawNeighborhood`までをstubのDOMで描く。
  - 確かめること：そのタスクのカードの`title`が全文（`id + ' ' + item`）であること。カードの`onclick`が、そのidで`select`の意図を返すこと。
  - ほかの確認（2行の題名、16文字で切っていないこと、計画の編集欄）は変えていない。
- **否定対照**（一時コピー）：カードのtitleを`.slice(0,16)`で切ると「full title in the card」で落ちる。`select`の意図を捨てると「clicking a local-map card still selects it」で落ちる。
- **実行**：`node test-usability-cards.cjs`、`node test-task-view-model-neighbor.cjs`、`node test-*.cjs`はすべてPASS。`sync.py`（verifyを含む）は成功。製品コード・実サーバー・実DBには触れていない。commitなし。
- これで、上の「止まっている点」は解消した。


## 区切り2技術受入（2026-10-19 Astra）

独立評価で明示入力VM・大域doc非依存・入力非変更・固定VM描画と各intentを確認。近傍7場面baseline/契約/DOMとmaps試験PASS。Astraも近傍試験と更新後usability試験を再実行PASS。旧文字列検査2件は実際の全文title/クリック意図の検査へ更新し、製品機能の追加はなし。区切り2を受入、区切り3/4は未完了。

## 姫の結果（区切り3：編集欄のVMと操作の意図、2026-10-19）

2026-10-19 姫・Opus 5.5。依頼は連絡DBの`LTR-20261019-501C47221C1349CFB5FA85B790765E7F`（v1を読んで受領）。基準は`9ebf2bddb`。区切り4（共通の配線）には触れていない。ユーザーの画面・実サーバー・実DB・AGENTS.mdには触れていない。commitなし。

### 変更（`index.template.html`：`e99382ee…2fcc880b`→`63e9d8b4…34263706`、変更前の写しは`/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/tmp.VNnkxn08nL/ops154s3/`）

- **`editorViewModel({data, graph, selected})`**（純粋）。`milestonePlanBlocks(data, t)`と`proposalBlocks(data, t)`を使う。
  - 返すもの：タスクの選択欄（IDの数値順、title）、見出し、欄の並び（`text`・`documents`・`details`・`buttons`・`button`・`edge`・`row`・`field`）。
  - 欄は、種類・選択肢・初期値・ENDの選択肢の「（→ GATE-…）」の表示を持つ。打つと`formDirty`になる欄かどうか（`typing`）も持つ。
  - 意図は対象をIDで指す。読む欄も`read`として持つ（例：`{type:'applyTask', id, read:{state:'state', owner:'owner'}}`）。
  - 削除の意図に渡す関係は写しで、Modelの物ではない。
  - マイルストーンの行は、描いた線（`graph.edges`）から作る。`linkLabel`と`isMilestoneLink`には`data`を渡す。
- **`drawEditor(box, title, picker, vm, act)`**（View）：描くことと、意図を返すことだけ。
  - 押したとき、その意図が読む欄のDOMの値を集めて`act(intent, values)`を呼ぶ。
  - 欄は既存の`field`・`options`で作る。打つ欄だけが`formDirty`を立てる（今までどおり）。
- **`editorAct(intent, values)`**（プレゼンター）：既存の関数で、IDを指してModelを変える。
  - 使う関数：`removeRelation`・`check`・`addMilestoneRelation`・`planEditText`・`planReorder`・`planMove`・`updateProposal`・`removeProposal`・`addProposalEdge`・`select`・`showNeighborhood`。
  - 変えていないもの：ガード（「先に入力の『変更を適用』を…」）・確認の文・エラーの報告・`dirty`と`formDirty`の扱い・選択の変化。
  - 「変更を適用」は、`doc.tasks`のIDの物を変える（前は、`graphData()`のノードを通して同じ物を変えていた）。
- **`editor()`**：VMを作ってViewに渡す。**`formDirty`の間は描き直さない**。
- **振る舞いの変更（依頼の「版の変更でも入力を保つ」に当たる、1点）**：
  - 前は、版の選択の`onchange`が`render()`を呼び、編集欄を作り直していたので、打っている途中の値が消えていた。区切り0のbaselineでも`inputRetention.afterVersionChange`は元の値だった。
  - 今は打った値が残る。`render()`が`formDirty`のまま呼ばれるのは、この経路だけ。
  - 破棄する経路では、先に`formDirty=false`にしてから描き直すので、今までどおり描き直される。破棄する経路は、選択のconfirm・ファイルを開く・正本から始める・適用・取消。
- **変えていないもの**：保存と再開の契約、「更新」の拒否の条件、30秒の確認（バナーだけ）、`beforeunload`、計画の編集欄、連絡の画面とほかの画面、`verify.cjs`の切り出しの区間。

### 試験と証拠

- **新しい`test-task-view-model-editor.cjs`**（`2420a161…dc66c549`）：
  - **互換のbaseline**：`task-view-model-editor.baseline.json`（`731c252c…e6bbc98a`）。変更前の写しから、stubのDOMと匿名のfixture bで取得した。同じ写しから2回取ってバイト単位で一致した。
    - 11の選択について、編集欄・見出し・選択欄のDOM。
    - 28の操作について、操作のあとのModel（JSON）・`delta()`・選択・`dirty`/`formDirty`・confirmと報告と描き直しの記録・編集欄のDOM。
    - 操作の内訳：状態と担当の適用、前提の追加・重複・入力中の拒否、前提の削除（はい・いいえ）、到達点へ・2回目の拒否、マイルストーンを前提に、STARTから、到達点の削除、接続を見る、選択欄（入力中にいいえ）、計画の名前・空の拒否・前へ・後への端・版の移動・入力中の拒否、追加案の適用・取消（はい・いいえ）・前提・後続・マイルストーンの後・到達点とその削除・入力中の拒否。
  - **入力の保持**：打つ→描き直しの要求（版の変更と同じ`render()`）→値が残り、Modelは変わらない→適用でModelに入る→選択のガードで破棄すると、新しい選択が描かれる。
  - **VMの契約**：
    - 入力を変えない。同じ入力からは同じVM。大域の`doc`と`selected`を変えてもVMは同じ。
    - 選択欄の順。打つ欄は`state`と`owner`だけ。欄の並び。
    - 意図がIDを指すこと、削除の関係が写しであること、到達点の3つの向き、ENDの選択肢の表示。
    - 計画のカード（前へ/後へ・移動・打つ欄）、版ゲートに欄がないこと、追加案（前提・後続の読む欄、マイルストーンの向き）、未知の選択と選択なし。
  - **固定VM→DOM**：要素の並び、欄の値と選択肢の表示、打つ欄だけの`oninput`。返すのは意図と、その意図が読む値だけ（選択欄も含む）。見出しなしなら見出しを残すこと。Viewのソースが`doc`・`graphData`・`formDirty`・`selected`を読まないこと。
- **試験を先に書いた証拠**：変更前の写し（`STUDIO_TEMPLATE=/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/tmp.VNnkxn08nL/ops154s3/index.template.html`）では、baselineは一致し、入力の保持の確かめで落ちる（typed value survives a redraw request while formDirty）。
- **否定対照**（一時コピー）。どれも落ちた。
  - `formDirty`の間も描き直す→入力の保持の確かめで落ちる。
  - VMが大域の`doc`を読む→「reads only its inputs」で落ちる。
  - 適用の対象を`doc.tasks[0]`にする→baselineの「apply state and owner / editor」で落ちる。
  - Viewが欄の値を渡さない→baselineの操作が途中でTypeErrorになって落ちる（到達点への接続ができず、削除する行がないため）。
- **そのほか**：`node test-*.cjs`はすべてPASS。`sync.py`（verifyを含む）は成功。既存の試験で、編集欄のソースの文字列を確かめているものはなかったので、既存の試験は変えていない。
- **隔離headless**（WebKit、`file://`、fixture b、証拠は`/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/tmp.uX7SMXJtlp/`の`check.cjs`・`results.json`・`editor.png`）：
  - RELEASE-076の担当に打つ。地図のタブの往復・カードの並び・版の変更（「全体」）・「更新」の押下（`file://`の注意だけが出る）のあとも、「入力中の値」が残った。
  - 適用で変更が1→2件。前提の追加で3件。追加案と計画のカードの表示。「前へ」で5件。
  - ページのエラーは0件。
- **区切り0の地図のbaseline**（`task-view-model-capture.cjs`と`check`、a・b）：変更の前後の生成ページで、記録した段はa・bとも完全に一致した。違うのは`inputRetention.afterVersionChange`だけで、元の値から「入力中の値」に変わった（上の振る舞いの変更）。
  - なお、保存されている`task-view-model-maps.baseline.json`との比較では、変更の前の写しでも16か所が違っていた。たとえばbの段6・7のgraph・permanentMap・cardList。これは区切り3より前からある違いで、調べておらず、直してもいない。baselineのファイルは占有の外なので、変えていない。取得物は`/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/tmp.uX7SMXJtlp/before-*.json`と`cap-*.json`。

### 限界と、決めてほしい点

- **確かめられなかったこと**：
  - stubのDOMの`select.value`は、ブラウザの挙動を簡単にまねたもの。実際の挙動はheadlessで一部を確かめた。
  - 実際のフォントでの見た目は見ていない（画像は1枚）。
  - httpでの「更新」と再開の経路は、試験サーバーを起動していないので、実行していない。コードは変えていない。
- **決めてほしい点（新しい方針の問い）**：
  - 版の変更のあとも入力を保つため、`formDirty`の間は、編集欄の選択欄（`taskPicker`）も描き直さない。今は、版の変更で選択欄の中身が変わることはないので、表示は同じ。
  - 将来、`formDirty`のままModelが変わる経路を足すなら、その経路で入力を残すか破棄するかを決める必要がある。
- **区切り0のbaseline**：`afterVersionChange`を「入力中の値」として取り直すのか、上の16か所と合わせて扱うのかは、Astraに任せる。


## 区切り3技術受入・V3開始条件充足（2026-10-19 Astra）

Astraのeditor試験と独立評価で11表示/28操作、純粋VM・固定VM描画・IDによる更新・未確定入力保持を確認。関連maps/近傍試験もPASS。変更前後の地図取得物の差は入力保持の意図した改善だけで、区切り3を受入。OPS159の開始条件を満たした。

将来のModel更新と未確定入力の扱いは将来の変更時に決めるもので、現行の新しいユーザー判断は不要。保存baselineとの既存16差分は区切り3の回帰ではない。盲目的に再生成せず、OPS154残り区切り4の確認事項として残す。HTTP更新/再開の実試験と共通配線も残り、OPS154全体はACTIVEを維持する。
