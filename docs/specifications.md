# Benchmark Specifications

Framework-agnostic reference for all benchmarks.
Every framework must match this specification exactly.

---

## Benchmark Parameters

### Entity Counts

Each benchmark runs at four entity scales:

```lua
ENTITY_COUNTS = {100, 1000, 10000, 50000}
```

`n_entities` (or `N`) denotes the entity count for a given scale.

### World Population

Entity, component, and tag tests run against a **pre-populated world** at a 1:5
ratio. The multiplier (`WORLD_MULTIPLIER = 5`) produces a world of `5N` entities:

- `4N` **background** entities (idle)
- `N` **tracked** entities (targets of the benchmark operation)

Three motivations drive this design:

1. **Realistic workload** — games process a subset of the world each frame. A
   20% active ratio approximates small-scale game behavior.
2. **Allocation pressure** — a pre-populated world exposes framework behavior
   under memory pressure (GC, hash resizing). An empty world measures only
   best-case allocation cost.
3. **Stable measurements** — a populated world produces more consistent timings
   than an empty one, where early allocations dominate variance.

System tests use a **1:1 ratio** (no background entities) to isolate iteration
throughput and scheduling overhead from structural cost. Adding background
entities would conflate iteration cost with world-size effects.

### Constants

| Constant           | Value  | Purpose                                                   |
| ------------------ | ------ | --------------------------------------------------------- |
| `WORLD_MULTIPLIER` | `5`    | Pre-population ratio for entity/component/tag tests       |
| `DT`               | `1/60` | Simulated frame delta (60 FPS) for system ticks           |
| `N_BUFFS`          | `20`   | Number of unique buff components for fragmented tests     |
| `N_SYSTEMS`        | `20`   | Number of background systems for structural scaling tests |

---

## Framework Variants

Some frameworks expose multiple API styles for the same operation. **ecs-lua**
offers a non-batch API (one entity at a time) and a batch API (bulk operations);
**lovetoys** makes the same distinction for component addition.

### Module Structure

A framework file exports one of two shapes:

- **Non-variant** (`BenchmarkModule`): exports test groups directly.

  ```lua
  return { entity = {...}, component = {...}, tag = {...}, system = {...} }
  ```

- **Variant** (`VariantModule`): exports named variants, each containing test
  groups.

  ```lua
  return {
      variants = {
          ["framework"]       = { entity = {...}, system = {...} },
          ["framework-batch"] = { component = {...}, tag = {...} },
      }
  }
  ```

### Variant Rule

- **Shared tests** go in the default variant (e.g., `"ecs-lua"`, `"lovetoys"`).
  These tests share identical implementations across all API styles.
- **Specific variants** (e.g., `"ecs-lua-batch"`, `"ecs-lua-nobatch"`) hold
  **only** tests whose implementations differ between API styles.
- **Charts** compare variants only on tests both implement, keeping comparisons
  fair.

---

## Implementation Guidelines

1. **Idiomatic code** — use each framework's optimal API. Adapters add
   function-call overhead that skews measurements.
2. **Full deferred-operation cost** — when a framework defers structural changes
   to command buffers, measure the complete cost (record + playback). The
   `world:flush()` calls in pseudocode represent this.
3. **Inactive systems during structural tests** — entity/component/tag
   benchmarks must keep all systems inactive to isolate structural cost from
   iteration overhead. The `structural_scaling` group is the deliberate
   exception: it registers background systems to measure their impact on
   structural operations.
4. **Shuffle to defeat insertion-order bias** — shuffle entity arrays
   (Fisher-Yates) after creation so benchmarks gain no advantage from sequential
   memory layout. Without shuffling, frameworks that store entities contiguously
   would show artificially good cache locality, absent in real-world random
   access.

---

## Part 1 — Entity Tests

### Component Types

Entity tests exercise two component types:

| Type                | Description          | Examples                                                                                                        |
| ------------------- | -------------------- | --------------------------------------------------------------------------------------------------------------- |
| **Table component** | Stores data fields   | `Position = {x=0, y=0}`, `Velocity = {x=0, y=0}`, `Name = {value="monster"}`, `Health = {current=100, max=100}` |
| **Tag component**   | Boolean/empty marker | `Alive = true`, `Aggro = true`                                                                                  |

### World Population Model

Tests run against a pre-populated world to simulate realistic allocation pressure.

**Multiplier:** 5 (constant for all tests). World size = `5N`:

- `4N` **background** entities (idle)
- `N` **tracked** entities (targets of the benchmark operation)

Background entities use **different components** from tracked entities to avoid
query overlap. Background composition:

```text
Health = {current=100, max=100}, Name = {value="monster"}, Aggro = true
```

