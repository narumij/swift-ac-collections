## Task Registry

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `T-001` | `ACTIVE` | Codex | [DISCOVERY] first | 完了まで継続 | `fixture.md` |
| `T-002` | `ACTIVE` | Codex | [EXECUTION] second | T-001後 | `fixture.md` |

## Task precedence

| 後続task | 前提task | Flow | 制約 |
| --- | --- | --- | --- |
| `T-001` | `T-002` | `SEQUENCE` | cycle half |
| `T-002` | `T-001` | `PARALLEL_JOIN` | cycle half |
| `T-001` | `T-001` | `SEQUENCE` | self dependency |
| `T-002` | `MISSING` | `INVALID` | dangling and invalid flow |

## Registry rules
