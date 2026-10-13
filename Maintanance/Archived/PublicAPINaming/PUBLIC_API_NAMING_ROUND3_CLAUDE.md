# Public API naming deliberative score — Claude, round 3

Status: Claude round-3 scoring completed 2026-10-13 (Claude Opus 5.5) after reading all round-2 records and the round-2 report.

Read all round-2 score records and `PUBLIC_API_NAMING_ROUND2_REPORT.md`. Score the five remaining
candidates from 1 through 10. For each, state what behavior or mental model the name promises and how
the round-2 user response affects the evaluation.

| Candidate ID | Candidate | Round-2 Claude | Round-3 Claude | What this name suggests or promises |
| --- | --- | ---: | ---: | --- |
| `PO-01` | `OptionalCache` | 5 | 5 | 約束: 結果を置いておく入れ物（cache）。読むと前の結果があれば返り、なければ空。読み手によっては、自動計算、容量上限、追い出し（eviction）といったpolicyまで期待しうるが、実装は固定slotに値を置くだけ。round-2でUserが中立の5を維持したので、主用途を短く示す価値は認めて据え置く。`ElementBuffer`採用で、family名の一貫性（Buffer）は得られない |
| `PO-02` | `OptionalElementBuffer` | 6 | 6 | 約束: `ElementBuffer`と同じ所有・固定寸法のstorageで、各要素が空でありうる。`element(at:)`が`Element?`を返す実装と、心のmodelが一番一致する。`ElementBuffer`の採用で一貫性の利点は具体的になったが、Userのround-2の「too long」は競技のcall siteで現実的な費用なので据え置く |
| `PO-10` | `MemoizationTable` | 5 | 5 | 約束: 動的計画法などのmemo化結果を座標で引く表。用途は明確だが、他の用途（未訪問判定など）を名前が排除し、`memoize`のような関数を提供するかのようにも読める。Userのround-2は「i dont know」の4で、拒否ではない。長さもあり据え置く |
| `RP-01` | `pointee` | 6 | 4 | 約束: pointerの参照先（`UnsafeMutablePointer.pointee`と同じ語）。copyではなくstorageへの射影だという点は正確だが、「pointerを扱っている」という低レベル・unsafeな心のmodelを伴う。Userがround-2で明示的に1（i dont like this）とし、安全な借用参照として見せたい型にpointerの語を持ち込む違和感を、AI側の精度の議論より重く見て2点下げた |
| `RP-02` | `value` | 4 | 6 | 約束: この参照が指す値。`ref.value += 1`は参照越しに書き換えると自然に読め、`MutableRef`という型名が「参照」であることを担うので、copyとの誤読は型の文脈でかなり抑えられる。round-2で私は「copied accessで退けた`value`を逆の意味で使うと混乱する」と下げたが、退けたのはownerのmethod `value(at:)`で、参照型のpropertyとは文脈が違うと考え直した。Userの5（優先）も踏まえて2点上げた |
