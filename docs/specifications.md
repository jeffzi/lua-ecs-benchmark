# Benchmark Specifications

Framework-agnostic reference for all benchmark tests.
Each framework implementation must produce behavior equivalent to this spec.

---

## Benchmark Parameters

### Entity Counts

Each benchmark is run at four entity scales:

```lua
ENTITY_COUNTS = {100, 1000, 10000, 50000}
```

The variable `n_entities` (or `N`) refers to the entity count for the measured
operation at a given scale.

### World Population

Entity and component tests run against a **pre-populated world** at a 1:5
ratio. A constant multiplier (`WORLD_MULTIPLIER = 5`) sets the total world size
to `5N`:

- `4N` **background** entities (not operated on)
- `N` **tracked** entities (targets of the benchmark operation)

Three motivations drive this design choice:

1. **Realistic workload** — games operate on subsets of the world each frame,
   not on every entity. A 20% active ratio approximates small-scale game
   behavior.
2. **Allocation pressure** — a world that already holds entities reveals how
   frameworks behave under existing memory pressure (GC, hash resizing). An
   empty world measures only best-case allocation.
3. **Stable measurements** — a populated world produces more consistent timings
   than an empty one, where the first few allocations dominate the result.

System and stress tests use a **1:1 ratio** (no background entities). They
measure iteration throughput and scheduling overhead, not structural operations
in a crowded world. Background entities would conflate iteration cost with
world-size effects.

### Constants

| Constant           | Value  | Purpose                                              |
| ------------------ | ------ | ---------------------------------------------------- |
| `WORLD_MULTIPLIER` | `5`    | Pre-population ratio for entity/component tests      |
| `DT`               | `1/60` | Simulated frame delta (60 FPS) for system ticks      |
| `N_TAGS`           | `20`   | Number of unique tag components for fragmented tests |

---

## Framework Variants

Some frameworks expose multiple API styles for the same operation. **ecs-lua**
offers both a non-batch API (one entity at a time) and a batch API (bulk
operations); **lovetoys** draws the same distinction for component addition.

### Module Structure

A framework file exports one of two shapes:

- **Non-variant** (`BenchmarkModule`): directly exports grouped tests.

  ```lua
  return { entity = {...}, component = {...}, system = {...} }
  ```

- **Variant** (`VariantModule`): exports named variants, each containing grouped
  tests.

  ```lua
  return {
      variants = {
          ["framework"]       = { entity = {...}, system = {...} },
          ["framework-batch"] = { component = {...} },
      }
  }
  ```

### Variant Rule

- **Shared tests** go in the default variant (e.g., `"ecs-lua"`, `"lovetoys"`).
  These tests have identical implementations across all API styles.
- **Specific variants** (e.g., `"ecs-lua-batch"`, `"ecs-lua-nobatch"`) contain
  **only** tests whose implementation differs between variants.
- Charts compare variants only on tests they both implement, keeping results
  fair and avoiding penalties for inapplicable tests.

---

## Implementation Guidelines

1. **Idiomatic code** — use each framework's optimal API, not a
   lowest-common-denominator wrapper. Adapters add function-call overhead that
   skews measurements.
2. **Full deferred-operation cost** — when a framework uses command buffers for
   structural changes, include the complete cost (record + playback). The
   `world:flush()` calls in test pseudocode represent this.
3. **No systems during structural tests** — entity/component benchmarks must
   keep all systems inactive. Isolate structural operation cost from iteration
   overhead.
4. **Shuffle to avoid insertion-order bias** — entity arrays are shuffled
   (Fisher-Yates) after creation so benchmarks gain no advantage from sequential
   memory layout. Without shuffling, frameworks that store entities contiguously
   would show artificially good cache locality absent from real-world random
   access.

---

## Part 1 — Entity & Component Tests

### Component Types

Every test exercises **both** component types:

