-- GRAPH-007: RBT-017 minimal fixture, transcribed by hand from AI_GRAPH_SHARED_SCHEMA.md section 5.
-- Observed at 729637c9 (no Sources/Tests change since f6f84d6c).
-- Hand-made fixture: document nodes are listed explicitly. The fixture files and the task-definition documents
-- (AI_GRAPH_SHARED_SCHEMA.md, AI_GRAPH_IN_MEMORY_FIXTURE.md) are not document nodes, so they cannot inflate the counts.

-- symbols
INSERT INTO node VALUES
  ('s:23RedBlackTreeCollections0abC16MappedValuesViewVy4Base_01_E5ValueAA01_eI4TypePQZAA12_LazyTieWrapVyAA15_NodePtrSealingVGcip', 'symbol', 'RedBlackTreeMappedValuesView.subscript(_:)', 'Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeMappedValuesView.swift:152', 152, 162, NULL,
   'compiler_symbolgraph', 'confirmed', '729637c9'),
  ('s:23RedBlackTreeCollections0abC16MappedValuesViewV6swapAtyyAA12_LazyTieWrapVyAA15_NodePtrSealingVG_AItF', 'symbol', 'RedBlackTreeMappedValuesView.swapAt(_:_:)', 'Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeMappedValuesView.swift:175', 175, 189, NULL,
   'compiler_symbolgraph', 'confirmed', '729637c9');

-- tests
INSERT INTO node VALUES
  ('Tests/RedBlackTreeTests/RedBlackTreeView/RedBlackTreeView_0_MappedValuesViewTests.swift', 'test', 'RedBlackTreeView_0_MappedValuesViewTests.swift',
   'Tests/RedBlackTreeTests/RedBlackTreeView/RedBlackTreeView_0_MappedValuesViewTests.swift', NULL, NULL, 'spec', 'compiler_index', 'confirmed', '729637c9'),
  ('Tests/RedBlackTreeTests/RedBlackTreeMultiMap/RedBlackTreeMultiMap_7_UtilityTests.swift', 'test', 'RedBlackTreeMultiMap_7_UtilityTests.swift',
   'Tests/RedBlackTreeTests/RedBlackTreeMultiMap/RedBlackTreeMultiMap_7_UtilityTests.swift', NULL, NULL, 'spec', 'compiler_index', 'confirmed', '729637c9'),
  ('Tests/RedBlackTreeTests/RedBlackTreeMultiMap/RedBlackTreeMultiMap_8_RangeViewTests.swift', 'test', 'RedBlackTreeMultiMap_8_RangeViewTests.swift',
   'Tests/RedBlackTreeTests/RedBlackTreeMultiMap/RedBlackTreeMultiMap_8_RangeViewTests.swift', NULL, NULL, 'spec', 'compiler_index', 'confirmed', '729637c9'),
  ('Tests/RedBlackTreeTests/RedBlackTreeDictionary/RedBlackTreeDictionary_99_DeathTests.swift', 'test', 'RedBlackTreeDictionary_99_DeathTests.swift',
   'Tests/RedBlackTreeTests/RedBlackTreeDictionary/RedBlackTreeDictionary_99_DeathTests.swift', NULL, NULL, 'other', 'compiler_index', 'confirmed', '729637c9');

