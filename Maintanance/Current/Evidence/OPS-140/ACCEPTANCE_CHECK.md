# OPS-140 要約追加の本文不変性照合

2026-10-19 / Astra受入補助としてSolが実施。先頭部分の編集担当と同一Solによる再照合であり、別人・別モデルの独立レビューとは呼ばない。編集処理のoffset・挿入文を判定入力に使わず、保存原文と現在実体の差分を新たに計算する別方式で確認した。

## 結果

| 範囲 | 対象数 | 本文byte一致 | 要約1か所だけの追加 | 不一致 |
| --- | ---: | ---: | ---: | ---: |
| 先頭担当の追加分 | 36 | 36 | 36 | 0 |
| 後半担当の追加分 | 32 | 32 | 32 | 0 |
| 合計 | 68 | 68 | 68 | 0 |

全68件が、一か所に4行（見出し・空行・短い1段落・区切り空行）の挿入だけだった。原文行の削除・置換・並替えは検出されず、挿入部分を取り除いたbytesは変更前控えと完全一致した。対象正本は修正していない。

## 対象・方法

- 先頭：`/private/tmp/ops140-sol-validation.json` から追加36件のパスを取得。比較原文は `/private/tmp/ops140-sol-originals/<repo相対パス>`。記録のoffset・addition・body_identicalは今回の合否に使っていない。
- 後半：`/private/tmp/OPS-140-SOL-B-20261019/results.json` の区分「追加」から32件を取得。比較原文は同ディレクトリの `original/<repo相対パス>`。要約txt・apply.py・自己検証の結論は今回の合否に使っていない。
- 現在実体はrepository直下の各パスからread_bytesで読んだ。改行を保持して行へ分け、Python difflib.SequenceMatcher(autojunk=False)で原文と現在実体のopcodeを計算した。
- equal以外のopcodeが一件のinsertだけであることを確認し、insertのbytesがTL;DR見出しと1段落だけ（空白を除く2行、挿入全体4行）であることを確認した。空行は差分の対応位置が前後へ動き得るので、見出し判定時だけ先後空白を除外した。
- equal部分を現在実体から順に連結し、そのbytes全体を保存原文と直接比較した。hash一致だけの判定ではない。下表のhashは照合時の入力を識別するために併記した。

## 保証範囲

この照合が示すのは、保存控えに対する要約追加以外の本文不変性と、照合時の実体の同一性まで。要約の意味の妥当性・状態判断・編集権限・保存控えを作る以前の真正性を新たに認定しない。除外資料・既存要約・歴史資料のLuna追加分は今回の68件には含まない。stage・commit・対象正本の修正は行っていない。

## 照合明細

