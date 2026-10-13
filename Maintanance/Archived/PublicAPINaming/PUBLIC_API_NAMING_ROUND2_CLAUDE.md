# Public API naming deliberative score — Claude, round 2

Status: Claude round-2 deliberative scoring completed 2026-10-13 (Claude Opus 5.5) after reading all round-1 scores, the score report, and the decisions record.

This round is deliberately not independent. Read the complete round-1 score records, the integrated
score report, and the adopted decisions before scoring. Score only the unresolved scopes below from
1 through 10. Record how the visible disagreement or another participant's reason affected the result.

| Candidate ID | Candidate | Round-1 Claude | Round-2 Claude | Deliberative reason |
| --- | --- | ---: | ---: | --- |
| `BO-01` | `BareElements` | 4 | 5 | Userの相対首位を見て1点上げた。採用済みの`element`語彙とも揃う。複数形の型名と「Bare」の未説明という懸念は残る |
| `BO-02` | `ElementBuffer` | 6 | 7 | Codexの理由（値semanticsを約束しない所有storage）に加え、採用済みの`element(at:)`／`setElement`と語彙が揃う点を重く見て1点上げた。固定shapeと`~Copyable`は名前に出ない |
| `BO-03` | `FixedShapeElements` | 4 | 4 | 維持。不変条件は正確だが、1Dで「Shape」が重く日常のcall siteに長い |
| `BO-04` | `BareArray` | 7 | 6 | 1点下げた。Userが4で現行名に執着がないと読めたため、移行費用ゼロの利点を前ほど重く見ない。`Array`の値semantics連想は全員の懸念として残る |
| `BO-05` | `FixedArray` | 5 | 4 | 1点下げた。Userも4で、`InlineArray`との混同という懸念を上回る利点が見えない |
| `BO-06` | `HeapArray` | 3 | 2 | 1点下げた。Userの1と、全員が役割より置き場所を名前にしている点を懸念したことを反映 |
| `PO-01` | `OptionalCache` | 4 | 5 | Userの相対首位を見て1点上げた。主用途の表明として理解できる。ただし「Cache」がpolicy（自動計算・追い出し）を約束しうる懸念は維持 |
| `PO-02` | `OptionalElementBuffer` | 5 | 6 | BO-02を上げたのに合わせて1点上げた。Userも4で、PO節では高い側。「Optional」がbuffer全体にかかって読める文法の懸念は残る |
| `PO-03` | `OptionalFixedShapeElements` | 3 | 3 | 維持。長すぎる |
| `PO-04` | `OptionalArray` | 6 | 4 | 2点下げた。Userの1と、全員が`Array<Element?>`と同一視される懸念を挙げたことを重く見た。User scoreでは「Array」を含むPO候補がすべて1で、presence-tracked familyに「Array」を使うこと自体が避けられているように読める（Userへの確認事項） |
| `PO-05` | `FixedOptionalArray` | 3 | 3 | 維持。上と同じく「Array」を含み、文法も曖昧 |
| `PO-06` | `HeapOptionalArray` | 2 | 2 | 維持 |
| `PO-07` | `SlotArray` | 6 | 4 | 2点下げた。状態modelの正確さは変わらないが、Userの1（「Array」を含む候補の一律1と同じ傾向）と、疎なstorageを連想させる懸念を合わせて見直した |
| `PO-08` | `MemoTable` | 6 | 5 | 1点下げた。Userは`MemoTable`に1、`MemoizationTable`に3で、用途名そのものより略語を避けているのかもしれない（未確認）。用途を狭める懸念は維持 |
| `PO-09` | `PresenceBuffer` | 5 | 4 | 1点下げた。Codexの8が示す表現の正確さは認めるが、Userの1と、要素を格納する型であることが読みにくい点を重く見た |
| `PO-10` | `MemoizationTable` | 5 | 5 | 維持。Userの3はPO節で2番目に高く、用途を明示しつつ「Cache」ほどpolicyを約束しない。長さの懸念は残る |
| `BR-01` | `reference` | 7 | 7 | 維持。採用済みの`MutableRef`（Ref）と自然に対応し、短く、現行のtestと例に定着している。Userは3案すべて5で差を付けていない |
| `BR-02` | `mutableElement` | 6 | 6 | 維持。可変であることは返り値の型名`MutableRef`がすでに示すので、method名で繰り返す利点が前ほど大きくない |
| `BR-03` | `elementReference` | 5 | 6 | 1点上げた。Codexの「copied accessと参照の射影を分ける」という理由が、採用済みの`element(at:)`／`setElement`と並べたときに効く（element / setElement / elementReference）。可変と寿命は名前に出ない |
| `RP-01` | `pointee` | 5 | 6 | 1点上げた。Codexの理由（参照としてのaccessを正しく示す）に加え、`MutableRef.pointee`は`UnsafeMutablePointer.pointee`と同じく、copyではなくstorageの射影だと読める。unsafe寄りの響きは残る |
| `RP-02` | `value` | 5 | 4 | 1点下げた。copied accessの語彙で`value`が退けられ`element`が採用されたので、ここで`value`を「copyではない参照先」の意味に使うと、同じ語が退けた意味と逆の意味で現れて混乱しうる |