-- documents
INSERT INTO node VALUES
  ('Documentation/RedBlackTreeMultiMap.ja.md', 'document', 'RedBlackTreeMultiMap.ja.md', 'Documentation/RedBlackTreeMultiMap.ja.md', NULL, NULL, NULL, 'repo_text', 'confirmed', '729637c9'),
  ('Documentation/RedBlackTreeMultiMap.md', 'document', 'RedBlackTreeMultiMap.md', 'Documentation/RedBlackTreeMultiMap.md', NULL, NULL, NULL, 'repo_text', 'confirmed', '729637c9'),
  ('Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md', 'document', 'RED_BLACK_TREE_REMAINING_TASKS.md', 'Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md', NULL, NULL, NULL, 'repo_text', 'confirmed', '729637c9'),
  ('Sources/RedBlackTreeCollections/Documentation/API-Matrix-View.md', 'document', 'API-Matrix-View.md', 'Sources/RedBlackTreeCollections/Documentation/API-Matrix-View.md', NULL, NULL, NULL, 'repo_text', 'confirmed', '729637c9'),
  ('Sources/RedBlackTreeCollections/Documentation/API-Matrix.md', 'document', 'API-Matrix.md', 'Sources/RedBlackTreeCollections/Documentation/API-Matrix.md', NULL, NULL, NULL, 'repo_text', 'confirmed', '729637c9'),
  ('Sources/RedBlackTreeCollections/Documentation/Head/Outlines/RedBlackTreeMultiMap.outline.md', 'document', 'RedBlackTreeMultiMap.outline.md', 'Sources/RedBlackTreeCollections/Documentation/Head/Outlines/RedBlackTreeMultiMap.outline.md', NULL, NULL, NULL, 'repo_text', 'confirmed', '729637c9'),
  ('Sources/RedBlackTreeCollections/Documentation/Head/RedBlackTreeMultiMap.ja.md', 'document', 'RedBlackTreeMultiMap.ja.md', 'Sources/RedBlackTreeCollections/Documentation/Head/RedBlackTreeMultiMap.ja.md', NULL, NULL, NULL, 'repo_text', 'confirmed', '729637c9'),
  ('Sources/RedBlackTreeCollections/Documentation/Head/RedBlackTreeMultiMap.md', 'document', 'RedBlackTreeMultiMap.md', 'Sources/RedBlackTreeCollections/Documentation/Head/RedBlackTreeMultiMap.md', NULL, NULL, NULL, 'repo_text', 'confirmed', '729637c9'),
  ('Sources/RedBlackTreeCollections/RedBlackTreeCollections.docc/RedBlackTreeMappedValuesView.md', 'document', 'RedBlackTreeMappedValuesView.md', 'Sources/RedBlackTreeCollections/RedBlackTreeCollections.docc/RedBlackTreeMappedValuesView.md', NULL, NULL, NULL, 'repo_text', 'confirmed', '729637c9');

-- commits
INSERT INTO node VALUES
  ('211ca2fc', 'commit', '2026-10-05 make mapped values index operations constant time', NULL, NULL, NULL, NULL, 'repo_git', 'confirmed', '729637c9'),
  ('3349e4b3', 'commit', '2026-10-03 add tests',    NULL, NULL, NULL, NULL, 'repo_git', 'confirmed', '729637c9'),
  ('3e79163c', 'commit', '2026-10-01 docc',         NULL, NULL, NULL, NULL, 'repo_git', 'confirmed', '729637c9'),
  ('4e5c3306', 'commit', '2026-09-28 memo',         NULL, NULL, NULL, NULL, 'repo_git', 'confirmed', '729637c9'),
  ('0266bfd5', 'commit', '2026-09-28 view',         NULL, NULL, NULL, NULL, 'repo_git', 'confirmed', '729637c9'),
  ('0bbde8a0', 'commit', '2026-09-28 values view',  NULL, NULL, NULL, NULL, 'repo_git', 'confirmed', '729637c9'),
  ('beb80c1b', 'commit', '2026-09-28 renames',      NULL, NULL, NULL, NULL, 'repo_git', 'confirmed', '729637c9'),
  ('a67b736c', 'commit', '2026-09-28 swap',         NULL, NULL, NULL, NULL, 'repo_git', 'confirmed', '729637c9');

