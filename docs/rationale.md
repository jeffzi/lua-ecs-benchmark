# Test Selection Rationale

Why these tests, and what each one reveals. For full test specifications,
see [specifications.md](specifications.md).

---

## Test Overview

The suite contains 19 tests across 5 groups, each targeting a distinct performance dimension.

### Entity (3 tests)

| Test                     | Measures                                    |
| ------------------------ | ------------------------------------------- |
| `create_empty`           | Entity allocation cost alone                |
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

### Structural Scaling (3 tests)

| Test            | Measures                                           |
| --------------- | -------------------------------------------------- |
| `create`        | Entity creation cost with 20 registered systems    |
| `add_component` | Component addition cost with 20 registered systems |
| `destroy`       | Entity destruction cost with 20 registered systems |

Three tests suffice because create, add, and destroy all trigger the same
system-matching overhead. Additional operations (`remove`, `create_empty`,
tags) would repeat the same scaling pattern without new information.

The group registers 20 background no-op systems (matching the `multi_20` and
`empty_systems` count) that query `Position` + `Velocity` — the same components
the tracked entities carry. Comparing these results against the zero-system
baselines in Parts 1-3 reveals how much each framework's structural cost grows
with system count.
