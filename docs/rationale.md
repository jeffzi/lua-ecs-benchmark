# Test Selection Rationale

Why these tests, and why not others. For full test specifications,
see [specifications.md](specifications.md).

---

## Test Overview

The suite contains 16 tests across 4 groups, each targeting a distinct performance axis.

### Entity (3 tests)

| Test                     | Measures                                    |
| ------------------------ | ------------------------------------------- |
| `create_empty`           | Raw entity allocation cost                  |
| `create_with_components` | Entity allocation with component attachment |
| `destroy`                | Entity removal from a populated world       |

### Component (4 tests)

| Test     | Measures                                        |
| -------- | ----------------------------------------------- |
| `get`    | Field read speed on table components            |
| `set`    | Field write speed on table components           |
| `add`    | Component insertion cost (archetype transition) |
| `remove` | Component removal cost (archetype transition)   |

### Tag (3 tests)

| Test     | Measures                               |
| -------- | -------------------------------------- |
| `has`    | Tag presence check cost                |
| `add`    | Tag insertion cost (structural change) |
| `remove` | Tag removal cost (structural change)   |

### System (6 tests)

| Test            | Measures                                                    |
| --------------- | ----------------------------------------------------------- |
| `throughput`    | Per-entity iteration cost (1 system, 100% match)            |
| `overlap`       | Scheduling efficiency with overlapping queries (3 systems)  |
| `fragmented`    | Iteration across 20 archetypes (2 systems)                  |
| `chained`       | Data-dependency pipeline (4 systems, A → B → C → D → E)     |
| `multi_20`      | Per-system dispatch overhead (20 systems, 100% match)       |
| `empty_systems` | Short-circuit cost with zero matching entities (20 systems) |
