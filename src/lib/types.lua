--- @alias BenchmarkName
--- | "add_empty_entity"
--- | "add_entities"
--- | "remove_entities"
--- | "get_component"
--- | "get_components"
--- | "add_component"
--- | "add_components"
--- | "remove_component"
--- | "remove_components"
--- | "system_update"

--- @class BenchmarkParams
--- @field n_entities number Number of entities for this benchmark run.

--- @class BenchmarkSpec
--- @field fn fun(ctx: table, p: BenchmarkParams) Benchmark function to measure.
--- @field before? fun(ctx: table, p: BenchmarkParams): table Setup function, returns context.
--- @field after? fun(ctx: table) Teardown function called after each iteration.
--- @field max_entities? number Maximum entity count for this benchmark.

--- @alias BenchmarkTests { [BenchmarkName]: BenchmarkSpec }

--- Module that exports tests directly.
--- @alias BenchmarkModule BenchmarkTests

--- Module that exports named variants (e.g., batch/nobatch).
--- @class VariantModule
--- @field variants table<string, BenchmarkTests> Variant name -> tests mapping.