| Type                | Description          | Examples                                                                                                        |
| ------------------- | -------------------- | --------------------------------------------------------------------------------------------------------------- |
| **Table component** | Stores data fields   | `Position = {x=0, y=0}`, `Velocity = {x=0, y=0}`, `Name = {value="monster"}`, `Health = {current=100, max=100}` |
| **Tag component**   | Boolean/empty marker | `Alive = true`, `Aggro = true`                                                                                  |

### World Population Model

Tests run against a pre-populated world that simulates realistic conditions.

**Multiplier:** 5 (constant for all tests). Total world size = `5N`:

- `4N` **background** entities (not operated on)
- `N` **tracked** entities (targets of the benchmark operation)

Background entities use **different components** than tracked entities to keep
measurements clean. Background composition:

```text
Health = {current=100, max=100}, Name = {value="monster"}, Aggro = true
```

Tracked entities are **shuffled** (Fisher-Yates) after creation, eliminating
insertion-order bias.

### Default Entity

Most tests with pre-populated tracked entities use this composition:

```text
Position = {x=0.0, y=0.0}   -- table component
Velocity = {x=0.0, y=0.0}   -- table component
Alive    = true              -- tag component
```

2 table components + 1 tag. Velocity exists so the `remove` test can strip a table
component while the entity retains `Position` -- testing partial removal, not full
stripping.

---

### Entity Tests

#### create_empty

**Purpose:** Measure the cost of creating a bare entity with no components.

| Property | Value                                   |
| -------- | --------------------------------------- |
| Setup    | Empty world with 4N background entities |
| Teardown | Clear all entities                      |

**Operation:**

```text
for i = 1..N:
    world:add_entity({})
world:flush()
```

**Rationale:** Isolates entity allocation overhead from component assignment.

---

#### create_with_components

**Purpose:** Measure the cost of creating an entity with components attached at
creation time.

| Property   | Value                                                      |
| ---------- | ---------------------------------------------------------- |
| Setup      | Empty world with 4N background entities                    |
| Components | 1 table (`Position = {x=0, y=0}`) + 1 tag (`Alive = true`) |
| Teardown   | Clear all entities                                         |

**Operation:**

```text
for i = 1..N:
    world:add_entity({
        Position = {x=0, y=0},
        Alive = true
    })
world:flush()
```

**Rationale:** Measures combined allocation + component attachment cost. Uses
fewer components than the default entity (1 table + 1 tag vs 2 table + 1 tag) to
isolate creation overhead from component count scaling.

---

#### destroy

**Purpose:** Measure the cost of removing entities from the world.

| Property | Value                              |
| -------- | ---------------------------------- |
| Setup    | N default entities + 4N background |
| Teardown | Clear all entities                 |

**Operation:**

```text
for i = 1..N:
    world:remove_entity(entities[i])
world:flush()
```

**Rationale:** Entities leave a populated world that continues to exist -- the
realistic case. A game discards the world outright rather than destroying entities
one by one.

---

### Component Tests

#### get

**Purpose:** Measure the cost of reading component data from entities.

| Property       | Value                                                          |
| -------------- | -------------------------------------------------------------- |
| Setup          | N default entities (Position, Velocity, Alive) + 4N background |
| Access pattern | Field-level read (`e.Position.x`) + tag read (`e.Alive`)       |
| Teardown       | Clear all entities                                             |

**Operation:**

```text
for i = 1..N:
    e = entities[i]
    _ = e.Position.x    -- read table component field
    _ = e.Alive          -- read tag component
```

**Rationale:** Tests field-level access, not whole-component retrieval. Reading
both a nested table field and a flat tag captures the two access patterns
frameworks must optimize.

---

#### set

**Purpose:** Measure the cost of writing/updating component data on entities.

| Property       | Value                                                                    |
| -------------- | ------------------------------------------------------------------------ |
| Setup          | N default entities (Position, Velocity, Alive) + 4N background           |
| Access pattern | Field-level write (`e.Position.x = 1.0`) + tag write (`e.Alive = false`) |
| Teardown       | Clear all entities                                                       |

