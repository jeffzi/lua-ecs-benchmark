# Test Selection Rationale

Why the suite includes these tests and excludes others. For full test
specifications, see [specifications.md](specifications.md).

---

## Test Overview

The suite contains 13 tests across 4 groups, each targeting a distinct performance axis.

### Entity (3 tests)

| Test                     | Measures                                 |
| ------------------------ | ---------------------------------------- |
| `create_empty`           | Raw entity allocation cost               |
| `create_with_components` | Allocation and component attachment cost |
| `destroy`                | Entity removal from a populated world    |

### Component (4 tests)

| Test     | Measures                                        |
| -------- | ----------------------------------------------- |
| `get`    | Field-level read speed (table + tag)            |
| `set`    | Field-level write speed (table + tag)           |
| `add`    | Component insertion cost (archetype transition) |
| `remove` | Component deletion cost (archetype transition)  |

### System (5 tests)

| Test            | Measures                                                         |
| --------------- | ---------------------------------------------------------------- |
| `throughput`    | Per-entity iteration cost (1 system, 100% match)                 |
| `overlap`       | Scheduling efficiency under overlapping queries (3 systems)      |
| `fragmented`    | Iteration across 20 archetypes (2 systems)                       |
| `chained`       | Data-dependency pipeline (4 systems, A → B → C → D → E)          |
| `multi_20`      | Per-system dispatch overhead (20 systems, 100% match)            |
| `empty_systems` | Short-circuit cost when no entities match (20 systems, 0% match) |

### Stress (1 test)

| Test              | Measures                                        |
| ----------------- | ----------------------------------------------- |
| `archetype_churn` | Repeated archetype transitions (200 per entity) |
