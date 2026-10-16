# 候補CIの比較元が「前回のrelease tag」だったことによる移行の穴

2026-10-16夜 / Claude（姫）/ 未採番 `CP-20261016-015`。ユーザー「CIの移行ミスってる線でも調査ひつようかもな」「その線でまだ調べる余地あるなら、しらべてもらって」による。
読み取り調査だけで、workflow・Benchmarks・製品は変更していない。RELEASE-083（停止原因）・RELEASE-084（停止報告）の続き。

## 結論

性能CI変更ガイドの段階手順（workloadの実装を先にmerge → そのmerge commitを以後のbaselineにする → CI libraryへ登録）は、比較元が`main`（PRのbase）である通常CIを前提にしていた。
候補CI（`candidate.yml`）の比較元は「候補HEADに含まれる最新のx.y.z tag」で、0.5.3以後リリースがないため、10-12〜10-13のbaselineの切替がどれも候補CIには届いていない。
これが、RELEASE-083の8件欠落と、RELEASE-084で見つけたPermutationの契約差の共通の根である。候補CIの性能比較は、作られてから一度も成功した記録がない。

## 経緯（git履歴から）

| 日時 | commit | 出来事 | 候補CIへの影響 |
| --- | --- | --- | --- |
| 10-10 01:06 | `139ffef8` | 0.5.3 tag | 候補CIの比較元になる |
| 10-10 15:20 | `67cbc78e` | `candidate.yml`を新設。比較元＝最新release tag、候補の`CI.json`を比較元へコピー | 規則はこの時点から同じ |
| 10-12 | PR #189 `32b65d5f`、#190 `f7d1de2d` | ElementBuffer/OptionalElementBuffer（当時BareArray/OptionalArray）のworkload実装、通常CIへの登録 | 通常CIはbase＝mainなので緑。0.5.3にはworkloadがない |
| 10-12 | `9ff515c9` | Permutationをruntime-check付きViewへ切替 | 0.5.3とは比較の契約が変わる |
| 10-13 | PR #191 `34bcf2df`、#193 `1f531c23` | ガイドは#191のmergeを「以後のruntime-check版baseline」と定めた | 通常CIの話。候補CIの比較元は0.5.3のまま |
| 10-13 | `0bee6467`、`0330e7b5` | task名renameの互換処理を、通常CIと候補CIの両方に追加 | 比較元が「旧名のworkloadを持っている」ことを前提にしている。0.5.3は旧名のworkload自体を持たない |
| 10-16 00:34 | `2d32f71c` | PRコメント（`/test release`）で候補CIを起動できるようにした | 初回run 38765855176で「Run baseline benchmarks」がexit 1（RELEASE-080） |
| 10-16 | — | RELEASE-080はユーザーの「解決済み」でEXCLUDED（原因は未確定のまま） | — |
| 10-16夜 | run 38906685897 | 同じstepで再び失敗。RELEASE-083で8件のunknown tasksと特定 | — |

## 判断の材料（事実）

- **RELEASE-080の失敗は、同じ原因だった可能性が高い（推定）。** 失敗したstepが同じで、そのときも`CI.json`の8件と0.5.3の関係は同じだった。ただし、そのrunのログは見ていない。
- **赤黒木の18件は、比較の契約が同じと考えてよい。** 0.5.3からの製品コードの差は、範囲`erase(_:where:)`のpredicateエラー伝播（`31aa2f07`）だけ（RELEASE-081）。CIの測定にrangeのeraseは含まれない。`_RedBlackTreeModule`は差分0。
- ガイドの「benchmark task名のrename境界」の節は「PRおよびrelease candidateのperformance workflow」と書き、候補CIも視野に入れていた。ただし、比較元が旧名のworkloadを持つ前提で、比較元にworkloadがない場合や、実装の契約が変わった場合は扱っていない。

## 次に決めること（提案。決めるのはユーザー・Astra）

1. 候補CIの比較元の規則。案は3つ。
   - 最新release tagのままにする（0.6.0を出せば次からは成立する。今回の0.6.0の判定だけを例外として扱う）。
   - 比較元を`main`にする。
   - 比較元を明示した固定baselineにする。
2. ガイドの段階手順に「候補CIの比較元へも届いたか」の確認を足すか。
3. 0.6.0の候補判定では、RELEASE-084の3案（例外として明示／参考表示／比較を判定に使わない）と、赤のままmergeする案のどれを採るか。

## 未確認

- 各runのログの実物（どちらも403、`gh`なし）。
- 候補CIのtag経路（`candidate-*` tagのpush）の過去run。保存記録は見つからなかった。