**Operation:**

```text
for i = 1..N:
    e = entities[i]
    e.Position.x = 1.0   -- write table component field
    e.Alive = false       -- write tag component
```

**Rationale:** Mirrors `get` but measures write performance. Setting a tag to
`false` rather than removing it tests in-place mutation without triggering
archetype changes.

---

#### add

**Purpose:** Measure the cost of adding new components to existing entities.

| Property         | Value                                                          |
| ---------------- | -------------------------------------------------------------- |
| Setup            | N default entities (Position, Velocity, Alive) + 4N background |
| Components added | 1 table (`Name = {value="monster"}`) + 1 tag (`Aggro = true`)  |
| Teardown         | Clear all entities                                             |

**Operation:**

```text
for i = 1..N:
    e = entities[i]
    e.Name = {value="monster"}    -- add table component
    e.Aggro = true                -- add tag component
    world:entity_updated(e)       -- notify world of change
world:flush()
```

**Rationale:** Adds components absent from the default entity, forcing an
archetype transition (in archetype-based ECS) and testing each framework's
structural-change handling. The added components (`Name`, `Aggro`) happen to match
background entity components -- incidental overlap, not a design constraint.

---

#### remove

**Purpose:** Measure the cost of removing components from existing entities.

| Property           | Value                                                          |
| ------------------ | -------------------------------------------------------------- |
| Setup              | N default entities (Position, Velocity, Alive) + 4N background |
| Components removed | 1 table (`Velocity`) + 1 tag (`Alive`)                         |
| Teardown           | Clear all entities                                             |

**Operation:**

```text
for i = 1..N:
    e = entities[i]
    e.Velocity = nil     -- remove table component
    e.Alive = nil        -- remove tag component
    world:entity_updated(e)   -- notify world of change
world:flush()
```

**Rationale:** Removes components present on the default entity, triggering
archetype transitions. After removal, entities retain only `Position`, testing
that the framework handles partial component sets correctly. Removing both a table
component and a tag exercises both removal paths.

---

## Part 2 — System & Stress Tests

### Common Patterns

All system tests share the same lifecycle:

1. **Create entities** with test-specific compositions
2. **Register systems** with appropriate filters
3. **Flush** pending entity/system changes
4. **Warmup tick** — run one `world:update(dt)` before measurement
5. **Measure** — benchmark calls `world:update(dt)` repeatedly

The warmup tick fully initializes framework internals (entity lists, system
caches, query indices) before measurement begins. Without it, the first iteration
would include one-time setup costs.

Unlike entity/component tests, system tests have **no background entities**, no
world population multiplier, and no shuffling. Entities use test-specific
compositions instead of the default entity.

**Constants:** `dt = 1/60` (60 FPS frame time), `N_TAGS = 20`.

### Component Palette

| Category | Components              | Fields                               |
| -------- | ----------------------- | ------------------------------------ |
| Domain   | `Position`, `Velocity`  | `{x, y}`                             |
| Generic  | `A`, `B`, `C`, `D`, `E` | `{v}`                                |
| Numbered | `Comp1`..`Comp10`       | `{value}`                            |
| Tags     | `Tag1`..`Tag20`         | `{id}` (table markers, not booleans) |
| Sentinel | `NonExistent`           | Never assigned to any entity         |

---

### System Tests

#### throughput

**Purpose:** Measure raw per-entity processing throughput with a single system,
100% entity match rate, and the simplest possible workload.

| Property           | Value                                            |
| ------------------ | ------------------------------------------------ |
| Systems            | 1 (`MovementSystem`)                             |
| Archetypes         | 1                                                |
| Match rate         | 100%                                             |
| Entity composition | `Position = {x=0, y=0}`, `Velocity = {x=0, y=0}` |
| Teardown           | Clear all entities                               |

