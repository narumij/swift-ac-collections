# OPS-076 追記のうち判断にはみ出した記述の再検証（入力版 `1175e583b1857819e9e0b07b83a1cb5fc8be657a`）

2026-10-17 / 姫（Opus 5.5）。ユーザー直接依頼「判断にはみだすと、それって依存が何層かあるはずなので、判断抽出したものについて再検証と、全体の再送をおねがいしたい」。OPS-076はDONEなので、本作業は未採番（CP-20261017-016）。

範囲：OPS-076第1〜4区切りで姫が書いた追記・Return・ROUND2/3のうち、事実照合を越えて判断に触れた記述。抽出方法は2つ。

- 追記節を「判断・変わらない・有効・足りる・結論・成立・意味しない・想定どおり」でgrepした。
- Return・ROUND3を読み直した。

各記述について、その判断が乗っている事実（依存の層）を固定treeで確かめ直した。元の追記・Return・証拠は書き換えていない。この表が訂正の記録になる。

結果の凡例：

- 支持：依存の事実が版で成り立つ。成立範囲は表に書いたところまで
- 範囲限定：支持されるのは一部だけ
- 取り下げ：根拠がないか、言いすぎ

## 一覧

| # | 記述（場所） | 種類 | 依存の層（下ほど根っこ） | 再検証の結果（版） | 判定 |
| --- | --- | --- | --- | --- | --- |
| J1 | 「`Benchmarks/QualityAssessment/`の差分は測定コードではないので結論に影響しない」（`RELEASE_CANDIDATE_BASELINE_FIX.md`追記156行） | 影響の見積もり | 結論「旧例外修正が不要」←比較元と候補の測定コードが同じ←CIの比較は`Benchmarks/Sources`・`Libraries`だけを使い、`QualityAssessment/`を参照しない | workflow全ファイルに`QualityAssessment`の参照なし。測定コード・製品の差分なしは第1区切りでAstraが独立確認済み | 支持（CI定義の範囲で。ローカルの手動計測の手順は見ていない） |
| J2 | 「結論を揺らす更新条件は新しい数値版tag、その1行を見れば足りる」（本書第1区切りReturn） | 十分性の主張 | tag←ref集合（commitで固定されない）。workflow・コードの変更も結論を揺らす | Astraの第1区切り受入で補正済み | 取り下げ（受入時の補正どおり） |
| J3 | 「事実は古くなったが、実装の判断は変わらない」（`REGISTRY_STUDIO_MILESTONE_CONNECT.md`追記） | 影響の見積もり | 版ゲート拒否の判断←拒否の実装が残る←`index.html`→`index.template.html`の改名で中身が保たれた | `bbddb7ff3`の改名前後の差分は3行の追加・3行の削除だけ。版の`index.template.html` 336行に拒否文言、341行に`addMilestoneRelation` | 支持（版ゲートへの接続拒否という判断に限る。その後のテンプレートの変更全体は見ていない） |
| J4 | 「条件明記の判断は変わらない」（`REGISTRY_STUDIO_SINGLE_LINE_KIND.md`追記） | 影響の見積もり | 全行に条件を明記←28行すべてが規定の書き出しで始まる | 28行とも3つの書き出しのいずれか（第2区切りで確認、表は版331〜360行） | 範囲限定（書き出しの規則を守っていることまで。条件文の中身が正しいかは判断していない） |
| J5 | 「方針（書き戻しなし・状態の正本はRegistry）はこの変化で変わっていない」（`TASK_REGISTRY_APP_PROTOTYPE.md`追記） | 影響の見積もり | 方針←サーバー型でもRegistryへ書かない←`serve.py`のPOSTと`sync.py`の書き込み先 | `serve.py`のPOSTは`/sync`だけで、固定の`sync.py`を実行する。`sync.py`が書くのは`APP`（既定`Maintanance/Cache/RegistryStudio`）の`registry.json`・`index.html`と`local-tools.json`だけで、Registryは読むだけ | 支持（版のコードの範囲で。環境変数`REGISTRY_STUDIO_APP`で出力先は変えられる） |
| J6 | 「差分があるのは想定どおりで、照合の無効を意味しない」（`RED_BLACK_TREE_OUTLINE_AUDIT.md`追記） | 解釈 | 想定どおり←照合（`1dc613ff`）の後に本文を作り直した←commitの前後関係 | `1dc613ff`は差分を含む`c1f2c7f90`の祖先 | 範囲限定（前後関係は支持。「無効を意味しない」は推論をしないという宣言で、有効だと保証してはいない） |
| J7 | 「前半は通常CIに限れば成立」「推論の前提は変わっていない」（`ASAN_DEATH_TEST_INVESTIGATION.md`追記） | 解釈 | 後半の推論（Linuxの成功はmacOSを証明しない）←CIにmacOSのASan jobがない | ASanを含むworkflowは`ci.yml`・`candidate.yml`だけで、`runs-on`はすべて`ubuntu-24.04` | 支持（前提の事実まで。推論そのものの正しさは確かめていない） |
| J8 | 「修正案（旧パス）は今も有効」（`PROVISIONAL_AGREEMENT_JUDGMENT_INVENTORY_PILOT.md`追記） | 修正案の存続 | 修正案←監査が旧パスを現行の参照として挙げる←旧パスがなく、移動先がある | 監査本文64行は「Main sources」節（現行の残作業の参照）。`Sources/PermutationModule/`はなく、`Sources/NextPermutationModule/NextPermutations.swift`がある | 支持（修正するかどうかは文書の持ち主の判断） |
| J9 | 「再現結果は今も有効」「hashだけ見れば足りる」（ROUND3 #17、第3区切りReturn） | 結果の有効性 | 実装の同一性・呼出先・テスト・toolchain | Astraの第3区切り受入で補正。第4区切りで範囲を直した追記に置き換え済み | 取り下げ（受入時の補正どおり） |
| J10 | 「レビュー版から`Sources`差分なしの1行があれば、見直すべきかを差分だけで判断できる」（本書第2区切りReturnの観察） | 十分性の主張 | 目視レビューの有効性←ソースの同一性と表示環境（toolchain・DocC・ブラウザ） | 追記本文は「表示環境が変われば未確認に戻る」と書いているが、Returnの観察はそれより強い | 取り下げ（「差分があれば見直しが要ると分かる」まで。差分がなくても環境の変化で見直しが要る） |
| J11 | ROUND3 #14「追加は不要」 | 要否の判断 | OPS-074の追記がある（事実） | 追記・追記2・追記3は版にある | 範囲限定（追記があることまで。追加が要るかは判断していない） |
| J12 | ROUND3 #18「これに依存する判断なし」 | 不在の主張 | 依存する判断を全部探す必要がある | 探していない | 取り下げ（悪魔の証明。「依存は調べていない」に直す） |
| J13 | ROUND3 #31「根拠は返却側に置けば足りる」 | 置き場の見立て | — | 姫の見立てで、確かめていない | 範囲限定（分類の理由ではなく、姫の案として読む） |
| J14 | ROUND3 #26「ユーザー確定として扱う」 | 権限の判定 | 文書の状態 | 版の本文に「Status: current naming decisions are adopted」「The user makes the final public decision」とある | 支持（本文の記述まで。個々の名前をユーザーが確定した記録は照合していない） |
| J15 | 「補正1はOPS-074で閉じた」（`OPS_072_ACCEPTANCE.md`追記） | 状態の判定 | OPS-074の受入 | Registryの版でOPS-074はDONE、追加返却を受入済み | 支持 |

