--- Type stubs for luamark (installed via luarocks).
--- @alias luamark.Fun fun(ctx: any, params: table)
--- @alias luamark.before fun(ctx: any, params: table): any
--- @alias luamark.after fun(ctx: any, params: table)
--- @class luamark.Spec
--- @field fn luamark.Fun Benchmark function; receives iteration context and params.
--- @field before? luamark.before Per-iteration setup; returns iteration context.
--- @field after? luamark.after Per-iteration teardown; returns iteration context.
--- @field baseline? boolean If true, this function serves as 1x baseline for relative comparison.

--- @class BenchmarkParams
--- @field n_entities number Number of entities for this benchmark run.

--- @class BenchmarkTests
--- @field create_empty? luamark.Spec
--- @field create_with_components? luamark.Spec
--- @field destroy? luamark.Spec
--- @field get? luamark.Spec
--- @field set? luamark.Spec
--- @field has? luamark.Spec
--- @field add? luamark.Spec
--- @field remove? luamark.Spec
--- @field throughput? luamark.Spec
--- @field overlap? luamark.Spec
--- @field fragmented? luamark.Spec
--- @field chained? luamark.Spec
--- @field multi_20? luamark.Spec
--- @field empty_systems? luamark.Spec

--- @class BenchmarkGroup
--- @field name string Group name (e.g., "entity", "component", "system").
--- @field tests string[] Ordered list of test names in this group.

--- @class GroupedBenchmarkTests
--- @field entity? BenchmarkTests
--- @field component? BenchmarkTests
--- @field tag? BenchmarkTests
--- @field system? BenchmarkTests

--- Module that exports tests directly (grouped by category).
--- @alias BenchmarkModule GroupedBenchmarkTests

--- Module that exports named variants (e.g., batch/nobatch).
--- @class VariantModule
--- @field variants table<string, GroupedBenchmarkTests> Variant name -> grouped tests mapping.
