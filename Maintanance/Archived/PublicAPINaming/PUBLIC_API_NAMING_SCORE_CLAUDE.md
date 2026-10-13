# Public API naming score — Claude

Status: Claude independent scoring completed 2026-10-13 (Claude Opus 5.5). User and Codex scores were not read.

Copy the accepted candidate IDs and concise spellings from `PUBLIC_API_NAMING_BALLOT.md`. Claude
records a whole-number score from 1 through 10, its reason, and any material concern.

Do not read the User or Codex score records before submitting this score record.

Use role accuracy, call-site readability, family coherence, necessary distinction, migration cost,
promise accuracy, and Validation fitness as evaluation lenses. They are not separately summed.

| Candidate ID | Candidate | Claude score (1–10) | Reason | Material concern |
| --- | --- | --- | --- | --- |
| `BO-01` | `BareElements` | 4 | 所有する要素の集まりという役割は外していない。Arrayの値semanticsを約束しない点は良い | 型名が複数形で、`BareElements2D`のcall siteが不自然。「Bare」の意味は依然説明されない |
| `BO-02` | `ElementBuffer` | 6 | Collectionでも値型配列でもない、所有storageという役割に正確。family全体で次元suffixも素直につく | 「Buffer」は低レベル・unsafe寄りに読まれうる。shapeが固定であることは表さない |
| `BO-03` | `FixedShapeElements` | 4 | 固定shapeという一番の性質を正確に言う | 長く、1Dで「Shape」が重い。日常のcall siteで読みにくい |
| `BO-04` | `BareArray` | 7 | 移行費用ゼロ。BareArrayは製品除外で利用者も既存の競技利用に限られ、改名で得る理解の改善が費用に見合いにくい | `Array`が値semanticsとCollection適合を連想させる。「Bare」の意味は名前から読めない |
| `BO-05` | `FixedArray` | 5 | 伸縮しないことが伝わり短い | 標準の`InlineArray`や「fixed-size array」（型に要素数を持つinline storage）と混同されうる。こちらは実行時寸法・heap |
| `BO-06` | `HeapArray` | 3 | `InlineArray`との対比は付く | 置き場所という実装を名前にしており役割を表さない。`Array`もheapなので差になっていない |
| `PO-01` | `OptionalCache` | 4 | 主用途（メモ化）に寄せた短い名前 | 「Cache」は自動計算・追い出しなどのpolicyを約束するように読まれる。実装は値を置くだけ |
| `PO-02` | `OptionalElementBuffer` | 5 | BO-02と組にすると体系が揃う | 長い。「Optional」が要素ではなくbuffer全体にかかるように読める |
| `PO-03` | `OptionalFixedShapeElements` | 3 | 性質は正確 | 非常に長く、競技でのcall siteに向かない |
| `PO-04` | `OptionalArray` | 6 | 移行費用が小さく、各位置が空でありうることは伝わる | `Array<Optional<Element>>`と同一視されやすく、所有・固定長・`~Copyable`が伝わらない |
| `PO-05` | `FixedOptionalArray` | 3 | 伸縮しないことは伝わる | 「Fixed Optional」の文法が曖昧で長い。BO-05と同じ`InlineArray`混同もある |
| `PO-06` | `HeapOptionalArray` | 2 | — | 実装詳細が支配し、長い |
| `PO-07` | `SlotArray` | 6 | 各位置が空か1要素かという状態modelを短く正確に言う。主用途に縛られない | 「slot」はhash tableやobject pool、疎なstorageを連想させうる。実際は全slot分を密に確保する |
| `PO-08` | `MemoTable` | 6 | 主用途の配列メモ化に直結し、競技利用者に役割が伝わる | 用途を狭く見せる（未訪問判定など他の用途で名前が合わない）。memoization動作を約束するようにも読める |
| `PO-09` | `PresenceBuffer` | 5 | presence mapとpayloadを分けて持つ実装の状態modelに正確 | 見慣れない語で、要素を格納する型であることが名前から読みにくい |
| `PO-10` | `MemoizationTable` | 5 | 用途を明示し、Cacheほどpolicyを約束しない | 長い。用途を意図的に狭める点はPO-08と同じ |
| `DS-01` | Unsuffixed 1D for both families | 8 | 1Dを基本形、2D以上だけsuffixは`Array`の感覚に合い、最頻の1Dが短い。両familyで1つの規則になる | OptionalArray1Dの利用者に移行が要る（OptionalArrayは実験的traitなので費用は限定的） |
| `DS-02` | Explicit rank for every family | 5 | rankがどこでも見えて対称 | 最頻の1Dに常に`1D`が付き冗長。BareArrayの改名も要る |
| `DS-03` | Preserve current asymmetry | 3 | 移行費用ゼロ | 1つの規則で両familyの1D名を予測できない。今回揃える機会を逃す |
| `VA-01` | `element` / `setElement` | 8 | 格納された要素を読み書きすると明示し、両family・全次元で現行と同じ。Swiftのcollection語彙とも衝突しない | やや冗長 |
| `VA-02` | `value` / `setValue` | 5 | Collection適合を名乗らない中立な語 | 参照型要素では「value」がcopyを連想させ、要素の同一性や所有を弱く見せる。VA-01から変える利点が小さい |
| `BR-01` | `reference` | 7 | 短く、現行と同じ。`Reference`型との組で読める | 可変であること、借用で寿命を持つことは名前から読めない |
| `BR-02` | `mutableElement` | 6 | 1要素への可変accessであることを強調する | 返り値が参照的な型であることは名前から読めない。`MutableElementReference`とセットでないと冗長に見える |
| `BR-03` | `elementReference` | 5 | 参照の射影であることを明示 | 可変であることも寿命も表さず、BR-01より長いだけになりやすい |
| `RT-01` | `Reference` alias backed by `MutableRef` | 6 | owner型の文脈で短く読める | `Reference`と`MutableRef`の2つの公開名ができ、可変であることが別名に隠れる |
| `RT-02` | `MutableElementReference` | 4 | 可変な要素参照であることを完全に言う | 競技のcall siteには長い |
| `RT-03` | `MutableRef` directly | 7 | 公開名を1つにでき、別名の曖昧さがなくなる。可変であることも名前に残る | 略語「Ref」。借用寿命は名前に出ない |
| `RP-01` | `pointee` | 5 | owner storageへの射影でcopyではないことを、pointer由来の語で正直に表す | unsafe・実装寄りに聞こえ、安全な参照型の語としては違和感がある |
| `RP-02` | `value` | 5 | unsafeな響きがなく参照型らしい | copyした値と読まれやすく、owner storageを直接触っていることが伝わりにくい |