Tracked entities are **shuffled** (Fisher-Yates) after creation to eliminate
insertion-order bias.

### Default Entity

Most tests pre-populate tracked entities with this default composition:

```text
Position = {x=0.0, y=0.0}   -- table component
Velocity = {x=0.0, y=0.0}   -- table component
Alive    = true              -- tag component
```

2 table components + 1 tag. Velocity exists so `remove` can delete a table
component while the entity retains `Position`, exercising partial removal.

---

### Entity Tests

#### create_empty

**Purpose:** Measure bare entity allocation cost, without components.

| Property | Value                                                    |
| -------- | -------------------------------------------------------- |
| Setup    | Pre-populated world (4N background + N default entities) |
| Teardown | Clear all entities                                       |

**Operation:**

```text
for i = 1..N:
    world:add_entity({})
world:flush()
```

**Rationale:** Isolates allocation cost from component assignment.

---

#### create_with_components

**Purpose:** Measure entity creation cost when components are attached at birth.

| Property   | Value                                                      |
| ---------- | ---------------------------------------------------------- |
| Setup      | Pre-populated world (4N background + N default entities)   |
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

**Rationale:** Measures allocation and component attachment as a single
operation. Uses fewer components than the default entity (1 table + 1 tag vs
2 table + 1 tag) to isolate creation overhead from component-count scaling.

---

#### destroy

**Purpose:** Measure entity removal cost.

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

**Rationale:** Entities leave a world that remains populated -- the realistic
case. Games discard entire worlds rather than destroy entities individually.

---

## Part 2 — Component Tests

Each test performs exactly **one operation per entity**, isolating a single
performance dimension.

### Component Tests

#### get

**Purpose:** Measure table component field read cost.

| Property       | Value                                                          |
| -------------- | -------------------------------------------------------------- |
| Setup          | N default entities (Position, Velocity, Alive) + 4N background |
| Access pattern | Field-level read (`e.Position.x`, `e.Position.y`)              |
| Teardown       | Clear all entities                                             |

**Operation:**

```text
for i = 1..N:
    e = entities[i]
    pos = e.Position
    _ = pos.x            -- read field 1
    _ = pos.y            -- read field 2
```

**Rationale:** Reading both fields of a two-field component measures the
amortized lookup cost. Real code rarely reads a single field in isolation.

---

#### set

**Purpose:** Measure table component field write cost.

| Property       | Value                                                          |
| -------------- | -------------------------------------------------------------- |
| Setup          | N default entities (Position, Velocity, Alive) + 4N background |
| Access pattern | Field-level write (`e.Position.x`, `e.Position.y`)             |
| Teardown       | Clear all entities                                             |

**Operation:**

```text
for i = 1..N:
    e = entities[i]
    pos = e.Position
    pos.x = 1.0          -- write field 1
    pos.y = 1.0          -- write field 2
```

**Rationale:** Mirrors `get` for writes. Writing both fields amortizes the
lookup, matching the typical access pattern.

---

#### add

**Purpose:** Measure component insertion cost on existing entities.

| Property        | Value                                                          |
| --------------- | -------------------------------------------------------------- |
| Setup           | N default entities (Position, Velocity, Alive) + 4N background |
| Component added | 1 table (`Name = {value="monster"}`)                           |
| Teardown        | Clear all entities                                             |

**Operation:**

```text
for i = 1..N:
    e = entities[i]
    e.Name = {value="monster"}    -- add table component
    world:entity_updated(e)       -- notify world of change
world:flush()
```

**Rationale:** Adds a component absent from the default entity, forcing an
archetype transition in archetype-based frameworks. A single addition isolates
structural-change cost.

---

#### remove

**Purpose:** Measure component removal cost on existing entities.

| Property          | Value                                                          |
| ----------------- | -------------------------------------------------------------- |
| Setup             | N default entities (Position, Velocity, Alive) + 4N background |
| Component removed | 1 table (`Velocity`)                                           |
| Teardown          | Clear all entities                                             |

**Operation:**

```text
for i = 1..N:
    e = entities[i]
    e.Velocity = nil     -- remove table component
    world:entity_updated(e)   -- notify world of change
world:flush()
```

**Rationale:** Removes a component present on the default entity, triggering an
archetype transition. After removal, entities keep `Position` and `Alive`,
verifying correct partial-removal handling.

---

## Part 3 — Tag Tests

Tag tests exercise each framework's **idiomatic tag mechanism**:

- Frameworks with native tag support (evolved TAG trait) use the native tag type
- Frameworks without native tags (tiny-ecs, nata) use boolean `true`
- Frameworks with empty components (concord, ecs-lua, lovetoys) use empty
  component instances