**Operation (per system tick):**

```text
MovementSystem — filter: Position, Velocity
    for each entity e:
        e.Position.x += e.Velocity.x * dt
        e.Position.y += e.Velocity.y * dt
```

**Rationale:** Establishes the baseline for system iteration cost. One system,
one archetype, every entity matched. Overhead beyond the arithmetic is framework
dispatch cost.

---

#### overlap

**Purpose:** Measure system scheduling efficiency when multiple systems have
overlapping but non-identical entity queries.

| Property    | Value                                  |
| ----------- | -------------------------------------- |
| Systems     | 3 (`SwapAB`, `SwapCD`, `SwapCE`)       |
| Archetypes  | 4 (25% each)                           |
| Match rates | SwapAB: 100%, SwapCD: 25%, SwapCE: 25% |
| Teardown    | Clear all entities                     |

**Entity distribution** (round-robin by index `i % 4`):

| `i % 4` | Components         |
| ------- | ------------------ |
| 0       | `A`, `B`           |
| 1       | `A`, `B`, `C`      |
| 2       | `A`, `B`, `C`, `D` |
| 3       | `A`, `B`, `C`, `E` |

All components initialized with `{v = 0}`.

**Operation (per system tick):**

```text
SwapAB — filter: A, B          (matches all 4 archetypes)
    for each entity e:
        e.A.v, e.B.v = e.B.v, e.A.v

SwapCD — filter: C, D          (matches i%4 == 2 only)
    for each entity e:
        e.C.v, e.D.v = e.D.v, e.C.v

SwapCE — filter: C, E          (matches i%4 == 3 only)
    for each entity e:
        e.C.v, e.E.v = e.E.v, e.C.v
```

**Rationale:** Tests how well frameworks handle multiple systems with partially
overlapping queries. The varying match rates (100% vs 25%) reveal whether the
framework efficiently skips non-matching entities or archetypes.

---

#### fragmented

**Purpose:** Measure iteration cost when entities are spread across many
archetypes, with systems matching different fractions of the population.

| Property    | Value                                |
| ----------- | ------------------------------------ |
| Systems     | 2 (`PositionSystem`, `Tag1System`)   |
| Archetypes  | 20 (one per tag)                     |
| Match rates | PositionSystem: 100%, Tag1System: 5% |
| Teardown    | Clear all entities                   |

**Entity composition:**

Each entity has `Position = {x=0, y=0}` plus exactly one tag assigned by
round-robin:

```text
tag_index = ((i - 1) % 20) + 1
entity.Position = {x=0, y=0}
entity[Tag<tag_index>] = {id = tag_index}
```

This produces 20 distinct archetypes (`Position + Tag1`, `Position + Tag2`, ...),
each containing ~5% of entities.

**Operation (per system tick):**

```text
local sum = 0

PositionSystem — filter: Position     (matches all 20 archetypes)
    for each entity e:
        sum = sum + e.Position.x + e.Position.y

Tag1System — filter: Tag1             (matches 1 of 20 archetypes)
    for each entity e:
        sum = sum + e.Position.x + e.Position.y
```

**Rationale:** Archetype-based ECS frameworks must iterate all matching archetypes
to find entities. With 20 archetypes, a 100%-match system visits all 20; a
5%-match system visits just 1. This reveals per-archetype overhead in the
framework's query/iteration machinery. Systems read-accumulate instead of writing
to separate iteration cost from component write overhead (measured separately by
component `set`).

---

#### chained

**Purpose:** Measure system pipeline correctness and overhead when each system's
output feeds the next system's input.

| Property           | Value                                                           |
| ------------------ | --------------------------------------------------------------- |
| Systems            | 4 (`SysAB`, `SysBC`, `SysCD`, `SysDE`)                          |
| Archetypes         | 1                                                               |
| Match rate         | 100% (all systems)                                              |
| Entity composition | `A = {v=1}`, `B = {v=0}`, `C = {v=0}`, `D = {v=0}`, `E = {v=0}` |
| Teardown           | Clear all entities                                              |

