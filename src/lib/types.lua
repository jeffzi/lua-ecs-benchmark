--- @class BenchmarkParams
--- @field n_entities number Number of entities for this benchmark run.

--- @class BenchmarkSpec
--- @field fn fun(ctx: table, p: BenchmarkParams) Benchmark function to measure.
--- @field before? fun(ctx: table, p: BenchmarkParams): table Setup function, returns context.
--- @field after? fun(ctx: table) Teardown function called after each iteration.
--- @field max_entities? number Maximum entity count for this benchmark.

--- @class BenchmarkTests
--- @field create_empty? BenchmarkSpec
--- @field create_with_components? BenchmarkSpec
--- @field destroy? BenchmarkSpec
--- @field get? BenchmarkSpec
--- @field get_multi? BenchmarkSpec
--- @field add? BenchmarkSpec
--- @field add_multi? BenchmarkSpec
--- @field remove? BenchmarkSpec
--- @field remove_multi? BenchmarkSpec
--- @field update? BenchmarkSpec

--- @class BenchmarkGroup
--- @field name string Group name (e.g., "entity", "component", "system").
--- @field tests string[] Ordered list of test names in this group.

--- @class GroupedBenchmarkTests
--- @field entity? BenchmarkTests
--- @field component? BenchmarkTests
--- @field system? BenchmarkTests

--- Module that exports tests directly (grouped by category).
--- @alias BenchmarkModule GroupedBenchmarkTests

--- Module that exports named variants (e.g., batch/nobatch).
--- @class VariantModule
--- @field variants table<string, GroupedBenchmarkTests> Variant name -> grouped tests mapping.