Tags carry no data, so `get` and `set` do not apply. Component tests omit `has`
because callers retrieve via `get` and check the return value.

Each test performs **one operation per entity**.

### Tag Tests

#### has

**Purpose:** Measure tag presence-check cost.

| Property       | Value                                                          |
| -------------- | -------------------------------------------------------------- |
| Setup          | N default entities (Position, Velocity, Alive) + 4N background |
| Access pattern | Tag presence check (`has(e, Alive)`)                           |
| Teardown       | Clear all entities                                             |

**Operation:**

```text
for i = 1..N:
    e = entities[i]
    _ = has(e, Alive)    -- check tag presence (boolean result)
```

**Rationale:** Measures tag lookup cost via each framework's idiomatic check.
Returns a boolean (present/absent), unlike component `get`, which returns data.

---

#### add (tag)

**Purpose:** Measure tag insertion cost on existing entities.

| Property  | Value                                                          |
| --------- | -------------------------------------------------------------- |
| Setup     | N default entities (Position, Velocity, Alive) + 4N background |
| Tag added | `Aggro`                                                        |
| Teardown  | Clear all entities                                             |

**Operation:**

```text
for i = 1..N:
    e = entities[i]
    e.Aggro = true           -- add tag
    world:entity_updated(e)  -- notify world of change
world:flush()
```

**Rationale:** Adds a tag absent from the default entity, measuring structural
change cost for lightweight markers.

---

#### remove (tag)

**Purpose:** Measure tag removal cost on existing entities.

| Property    | Value                                                          |
| ----------- | -------------------------------------------------------------- |
| Setup       | N default entities (Position, Velocity, Alive) + 4N background |
| Tag removed | `Alive`                                                        |
| Teardown    | Clear all entities                                             |

**Operation:**

```text
for i = 1..N:
    e = entities[i]
    e.Alive = nil            -- remove tag
    world:entity_updated(e)  -- notify world of change
world:flush()
```

**Rationale:** Removes a tag present on the default entity, measuring the
structural cost of lightweight marker removal.

---

## Part 4 — System Tests

### Common Patterns

All system tests share this lifecycle:

1. **Create entities** with test-specific compositions
2. **Register systems** with appropriate filters
3. **Flush** pending entity/system changes
4. **Run one warmup tick** (`world:update(dt)`) before measurement
5. **Measure** by calling `world:update(dt)` repeatedly

The warmup tick initializes framework internals (entity lists, system caches,
query indices) before measurement. Without it, the first iteration would include
one-time setup cost.

System tests omit background entities, the world multiplier, and shuffling.
Entities use test-specific compositions instead of the default.

**Constants:** `dt = 1/60` (60 FPS frame time), `N_BUFFS = 20`.

### Component Palette

| Category | Components              | Fields                       |
| -------- | ----------------------- | ---------------------------- |
| Domain   | `Position`, `Velocity`  | `{x, y}`                     |
| Generic  | `A`, `B`, `C`, `D`, `E` | `{v}`                        |
| Numbered | `Comp1`..`Comp10`       | `{value}`                    |
| Buffs    | `Buff1`..`Buff20`       | `{level}` (buff intensity)   |
| Sentinel | `NonExistent`           | Never assigned to any entity |

---

### System Tests

#### throughput

**Purpose:** Measure raw per-entity throughput with one system, 100% match rate,
and minimal workload.

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
one archetype, every entity matched -- overhead beyond the arithmetic is pure
dispatch cost.

---

#### overlap

**Purpose:** Measure scheduling efficiency when multiple systems query
overlapping yet distinct entity sets.

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

**Rationale:** The contrasting match rates (100% vs 25%) reveal whether a
framework efficiently skips non-matching entities or archetypes.

---

#### fragmented

**Purpose:** Measure iteration cost when many archetypes fragment the entity
population and systems match different fractions.

| Property    | Value                                 |
| ----------- | ------------------------------------- |
| Systems     | 2 (`PositionSystem`, `Buff1System`)   |
| Archetypes  | 20 (one per buff)                     |
| Match rates | PositionSystem: 100%, Buff1System: 5% |
| Teardown    | Clear all entities                    |

**Entity composition:**

Each entity has `Position = {x=0, y=0}` plus exactly one buff assigned by
round-robin:

```text
buff_index = ((i - 1) % 20) + 1
entity.Position = {x=0, y=0}
entity[Buff<buff_index>] = {level = buff_index}
```

This produces 20 distinct archetypes (`Position + Buff1`, `Position + Buff2`,
...), each containing ~5% of entities.

**Operation (per system tick):**