-- tasks: they deal with these symbols, but no repository record says so. No task_scopes edge is made
-- (an AI inference must not become a confirmed edge), so the task section returns 0 with "nothing to derive from".
INSERT INTO node VALUES
  ('RBT-017', 'task', '[EXECUTION] Mapped Values Range Viewの範囲外更新防止ゲート', 'Maintanance/PROGRESS_OVERVIEW.md', NULL, NULL, NULL, 'repo_text', 'confirmed', '729637c9'),
  ('RBT-018', 'task', '[DISCOVERY] Mapped Values ViewのIndex検査条件調査',         'Maintanance/PROGRESS_OVERVIEW.md', NULL, NULL, NULL, 'repo_text', 'confirmed', '729637c9'),
  ('RBT-026', 'task', '[DECISION] Mapped Values ViewのO(1)範囲契約再検討',         'Maintanance/PROGRESS_OVERVIEW.md', NULL, NULL, NULL, 'repo_text', 'confirmed', '729637c9');

-- test_references
INSERT INTO edge(src, dst, relation, provenance, confidence, evidence) VALUES
  ('Tests/RedBlackTreeTests/RedBlackTreeView/RedBlackTreeView_0_MappedValuesViewTests.swift', 's:23RedBlackTreeCollections0abC16MappedValuesViewVy4Base_01_E5ValueAA01_eI4TypePQZAA12_LazyTieWrapVyAA15_NodePtrSealingVGcip', 'test_references', 'compiler_index', 'confirmed',
   'index store; Tests/RedBlackTreeTests/RedBlackTreeView/RedBlackTreeView_0_MappedValuesViewTests.swift:121 test_subrangeValuesSingleIndexOperations_doNotCompareKeys'),
  ('Tests/RedBlackTreeTests/RedBlackTreeDictionary/RedBlackTreeDictionary_99_DeathTests.swift', 's:23RedBlackTreeCollections0abC16MappedValuesViewVy4Base_01_E5ValueAA01_eI4TypePQZAA12_LazyTieWrapVyAA15_NodePtrSealingVGcip', 'test_references', 'compiler_index', 'confirmed', 'index store'),
  ('Tests/RedBlackTreeTests/RedBlackTreeView/RedBlackTreeView_0_MappedValuesViewTests.swift', 's:23RedBlackTreeCollections0abC16MappedValuesViewV6swapAtyyAA12_LazyTieWrapVyAA15_NodePtrSealingVG_AItF', 'test_references', 'compiler_index', 'confirmed',
   'index store; Tests/RedBlackTreeTests/RedBlackTreeView/RedBlackTreeView_0_MappedValuesViewTests.swift:121 test_subrangeValuesSingleIndexOperations_doNotCompareKeys'),
  ('Tests/RedBlackTreeTests/RedBlackTreeMultiMap/RedBlackTreeMultiMap_7_UtilityTests.swift', 's:23RedBlackTreeCollections0abC16MappedValuesViewV6swapAtyyAA12_LazyTieWrapVyAA15_NodePtrSealingVG_AItF', 'test_references', 'compiler_index', 'confirmed', 'index store'),
  ('Tests/RedBlackTreeTests/RedBlackTreeMultiMap/RedBlackTreeMultiMap_8_RangeViewTests.swift', 's:23RedBlackTreeCollections0abC16MappedValuesViewV6swapAtyyAA12_LazyTieWrapVyAA15_NodePtrSealingVG_AItF', 'test_references', 'compiler_index', 'confirmed', 'index store'),
  ('Tests/RedBlackTreeTests/RedBlackTreeDictionary/RedBlackTreeDictionary_99_DeathTests.swift', 's:23RedBlackTreeCollections0abC16MappedValuesViewV6swapAtyyAA12_LazyTieWrapVyAA15_NodePtrSealingVG_AItF', 'test_references', 'compiler_index', 'confirmed', 'index store');