**Operation (per system tick):**

```text
SysAB — filter: A, B     →  e.B.v = e.A.v
SysBC — filter: B, C     →  e.C.v = e.B.v
SysCD — filter: C, D     →  e.D.v = e.C.v
SysDE — filter: D, E     →  e.E.v = e.D.v
```

After one tick, the value `1` propagates: `A → B → C → D → E`.

**Rationale:** Verifies that frameworks execute systems in registration order and
that one system's changes are visible to subsequent systems within the same tick.
The propagation chain confirms deterministic ordering.

---

#### multi_20

**Purpose:** Measure system scheduling overhead with a large number of systems
(20), all operating on the same entities.

| Property           | Value                                                               |
| ------------------ | ------------------------------------------------------------------- |
| Systems            | 20 (2 per component × 10 components)                                |
| Archetypes         | 1                                                                   |
| Match rate         | 100% (all systems)                                                  |
| Entity composition | `Comp1 = {value=0}`, `Comp2 = {value=0}`, ..., `Comp10 = {value=0}` |
| Teardown           | Clear all entities                                                  |

**System creation:**

For each of the 10 components (`Comp1`..`Comp10`), register 2 systems:

```text
local sum = 0

for comp_name in [Comp1..Comp10]:
    System1 — filter: comp_name
        for each entity e:
            sum = sum + e[comp_name].value

    System2 — filter: comp_name
        for each entity e:
            sum = sum + e[comp_name].value
```

**Rationale:** With 20 systems all matching every entity, this test isolates
per-system dispatch overhead. Frameworks that batch or inline system calls
outperform those with high per-invocation cost. Systems read-accumulate instead of
writing to separate dispatch cost from component write overhead (measured
separately by component `set`).

---

#### empty_systems

**Purpose:** Measure system dispatch overhead when no entities match -- the cost
of checking and skipping 20 systems per tick.

| Property           | Value                            |
| ------------------ | -------------------------------- |
| Systems            | 20 (all query `NonExistent`)     |
| Archetypes         | 1 (`Position` only)              |
| Match rate         | 0% (no entity has `NonExistent`) |
| Entity composition | `Position = {x=0, y=0}`          |
| Teardown           | Clear all entities               |

**System creation:**

```text
for i = 1..20:
    System — filter: NonExistent
        for each entity e:
            e.NonExistent.value += dt    -- never executes
```

**Rationale:** Tests each framework's ability to short-circuit when a system
matches no entities. Archetype-based frameworks skip at the query level;
filtering-based frameworks may still iterate every entity. The gap reveals how
efficiently each framework handles empty result sets.

---

### Stress Tests

#### archetype_churn

**Purpose:** Measure the cost of repeated structural changes (component
add/remove cycles) that force archetype transitions.

| Property       | Value                                 |
| -------------- | ------------------------------------- |
| Setup entities | N entities with `A = {v=0}`, shuffled |
| Churn cycles   | 100 per entity                        |
| Teardown       | Clear all entities                    |

**Operation:**

```text
for each entity e in shuffled_entities:
    repeat 100 times:
        e.B = {v=0}              -- add component B
        world:entity_updated(e)
        world:flush()
        e.B = nil                -- remove component B
        world:entity_updated(e)
        world:flush()
```

Each entity transitions between archetype `{A}` and archetype `{A, B}` one
hundred times.

**Rationale:** Archetype-based frameworks must move entities between storage
buckets on every structural change. This test hammers that path: 200 transitions
per entity x N entities = `200N` total transitions. The shuffle prevents
sequential access patterns from masking overhead. Real games rarely churn
archetypes this aggressively, but the extreme load exposes worst-case structural
mutation cost.