## 依存の先（他の記録への波及）

- 取り下げのJ2・J9は、Astraの受入時にすでに補正されている。Astraの受入の数（77件の内訳・候補12件）はJ11〜J13の言い換えでは変わらない（分類の区分は変わらないため）。
- J10は本書第2区切りReturnの観察だけで、追記本文はすでに範囲を限定しているので波及しない。
- J12は分類(2)の理由だけで、区分は変わらない。
- 範囲限定のJ4・J6・J11・J13は、元の記述を読む人が範囲を広げて受け取るおそれがある。元の記述は残し、この表を正とする。

## 再実行

```sh
S=1175e583b1857819e9e0b07b83a1cb5fc8be657a
for y in $(git ls-tree --name-only $S .github/workflows/); do git show $S:$y | grep -n 'QualityAssessment\|runs-on\|sanitize address'; done
git diff --stat bbddb7ff3^:Maintanance/RegistryApp/index.html bbddb7ff3:Maintanance/RegistryApp/index.template.html
git show $S:Maintanance/RegistryApp/serve.py | grep -n 'do_POST\|/sync\|sync.py'
git show $S:Maintanance/RegistryApp/sync.py | sed -n '18,24p'; git show $S:Maintanance/RegistryApp/sync.py | grep -n 'write_text'
git merge-base --is-ancestor 1dc613ff c1f2c7f90 && echo ancestor
git show $S:Maintanance/Current/EXTERNAL_TYPE_EXTENSION_AUDIT.md | sed -n '62,64p'; git ls-tree -r --name-only $S Sources | grep NextPermutations.swift
git show $S:Maintanance/Current/PUBLIC_API_NAMING_DECISIONS.md | sed -n '1,12p'
```

## 受入時の補正への入口

2026-10-17 Astra：本表は補正付き受入。[正本末尾の再送受入](../../CANONICAL_EVIDENCE_ROLLOUT.md)を併読する。特にJ1・J5の全面保証、J10の差分からの自動的な再レビュー要求は認定していない。原表は返却履歴として保持する。