-- document_mentions: name match only is a candidate; API-Matrix-View.md lines 52-56 were read and state the O(1) contract.
INSERT INTO edge(src, dst, relation, provenance, confidence, evidence) VALUES
  ('Documentation/RedBlackTreeMultiMap.ja.md', 's:23RedBlackTreeCollections0abC16MappedValuesViewVy4Base_01_E5ValueAA01_eI4TypePQZAA12_LazyTieWrapVyAA15_NodePtrSealingVGcip', 'document_mentions', 'repo_text', 'candidate', 'git grep -w -F subscript and -F RedBlackTreeMappedValuesView'),
  ('Documentation/RedBlackTreeMultiMap.ja.md', 's:23RedBlackTreeCollections0abC16MappedValuesViewV6swapAtyyAA12_LazyTieWrapVyAA15_NodePtrSealingVG_AItF', 'document_mentions', 'repo_text', 'candidate', 'git grep -w -F swapAt and -F RedBlackTreeMappedValuesView'),
  ('Documentation/RedBlackTreeMultiMap.md', 's:23RedBlackTreeCollections0abC16MappedValuesViewVy4Base_01_E5ValueAA01_eI4TypePQZAA12_LazyTieWrapVyAA15_NodePtrSealingVGcip', 'document_mentions', 'repo_text', 'candidate', 'git grep -w -F subscript and -F RedBlackTreeMappedValuesView'),
  ('Documentation/RedBlackTreeMultiMap.md', 's:23RedBlackTreeCollections0abC16MappedValuesViewV6swapAtyyAA12_LazyTieWrapVyAA15_NodePtrSealingVG_AItF', 'document_mentions', 'repo_text', 'candidate', 'git grep -w -F swapAt and -F RedBlackTreeMappedValuesView'),
  ('Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md', 's:23RedBlackTreeCollections0abC16MappedValuesViewVy4Base_01_E5ValueAA01_eI4TypePQZAA12_LazyTieWrapVyAA15_NodePtrSealingVGcip', 'document_mentions', 'repo_text', 'candidate', 'git grep -w -F subscript and -F RedBlackTreeMappedValuesView'),
  ('Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md', 's:23RedBlackTreeCollections0abC16MappedValuesViewV6swapAtyyAA12_LazyTieWrapVyAA15_NodePtrSealingVG_AItF', 'document_mentions', 'repo_text', 'candidate', 'git grep -w -F swapAt and -F RedBlackTreeMappedValuesView'),
  ('Sources/RedBlackTreeCollections/Documentation/API-Matrix-View.md', 's:23RedBlackTreeCollections0abC16MappedValuesViewVy4Base_01_E5ValueAA01_eI4TypePQZAA12_LazyTieWrapVyAA15_NodePtrSealingVGcip', 'document_mentions', 'repo_text', 'confirmed', 'Sources/RedBlackTreeCollections/Documentation/API-Matrix-View.md:52-56 states O(1) and the caller precondition'),
  ('Sources/RedBlackTreeCollections/Documentation/API-Matrix-View.md', 's:23RedBlackTreeCollections0abC16MappedValuesViewV6swapAtyyAA12_LazyTieWrapVyAA15_NodePtrSealingVG_AItF', 'document_mentions', 'repo_text', 'confirmed', 'Sources/RedBlackTreeCollections/Documentation/API-Matrix-View.md:52-56 states O(1) and the caller precondition'),
  ('Sources/RedBlackTreeCollections/Documentation/API-Matrix.md', 's:23RedBlackTreeCollections0abC16MappedValuesViewVy4Base_01_E5ValueAA01_eI4TypePQZAA12_LazyTieWrapVyAA15_NodePtrSealingVGcip', 'document_mentions', 'repo_text', 'candidate', 'git grep -w -F subscript and -F RedBlackTreeMappedValuesView'),
  ('Sources/RedBlackTreeCollections/Documentation/Head/Outlines/RedBlackTreeMultiMap.outline.md', 's:23RedBlackTreeCollections0abC16MappedValuesViewVy4Base_01_E5ValueAA01_eI4TypePQZAA12_LazyTieWrapVyAA15_NodePtrSealingVGcip', 'document_mentions', 'repo_text', 'candidate', 'git grep -w -F subscript and -F RedBlackTreeMappedValuesView'),
  ('Sources/RedBlackTreeCollections/Documentation/Head/Outlines/RedBlackTreeMultiMap.outline.md', 's:23RedBlackTreeCollections0abC16MappedValuesViewV6swapAtyyAA12_LazyTieWrapVyAA15_NodePtrSealingVG_AItF', 'document_mentions', 'repo_text', 'candidate', 'git grep -w -F swapAt and -F RedBlackTreeMappedValuesView'),
  ('Sources/RedBlackTreeCollections/Documentation/Head/RedBlackTreeMultiMap.ja.md', 's:23RedBlackTreeCollections0abC16MappedValuesViewVy4Base_01_E5ValueAA01_eI4TypePQZAA12_LazyTieWrapVyAA15_NodePtrSealingVGcip', 'document_mentions', 'repo_text', 'candidate', 'git grep -w -F subscript and -F RedBlackTreeMappedValuesView'),
  ('Sources/RedBlackTreeCollections/Documentation/Head/RedBlackTreeMultiMap.ja.md', 's:23RedBlackTreeCollections0abC16MappedValuesViewV6swapAtyyAA12_LazyTieWrapVyAA15_NodePtrSealingVG_AItF', 'document_mentions', 'repo_text', 'candidate', 'git grep -w -F swapAt and -F RedBlackTreeMappedValuesView'),
  ('Sources/RedBlackTreeCollections/Documentation/Head/RedBlackTreeMultiMap.md', 's:23RedBlackTreeCollections0abC16MappedValuesViewVy4Base_01_E5ValueAA01_eI4TypePQZAA12_LazyTieWrapVyAA15_NodePtrSealingVGcip', 'document_mentions', 'repo_text', 'candidate', 'git grep -w -F subscript and -F RedBlackTreeMappedValuesView'),
  ('Sources/RedBlackTreeCollections/Documentation/Head/RedBlackTreeMultiMap.md', 's:23RedBlackTreeCollections0abC16MappedValuesViewV6swapAtyyAA12_LazyTieWrapVyAA15_NodePtrSealingVG_AItF', 'document_mentions', 'repo_text', 'candidate', 'git grep -w -F swapAt and -F RedBlackTreeMappedValuesView'),
  ('Sources/RedBlackTreeCollections/RedBlackTreeCollections.docc/RedBlackTreeMappedValuesView.md', 's:23RedBlackTreeCollections0abC16MappedValuesViewVy4Base_01_E5ValueAA01_eI4TypePQZAA12_LazyTieWrapVyAA15_NodePtrSealingVGcip', 'document_mentions', 'repo_text', 'candidate', 'git grep -w -F subscript and -F RedBlackTreeMappedValuesView'),
  ('Sources/RedBlackTreeCollections/RedBlackTreeCollections.docc/RedBlackTreeMappedValuesView.md', 's:23RedBlackTreeCollections0abC16MappedValuesViewV6swapAtyyAA12_LazyTieWrapVyAA15_NodePtrSealingVG_AItF', 'document_mentions', 'repo_text', 'candidate', 'git grep -w -F swapAt and -F RedBlackTreeMappedValuesView');