| 群/index | パス | 変更前SHA-256 | 照合時SHA-256 | 結果 |
| --- | --- | --- | --- | --- |
| A/1 | `Maintanance/Current/AI_COLLABORATION_BASIC_RESEARCH.md` | `c871223aedad108d0fe1af95f8522eacb3bf168386c3bae4a10fddf3ef1916f0` | `82d725e0116374c3dd988ddd8e0cb3d33c8c99cdb1b27eeee21ebb98a4626413` | 本文一致・要約のみ |
| A/2 | `Maintanance/Current/AI_RESEARCH_FIRST_EXPERIMENT.md` | `62a9799bd5485786294df84e4a475d80011bc324dc65fa05a7f8b18bc9cbdb8f` | `6e8085f506b090d4a92e6f24d3071dfc3f6ddae090ef99260adac2bc96b6267e` | 本文一致・要約のみ |
| A/3 | `Maintanance/Current/AI_RESEARCH_FIRST_EXPERIMENT_PREPARATION.md` | `4756c839e620850364468a2f15823c0f387122e829951efbc75aa6dba8f98e1c` | `593160189ab4bd377880b0b2870f4314eb95f114e5a5bddd5178bdd21c5ed5cd` | 本文一致・要約のみ |
| A/4 | `Maintanance/Current/APPROVAL_PROBE.md` | `400e30ac194ece51758c4ab578627afb4cf7b2ab052907d4eefd9adf9b1f173b` | `a4058dbbebc566f4662533843d4d209279882f5c182a4d78664425360e0bc4f0` | 本文一致・要約のみ |
| A/6 | `Maintanance/Current/CACHE_REFERENCE_OBSERVATION_PILOT.md` | `7964b42ce1ff36e1df03be5c8dcf88df3e49326c5421b1511c06f8a75b7a6b8a` | `c338f0f22ccad7b4d67a6301935f48c0edd0b6866e6a4d459ddf60da5f8b08bf` | 本文一致・要約のみ |
| A/7 | `Maintanance/Current/CACHE_SECOND_ITEM_PILOT.md` | `7a58385cdcaf2ea19dd564346c504266417ca533b388d1d8b85eabb78bca2abb` | `2bb2f0f1f0246b8c84c4f9650167ab1b7a788c516c0a74751f291db7d12acef1` | 本文一致・要約のみ |
| A/8 | `Maintanance/Current/CANONICAL_CONFIRMED_SCOPE_SUMMARY.md` | `0bb57bfe65f7e53171905da78e5fcc75edf0b9dea63f571e9ebf584b6a26f743` | `ff363c40ae459ab9f7f869655089de7e6b11dad07e56d2e8544dd17504bb37e7` | 本文一致・要約のみ |
| A/9 | `Maintanance/Current/CANONICAL_EVIDENCE_ROLLOUT.md` | `c943761c6bc70c09e121fea6d16faa1dd5d4c2e3f661bc0da8d5454b35783323` | `ef245a8e46b50355b1c9f6a39956f977f8fc84b88b0bb1d32853d65b56a11514` | 本文一致・要約のみ |
| A/10 | `Maintanance/Current/CANONICAL_INVENTORY_APPEND.md` | `2791d10c422db399fbf9e960be30304ea8306bdd19dadd1319656f8f1a712e4d` | `418497b9d31d54d6865bd4d4295c40b4dd0c11dabb093d8f222ee55d65057af3` | 本文一致・要約のみ |
| A/11 | `Maintanance/Current/CLAUDE_ACTIVITY_RULE_REVIEW.md` | `f3abbe66024dd7d648f3179eb516ed132b64fd270ee54d5351162bd8d7102fb2` | `399ef3896ff5aa6583e0f480d3e2700e50884af1f95786eaaf65b10e3b291fba` | 本文一致・要約のみ |
| A/12 | `Maintanance/Current/CLAUDE_QUEUE_RECONCILIATION_2026-10-16.md` | `e2d66e8f3c404c88db23e86a91db9d6462daa33658474846589d61eacafb0429` | `cefe574fb86004e7319d4efed257dd55ae0ba3e8c72b980978b3e7519cdbd30b` | 本文一致・要約のみ |
| A/14 | `Maintanance/Current/COORDINATOR_AUTHORITY_CONSOLIDATION_DECISION.md` | `1475ac5a269582abf65c70fcb603e99f94b6b5f66b0db6fd039949f81641107a` | `a8eca0420fceaad395eb2bec75d42429d086aaadd1e0c6ffee2f55067180e9af` | 本文一致・要約のみ |
| A/18 | `Maintanance/Current/HEADLESS_BROWSER_AVAILABILITY.md` | `2c51d9bc762d91d990627ad8e29a139b4acd2ce2f0e295c62455a2fa5cb94c17` | `34e598d53dab47ebcd1578ae12a2318601ee5a9a0bdd46ea6380bb58f72d1fbb` | 本文一致・要約のみ |
| A/19 | `Maintanance/Current/HIME_TRADE_NAME_DECISION.md` | `ddfa986d1e05c859d6cb12fd7425a1121e73f8658ddb02e110dd153cd15e521c` | `dab65f09c849a53ddb2be0bb848868e18f3c3d6e5d8f13d5ce9c29f3500a2361` | 本文一致・要約のみ |
| A/21 | `Maintanance/Current/MILESTONE_HEALTH_AUDIT_2026-10-17.md` | `d382f706de71ab6db503dc54f87d762802ce513ed6bb6c7604a95cf6e161c4d9` | `3571ef8ceaa29d3414846be847ca0d41b83163acfc7b8d436a8cde929a161337` | 本文一致・要約のみ |
| A/22 | `Maintanance/Current/MILESTONE_MIGRATION_ACCEPTANCE_2026-10-17.md` | `b038d73ced3cb27e8c858cf6174f15019d0615b02308d3d378a596aa3a31d770` | `5c0468b3d1ae0ba41301bf2725c31c4c461c1b14bac41aff8859c527b0d36150` | 本文一致・要約のみ |
| A/23 | `Maintanance/Current/OPS_072_ACCEPTANCE.md` | `d95de2d4d0dd756e4e61e174a0d24285ae634931fcffb074df928b1b74cdbde0` | `87cd29ef4ab3fa01ae63ca5c78f390941db021076f944f3f44bd9215e97e64d7` | 本文一致・要約のみ |
| A/24 | `Maintanance/Current/PROVISIONAL_AGREEMENT_JUDGMENT_INVENTORY_PILOT.md` | `997ea3bc2123c87fd91c14aa932b04c62572ae055a456765b68da2225eb55e9c` | `cf7eae72f8f395ae2bec6330a8a1077d9cdb2f38da3cc52b9bf635be85921d5b` | 本文一致・要約のみ |
| A/25 | `Maintanance/Current/PROVISIONAL_JUDGMENT_STUDY.md` | `5831a0f6c012b8a791aa19d7396913bff62e48449752a6a4e5beb54532a625f3` | `cb63fc63a9c74a1e67b9dcefa9041f90de571cff60b4f6d31edc2bd71d36a93f` | 本文一致・要約のみ |
| A/26 | `Maintanance/Current/PROVISIONAL_TASK_AGREEMENT_STUDY.md` | `3022a1a97401b7d2d26293dc927d322a7478daa09cd62210047e0f72473cd4b6` | `3473dab6cef237d4fd865ae578b78d11225011f5d4bc24694c45cee13f9fefe5` | 本文一致・要約のみ |
| A/27 | `Maintanance/Current/RECORD_LIFETIME_STUDY.md` | `4619ade38395dc7fd6fc1dff2cf67f7b5a2ec05d35746a3e7df9b7706f8d7198` | `833660e020836b91b332b950b9a9f427707241636874fe2e341282946ee5fe35` | 本文一致・要約のみ |
| A/28 | `Maintanance/Current/RED_BLACK_TREE_DOCC_PREVIEW_REVIEW.md` | `6b990180b7ad864cc9fc180f3da71202da0c2baa3eeec71b779a7af7bfb2bea5` | `46b8f89c9cfd89a42929c1a61d024294940014cc3ece23c579b62da50fbcfe3e` | 本文一致・要約のみ |
| A/29 | `Maintanance/Current/REGISTRY_STUDIO_ACTIVITY_TIMELINE.md` | `b455a1893c866f8f796e8134261c2fd709eba9b79c09e05657ad727ea25a15a8` | `58b8268beb0c6be4f3c46f972609d1d00c5e74354b005576e0676868a27ffecb` | 本文一致・要約のみ |
| A/30 | `Maintanance/Current/REGISTRY_STUDIO_CARD_LIST.md` | `93c4b64b3c229cd021e33317bb480404a2da6c7c16711af232fcf59e5900726c` | `8e30005b88be1e34cc836633cd491ab015b78c7fc1ea9ddf15411d190bdfe7c6` | 本文一致・要約のみ |
| A/31 | `Maintanance/Current/REGISTRY_STUDIO_COMPACT_ACTIVITY.md` | `3b5a0e9ac76b91b6e81843990568f57aedce57d3cc0fe2f4d527268a90c72f9c` | `e85eb6b09362c5bb0f5a6435d4b8eb478b122640c2142cf1cf74212c06ac89cf` | 本文一致・要約のみ |
| A/32 | `Maintanance/Current/REGISTRY_STUDIO_DISPLAY_PARTITION_TEST.md` | `d7901fab4ab01f9b6001e5410714190f797afd9a576e16842aa0689f76d55199` | `548d8cc0251e5920fafdd633c83ed577f8a85d56271c9d08f027072712c93177` | 本文一致・要約のみ |
| A/33 | `Maintanance/Current/REGISTRY_STUDIO_JUDGMENT_CACHE_REFRESH.md` | `0ff48228925bc451f1e2a5bce3885fcb7ea995cd5c5433e0d24efc843840227e` | `eab130cc9246f5068cb23d8d8c7298fec30a69c89259e7cf00b2629ea9ffd9d3` | 本文一致・要約のみ |
| A/34 | `Maintanance/Current/REGISTRY_STUDIO_LAYOUT_CACHE_REFRESH.md` | `4a58a7dc4f3c1b78b708167a5138eb83821633c14ac4cbc31ffd9b6fe6e3b53c` | `3ab6f7a4bda784e273dd06164339b970bd195e81595a8cbc295c0c1c053f8f9c` | 本文一致・要約のみ |
| A/35 | `Maintanance/Current/REGISTRY_STUDIO_LAYOUT_FALLBACK_REPAIR.md` | `0974e1905704e4cddfc2e11867529627b3370a172fd5c3a479ccaa924092875c` | `309b26522be08bad84fe0bde27906dbf612bd91d3c16efe873b8bb7a499383cf` | 本文一致・要約のみ |
| A/36 | `Maintanance/Current/REGISTRY_STUDIO_MILESTONE_BRANCH_LAYOUT.md` | `92732dfe3daffa09bb541c23b71208eaa66eed3f692143e93b111d57e2811fd7` | `789eb2005100f56c04ea656d97b53a1f0d819512fe866ea28ad8f9f49e9d4fda` | 本文一致・要約のみ |
| A/37 | `Maintanance/Current/REGISTRY_STUDIO_MILESTONE_CONNECT.md` | `e3539d24f159386646fcefc38717cc86f607687fe2196cb747284475fb081854` | `d3d6498a3f40cd2e59d5da30797db0572de8d1c522dced9e34b03ab2bd411083` | 本文一致・要約のみ |
| A/38 | `Maintanance/Current/REGISTRY_STUDIO_MILESTONE_DIRECTION_UI.md` | `61f4bc7178b8aaab9b9267bebb9c6448305473ec67feab3c6ca127f1c2b2aad7` | `fe213665ebc13df97359482270693f7742ff01e75736fbebf05f67bc0d280511` | 本文一致・要約のみ |
| A/39 | `Maintanance/Current/REGISTRY_STUDIO_MILESTONE_EDITOR.md` | `33a9e4fd88783184e3ab7e3d09a6e6865b4567bb329c5910d9e580c385f5bdf9` | `32582493251f6ac3b2307bc699afa86049cb542a177b5439a1d4056ccd1471fe` | 本文一致・要約のみ |
| A/40 | `Maintanance/Current/REGISTRY_STUDIO_MULTIPLE_MILESTONES.md` | `be443f5ad580f774ab26875ffe174779b75c54a08b7d2d9665b387c4be0bad60` | `68073c0807e3a2b2b528c61eb7d09de5011056fae7de6c2d17878e5ebcad201b` | 本文一致・要約のみ |
| A/41 | `Maintanance/Current/REGISTRY_STUDIO_NEIGHBOR_CARDS.md` | `74e5a00e3285f7d904cf307e7dcd140ae15f2cbc21c8d81bb54b6abefbe63d92` | `9086670ed519988121ee9bc34b3dc9abcc8ddc8dfd1af80a57651c84c6b6d71d` | 本文一致・要約のみ |
| A/42 | `Maintanance/Current/REGISTRY_STUDIO_NEIGHBOR_SELECTION_FIX.md` | `c892f4f3a856f865310ce6ccfdb6a4fd1886a13ef5cda68bbe47c2f3d7900df2` | `1ca8d9493d45473a6af8b13f4c80f0815be3ebdd1b65fbcdf6dd5d5ad30474ba` | 本文一致・要約のみ |
| B/43 | `Maintanance/Current/REGISTRY_STUDIO_NEW_TASK_PROPOSALS.md` | `3c3bb30ac13a552db5bafb2d7429b774750d89331bdd79dbb26092acbf5588fc` | `6123bd817c5682ad6fa746f9c1b47ee739c16e64f1e2cd0c5cf050ceeb1ef5b0` | 本文一致・要約のみ |
| B/44 | `Maintanance/Current/REGISTRY_STUDIO_NODE_NEIGHBORHOOD.md` | `872a72d2137b81e0b911ec78e42b160f1585306aea103aa66970a4b86cc130ac` | `8a9f33afe1d1edd3ed8db14202c578bf12629ef29fd6b9fe06943d0fed49f42f` | 本文一致・要約のみ |
| B/45 | `Maintanance/Current/REGISTRY_STUDIO_SAVE_CONTRACT.md` | `e9e0023b6be0c8e231eccb112a6fc385448e5b5769ebbac4cba808d570d2a361` | `7beafbab8accf8ef0e8f1c38e463a3eeb0c87450dfa623567b1e95f5ed268525` | 本文一致・要約のみ |
| B/46 | `Maintanance/Current/REGISTRY_STUDIO_SAVE_USABILITY.md` | `8c04c4ea7f292b0f8180b7bbb2a0a2a50ccb87f986edf608ceea6c1301f94f10` | `c2f2c3fcd27f17b06b021f8d78bb7d5da77654d1297f75a7aaa2f4cfe58617f1` | 本文一致・要約のみ |
| B/47 | `Maintanance/Current/REGISTRY_STUDIO_SERVER_SAVE.md` | `a2b9c71fd6d2c8cc3e5a211a8043c86e55fbf86cf991c78eb7ecbbecea901b6e` | `d861a51998bfb33846557372466f1a61614629b014c1b4b335d9c1f7f0f94c80` | 本文一致・要約のみ |
| B/48 | `Maintanance/Current/REGISTRY_STUDIO_SINGLE_LINE_KIND.md` | `b037b230737a0f7cf2740bef0778b84f7a07b145c6debd99c07a3416253fd5d8` | `82617c26b07c61f46ba333200b18e898032ca59e1fc892b83a6712fe193b0ea1` | 本文一致・要約のみ |
| B/49 | `Maintanance/Current/REGISTRY_STUDIO_TASK_PLACEMENT_FIX.md` | `bf24589005dcf02bb4698fd2909ca29c9acbda615b1d2823cd959e4e94e293fa` | `94c538db623591e8867a9f7479ce2692b2fb53bf9f370742c0efb6b2893a39de` | 本文一致・要約のみ |
| B/50 | `Maintanance/Current/REGISTRY_STUDIO_TERMINAL_BRANCH_LAYOUT.md` | `b9a0d598f1f496045c817b22d2a85d6087389898e4ef74cfd0377e16287b0f68` | `56a625e9c2ea386d21d77591ef670b131b666914cfb7a7dfb7fcfdd50b7032a8` | 本文一致・要約のみ |
| B/51 | `Maintanance/Current/REGISTRY_STUDIO_UNNUMBERED_CARDS.md` | `3a9e364c4d134d9daf9ac4b9864ca0b29a53476d44714c718469064aa79b3d44` | `b62c925bc1ca54885c38d2e69e853325ebbe7d60e62877bc2895612fc1a8df0c` | 本文一致・要約のみ |
| B/52 | `Maintanance/Current/REGISTRY_STUDIO_USABILITY_DECISION.md` | `bb025f2fe2a2d99fabeacde4297ec8e2c26ee74f1f963f7edf3245d1c976e10d` | `9f08386bf93d086a763ebda3fb2d2821a844d23672f3781861bd74df68350962` | 本文一致・要約のみ |
| B/53 | `Maintanance/Current/REGISTRY_STUDIO_VERIFY_FIXTURE_COUPLING.md` | `b427c3029848fc1ab44fbf0e20ba159078eb3f3abf4a3ad778280e5f25ce6039` | `31421f8423c8331b87b7737f9a82358387c4c8d3541391a0aca0cbe5abdffafa` | 本文一致・要約のみ |
| B/54 | `Maintanance/Current/REGISTRY_STUDIO_VERSION_START.md` | `d3ea7af1ffb3a050795cbc4ccf4101709dd2a45d3265447692e080225368229a` | `65b2e58ea63ab6067ce3895a3b26d85ea07af50bd26b90836a11cb7cef0a32c0` | 本文一致・要約のみ |
| B/55 | `Maintanance/Current/REGISTRY_STUDIO_WORK_PROGRESS.md` | `a1bd94286eea3d1588d44cfc2a04f08f9cf3e877e139307ba76b3821cacdd12d` | `df2e2790f3c33b86092a25aff79d6fc07fb12cd65025387929588dc4ae8d32ab` | 本文一致・要約のみ |
| B/56 | `Maintanance/Current/RESEARCH_STATUS_DOCUMENT_CORRECTION.md` | `880e745ed3fa18d70b28ba4d24b9537a8e2fcaeb03ea2b5fe2491703580e4818` | `1bcb246cf9a29c2c745ecd3c646be74a6345e9aa8a7e9ebe6d6f19c62e5e0eda` | 本文一致・要約のみ |
| B/57 | `Maintanance/Current/SOL_OJT_DOCUMENT_CORRECTION.md` | `e840bdea3a430fd7c70816b89017999a79ef15609037bdce0aaecc271401fc9d` | `e1a27539a7f7f478e0b0f4b94fd6ece341533686b59f1a3fcc6f201771a2ccda` | 本文一致・要約のみ |
| B/58 | `Maintanance/Current/SOL_OJT_PILOT_USER_DECISION.md` | `a3280b3b38910d64d55ba40610b0708c72fad503ca786362bcfcee95ffb7327b` | `bd2b009457ddbdf1de8a831ca846d0df371ffd43de476bc93e42a18c3c4b7300` | 本文一致・要約のみ |
| B/59 | `Maintanance/Current/SOL_OJT_WARMUP.md` | `6899375c28015d9a21ac5c20f5ab7c92146a1a396862f9c94bdb129fe072d675` | `128937d8234fc9b14f5a201fe8d6c10711518e589d351a0965fa94c19c236b51` | 本文一致・要約のみ |
| B/60 | `Maintanance/Current/STUDIO_ACTIVITY_OWNER.md` | `f8c6c3d85c55f991f995cd12dcdc6e61b11c18dacabafd738535f11450b7d802` | `82a4bb81765ac60604471614ce655653def8ad860ea57131132d0481deaa1f9b` | 本文一致・要約のみ |
| B/61 | `Maintanance/Current/STUDIO_APPROVAL_SIGNALS.md` | `fcbe679fc662d77c1f5cc72b476eae1c411b977f2c956def234779c9c067ea83` | `c89ae7448fe8976878b9a6a0889e480982c52b1194dedd330a9fc2065317e1f1` | 本文一致・要約のみ |
| B/62 | `Maintanance/Current/STUDIO_CONSIDERATION_EVENT.md` | `220edddedb740f711c4cfcae5dc9337c439386a12c443c753c704a0e8a636ec0` | `a4434834e7b6d7106c9055e0f7d5bebd5e940fb03b323964e5bd5decc3166436` | 本文一致・要約のみ |
| B/63 | `Maintanance/Current/STUDIO_HANDOFF_SIGNALS.md` | `9674fec344118b7985a4f447a8c501750935fe4fa040f64799b857e757bffc04` | `da6b3783072841d49f37f61e338e21c3d879479b1e58bf182ca894082deaf533` | 本文一致・要約のみ |
| B/64 | `Maintanance/Current/STUDIO_OPERATION_REVIEW.md` | `72e2442dc3a5f48479202fb612afcb8552398f71b646902dde19e99b675855a3` | `157b7b8f2f99ef2edd3ced35450563e22c771f6151ef6ea486b0e9d950e98005` | 本文一致・要約のみ |
| B/65 | `Maintanance/Current/STUDIO_RECENT_WORK_LANE.md` | `c2b7249df01f4895dfa1b651edaf261b94b93ac526e92dd773d3008c50ff1bc6` | `d9bde7a63979621552cc65bf2c754dcb3e4bb579fe44a9f2d1fe6374b7f20146` | 本文一致・要約のみ |
| B/66 | `Maintanance/Current/STUDIO_SERVER_REFACTOR.md` | `97bfff769addfa426f33008451fb5a10e7c9bad7ec9bdaad01640236134e237b` | `cb5732976f67305eade2f5a3a02e2206902caa7f226a982c8d2fcde41f6a25ba` | 本文一致・要約のみ |
| B/67 | `Maintanance/Current/STUDIO_UI_ROUND2.md` | `b1f08226ce90e9e34771fe2c4ee0fa05c429ca4dae299a7878b2176177edd95b` | `92bf5d6d9ce7519118c81af21e6bd178f9d6dc74f4f24cce4457a67b9d92691f` | 本文一致・要約のみ |
| B/69 | `Maintanance/Current/STUDIO_USABILITY_ROLLOUT.md` | `3133f9147f2891bd51be2eb2487a8136b9e10f84ca53333dbb492c3039788825` | `13afd5d264ede6e47bc76c96e5b89492c1a76028138f2dc689dd9f68137116ef` | 本文一致・要約のみ |
| B/70 | `Maintanance/Current/STUDIO_WORK_LANE_PROPOSAL.md` | `5372e181dedf97ac9a2b19c0df3995fd87d182847b4ef5eca05656b0484dc5f0` | `dabda6f1ab0c604a583b12aef09ce4454f0f65cd8981a2264c1477e1ab91d4e1` | 本文一致・要約のみ |
| B/71 | `Maintanance/Current/TASK_REGISTRY_APP.md` | `d00944ee5704b51010bb66dacf41709d8ba8135fbc8885e1206a43f6eea21227` | `9504182b165dac26ad5a8a8dbd8c498917ea8baa3c1afc2358672fbf9a2d6e33` | 本文一致・要約のみ |
| B/73 | `Maintanance/Graph/TASK_GRAPH_DB_EXPERIMENT.md` | `3c2c2bacf35ff8aa1aec0373fdacdbb8a56ddd758d8dff90ebd5915f366ba75a` | `e2c780d9ddf7b8ad708a56fd03799f43a2975fd432025f7daebad25da78c06a9` | 本文一致・要約のみ |
| B/77 | `Maintanance/ProgressV2/README.md` | `e4990fc3f2b9e561d86d49b1307e165b2a992f24e3b5fe9fa16894341ccf60b7` | `e0dba8203cf67817fd5d7509f4bdabaaba806df56b6746b833f6dcd0b1fced88` | 本文一致・要約のみ |
| B/82 | `Maintanance/Testing/Fixtures.md` | `da931effb45fc6721621f3a0c531a7cb3d86151ffb73b5925b693d3c42ebc75f` | `77061a07c61cc0f1429d7c260c40519778d2491a9121f24d3641a392fe649d76` | 本文一致・要約のみ |
| B/85 | `Maintanance/UserDocuments/SnippetSurvey/README.md` | `4c030f835a31456f4f1269aab023bd0d552080a3fba8829cdee015fe2d34011d` | `023e66414003de98f9a10e4d1bc1760950fe192d7682735d6805cca589abbe2f` | 本文一致・要約のみ |

## 一時作業物:

`/private/tmp/ops140-independent-check.json`（実体も同じ）、作成Sol・2026-10-19。用途：今回の差分opcode・前後hash・合否の中間記録。`/private/tmp/ops140-write-acceptance.py` は本記録の保存用。専用ディレクトリを作らず個別ファイルとした。状態：削除可。本記録に必要な方法・件数・照合対象・前後hashを保存したため、受入に不要となった時点で作成担当が削除可とする。保存原文ディレクトリは元の返却記録どおり継続保持し、今回削除していない。
