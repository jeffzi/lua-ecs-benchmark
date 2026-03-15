# Interpreting the Results

Some findings reflect framework characteristics, not bugs. The
patterns below help distinguish real performance traits from
measurement artifacts.

## Concord: JIT Pessimization

Enabling LuaJIT's JIT compiler **hurts** concord on several
operations at higher entity counts (up to 2.6× slower than JIT-off
on `component/add` at 10K entities). Its table-heavy dispatch defeats
trace compilation, forcing repeated bail-outs to the interpreter — a
known limitation of tracing JITs with polymorphic call sites.

Affected operations: `component/add`, `tag/add`, `entity/destroy`,
`component/remove`.

## lovetoys: Batch Overhead on Add

`lovetoys-batch` is consistently **slower** than `lovetoys-nobatch`
for `component/add` and `tag/add` (roughly 1.1–1.2× across all
interpreters and scales). The batch API adds bookkeeping per call that
outweighs any batching benefit for single-component additions.

Batch mode targets bulk operations where multiple components are added
at once; the overhead is expected when adding one at a time.

## evolved.lua: Extreme LuaJIT Interpreter Speedup

evolved.lua shows **20–35× faster** under LuaJIT's interpreter
(luajit-off) compared to Lua 5.1 on simple operations like
`component/get`, `component/set`, and `system/throughput`. Its
lightweight table-based design maps directly to operations LuaJIT's
interpreter handles natively, producing much larger speedup ratios
than other frameworks.

Where Concord's table-heavy dispatch defeats LuaJIT's trace compiler,
evolved's simplicity plays to its strengths.

## ecs-lua: Read-Only Operations Allocate Memory

`component/get` and `tag/has` on ecs-lua allocate memory proportional
to entity count (~7.8 KB per 100 entities on Lua 5.1). The framework
creates intermediate tables in its getter path — a design choice, not
a benchmark error.

## Structural Scaling: Filter-Based vs Archetype

The `structural_scaling` tests re-run create, add_component, and
destroy with 20 registered background systems. Comparing against the
zero-system baselines reveals how much each framework's structural
cost grows with system count.

**Archetype frameworks (ecs-lua, evolved)** show **no overhead** (~1×).
Structural changes update an archetype index directly — registered
system count is irrelevant.

**Filter-based frameworks** pay a per-system matching cost on every
structural change. The overhead scales with both entity count and
system count:

| Framework | create | add_component | destroy |
| --------- | ------ | ------------- | ------- |
| lovetoys  | ~2.5×  | ~1×           | ~1×     |
| nata      | ~3.5×  | ~2×           | ~8×     |
| concord   | ~5×    | ~7×           | ~10×    |
| tinyecs   | ~6×    | ~11×          | ~14×    |

tinyecs is hit hardest: its `refresh()` re-evaluates every dirty
entity against every registered system. In a game with 50+ systems,
structural operations become a bottleneck. concord and nata show
similar but less severe patterns depending on the operation.

## Measurement Noise

Results below 10 microseconds (time) or 1 KB (memory) sit at the
noise floor. Timer quantization and GC jitter dominate at this scale,
so small differences between frameworks at low entity counts are
unreliable.