-- commit_changes: rank is the git log order (1 = newest); same-day commits keep that order
INSERT INTO edge(src, dst, relation, provenance, confidence, evidence, rank) VALUES
  ('211ca2fc', 's:23RedBlackTreeCollections0abC16MappedValuesViewVy4Base_01_E5ValueAA01_eI4TypePQZAA12_LazyTieWrapVyAA15_NodePtrSealingVGcip', 'commit_changes', 'repo_git', 'confirmed', 'git log -L152,162:Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeMappedValuesView.swift', 1),
  ('3349e4b3', 's:23RedBlackTreeCollections0abC16MappedValuesViewVy4Base_01_E5ValueAA01_eI4TypePQZAA12_LazyTieWrapVyAA15_NodePtrSealingVGcip', 'commit_changes', 'repo_git', 'confirmed', 'git log -L152,162:Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeMappedValuesView.swift', 2),
  ('3e79163c', 's:23RedBlackTreeCollections0abC16MappedValuesViewVy4Base_01_E5ValueAA01_eI4TypePQZAA12_LazyTieWrapVyAA15_NodePtrSealingVGcip', 'commit_changes', 'repo_git', 'confirmed', 'git log -L152,162:Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeMappedValuesView.swift', 3),
  ('4e5c3306', 's:23RedBlackTreeCollections0abC16MappedValuesViewVy4Base_01_E5ValueAA01_eI4TypePQZAA12_LazyTieWrapVyAA15_NodePtrSealingVGcip', 'commit_changes', 'repo_git', 'confirmed', 'git log -L152,162:Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeMappedValuesView.swift', 4),
  ('0266bfd5', 's:23RedBlackTreeCollections0abC16MappedValuesViewVy4Base_01_E5ValueAA01_eI4TypePQZAA12_LazyTieWrapVyAA15_NodePtrSealingVGcip', 'commit_changes', 'repo_git', 'confirmed', 'git log -L152,162:Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeMappedValuesView.swift', 5),
  ('0bbde8a0', 's:23RedBlackTreeCollections0abC16MappedValuesViewVy4Base_01_E5ValueAA01_eI4TypePQZAA12_LazyTieWrapVyAA15_NodePtrSealingVGcip', 'commit_changes', 'repo_git', 'confirmed', 'git log -L152,162:Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeMappedValuesView.swift', 6),
  ('211ca2fc', 's:23RedBlackTreeCollections0abC16MappedValuesViewV6swapAtyyAA12_LazyTieWrapVyAA15_NodePtrSealingVG_AItF', 'commit_changes', 'repo_git', 'confirmed', 'git log -L175,189:Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeMappedValuesView.swift', 1),
  ('3349e4b3', 's:23RedBlackTreeCollections0abC16MappedValuesViewV6swapAtyyAA12_LazyTieWrapVyAA15_NodePtrSealingVG_AItF', 'commit_changes', 'repo_git', 'confirmed', 'git log -L175,189:Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeMappedValuesView.swift', 2),
  ('3e79163c', 's:23RedBlackTreeCollections0abC16MappedValuesViewV6swapAtyyAA12_LazyTieWrapVyAA15_NodePtrSealingVG_AItF', 'commit_changes', 'repo_git', 'confirmed', 'git log -L175,189:Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeMappedValuesView.swift', 3),
  ('beb80c1b', 's:23RedBlackTreeCollections0abC16MappedValuesViewV6swapAtyyAA12_LazyTieWrapVyAA15_NodePtrSealingVG_AItF', 'commit_changes', 'repo_git', 'confirmed', 'git log -L175,189:Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeMappedValuesView.swift', 4),
  ('0266bfd5', 's:23RedBlackTreeCollections0abC16MappedValuesViewV6swapAtyyAA12_LazyTieWrapVyAA15_NodePtrSealingVG_AItF', 'commit_changes', 'repo_git', 'confirmed', 'git log -L175,189:Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeMappedValuesView.swift', 5),
  ('a67b736c', 's:23RedBlackTreeCollections0abC16MappedValuesViewV6swapAtyyAA12_LazyTieWrapVyAA15_NodePtrSealingVG_AItF', 'commit_changes', 'repo_git', 'confirmed', 'git log -L175,189:Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeMappedValuesView.swift', 6),
  ('0bbde8a0', 's:23RedBlackTreeCollections0abC16MappedValuesViewV6swapAtyyAA12_LazyTieWrapVyAA15_NodePtrSealingVG_AItF', 'commit_changes', 'repo_git', 'confirmed', 'git log -L175,189:Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeMappedValuesView.swift', 7);
