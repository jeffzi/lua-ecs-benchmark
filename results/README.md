# Interpreting the Results

Some findings reflect framework characteristics, not bugs. The
patterns below help distinguish real performance traits from
measurement artifacts.

## Concord: JIT Pessimization

Concord runs **slower under LuaJIT than Lua 5.1** for several
operations at higher entity counts (up to 5× on `tag/remove` at 10K
entities). Its table-heavy dispatch defeats LuaJIT's trace
compilation, forcing repeated bail-outs to the interpreter — a known
limitation of tracing JITs with polymorphic call sites.

Affected operations: `component/add`, `component/remove`, `tag/add`,
`tag/remove`, `entity/destroy`.

## lovetoys: Batch Overhead on Add

`lovetoys-batch` is consistently **slower** than `lovetoys-nobatch`
for `component/add` and `tag/add` (roughly 1.1–1.2× across all
interpreters and scales). The batch API adds bookkeeping per call that
outweighs any batching benefit for single-component additions.

Batch mode targets bulk operations where multiple components are added
at once; the overhead is expected when adding one at a time.

## ecs-lua: Read-Only Operations Allocate Memory

`component/get` and `tag/has` on ecs-lua allocate memory proportional
to entity count (~7.8 KB per 100 entities on Lua 5.1). The framework
creates intermediate tables in its getter path — a design choice, not
a benchmark error.

## tinyecs / nata: Read Slower Than Write at High Entity Counts

Under LuaJIT at 10K entities, `component/get` is ~1.6× slower than
`component/set` for tinyecs and nata. Both frameworks use simple
table lookups, but the get path creates slightly more pressure on
LuaJIT's trace compiler at scale.

## Measurement Noise

Results below 10 microseconds (time) or 1 KB (memory) sit at the
noise floor. Timer quantization and GC jitter dominate at this scale,
so small differences between frameworks at low entity counts are
unreliable.