```text
local sum = 0

PositionSystem — filter: Position     (matches all 20 archetypes)
    for each entity e:
        sum = sum + e.Position.x + e.Position.y

Buff1System — filter: Buff1           (matches 1 of 20 archetypes)
    for each entity e:
        sum = sum + e.Buff1.level
```

**Rationale:** Archetype-based ECS frameworks must iterate all matching
archetypes to find entities. With 20 archetypes, the 100%-match system visits
all 20; the 5%-match system visits just 1. This contrast exposes per-archetype
query and iteration overhead. Buff1System reads its own component (Buff1, not
Position), aligning each system's filter with its data access. Systems
read-accumulate rather than write, separating iteration cost from write
overhead (measured separately by component `set`).

---

#### chained

**Purpose:** Measure pipeline overhead when each system's output feeds the next
system's input.

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

**Rationale:** Confirms that frameworks execute systems in registration order
and propagate writes within the same tick. The value chain
`A -> B -> C -> D -> E` proves deterministic ordering.

---

#### multi_20

**Purpose:** Measure system scheduling overhead with 20 systems all operating on
the same entities.

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

**Rationale:** Twenty systems matching every entity isolate per-system dispatch
overhead. Frameworks that batch or inline system calls outperform those with high
per-invocation cost. Systems read-accumulate rather than write, separating
dispatch cost from write overhead (measured separately by component `set`).

---

#### empty_systems

**Purpose:** Measure system dispatch overhead when no entities match -- the cost
of checking and skipping 20 idle systems each tick.

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

**Rationale:** Reveals whether a framework short-circuits when no entities
match. Archetype-based frameworks skip at the query level; filter-based
frameworks may still iterate every entity. The gap exposes each framework's
cost for empty result sets.

---

## Part 5 — Structural Scaling Tests

### Motivation

The entity, component, and tag tests (Parts 1-3) deliberately keep all systems
inactive (guideline #3) to isolate raw structural cost. In a real game, dozens
of systems are registered while entities are created, modified, and destroyed.
Structural operations may trigger system re-matching, entity-list updates, or
archetype transitions whose cost scales with registered system count.

The `structural_scaling` group re-runs three representative structural operations
with 20 registered background systems. Comparing these results against the
zero-system baselines in Parts 1-3 reveals each framework's structural scaling
behavior.

### Background System Setup

All structural scaling tests share this world setup:

1. Create world
2. Register `N_SYSTEMS` (20) no-op systems, each querying `Position` +
   `Velocity`
3. Populate `4N` background entities + `N` tracked entities (same as Parts 1–3)
4. Flush/refresh
5. Shuffle tracked entities

The systems have empty bodies — they exist only to incur filter-matching cost
during structural operations, not iteration cost. All 20 query the same
components (`Position`, `Velocity`) to maximize matching work across
framework architectures.

---

### Structural Scaling Tests

#### create

**Purpose:** Measure entity creation cost with registered background systems.

| Property           | Value                                                      |
| ------------------ | ---------------------------------------------------------- |
| Setup              | Scaling world (20 systems + 4N background + N tracked)     |
| Components created | 1 table (`Position = {x=0, y=0}`) + 1 tag (`Alive = true`) |
| Teardown           | Clear all entities                                         |

**Operation:**

```text
for i = 1..N:
    world:add_entity({
        Position = {x=0, y=0},
        Alive = true
    })
world:flush()
```

**Rationale:** Mirrors `create_with_components` from Part 1 but with active
systems. The gap between this result and `entity/create_with_components` reveals
how structural operations degrade as system count grows.

---

#### add_component

**Purpose:** Measure component addition cost with registered background systems.

| Property        | Value                                                  |
| --------------- | ------------------------------------------------------ |
| Setup           | Scaling world (20 systems + 4N background + N tracked) |
| Component added | 1 table (`Name = {value="monster"}`)                   |
| Teardown        | Clear all entities                                     |

**Operation:**

```text
for i = 1..N:
    e = entities[i]
    e.Name = {value="monster"}
    world:entity_updated(e)
world:flush()
```

**Rationale:** Mirrors `component/add` from Part 2 but with active systems.
Component addition triggers archetype transitions and system re-matching,
exposing per-system overhead during structural changes.

---

#### destroy

**Purpose:** Measure entity destruction cost with registered background systems.

| Property | Value                                                  |
| -------- | ------------------------------------------------------ |
| Setup    | Scaling world (20 systems + 4N background + N tracked) |
| Teardown | Clear all entities                                     |

**Operation:**

```text
for i = 1..N:
    world:remove_entity(entities[i])
world:flush()
```

**Rationale:** Mirrors `entity/destroy` from Part 1 but with active systems.
Entity removal must update system entity lists or archetype membership, exposing
per-system destruction overhead.
