local Progress = require("src.lib.progress")
local argparse = require("argparse")
local luamark = require("luamark")
local utils = require("src.lib.utils")

--- Framework modules. Some export tests directly, others export variants.
local MODULES = {
   ["ecs-lua"] = require("src.frameworks.ecs-lua"),
   concord = require("src.frameworks.concord"),
   lovetoys = require("src.frameworks.lovetoys"),
   nata = require("src.frameworks.nata"),
   tinyecs = require("src.frameworks.tinyecs"),
}

--- Flattened framework name -> tests mapping (variants expanded).
local FRAMEWORKS = {}

--- Alias name -> variant names (e.g., "ecs-lua" -> {"ecs-lua-batch", "ecs-lua-nobatch"}).
local FRAMEWORK_ALIASES = {}

for name, mod in pairs(MODULES) do
   if not mod.variants then
      FRAMEWORKS[name] = mod
   else
      FRAMEWORK_ALIASES[name] = {}
      for variant_name, tests in pairs(mod.variants) do
         FRAMEWORKS[variant_name] = tests
         FRAMEWORK_ALIASES[name][#FRAMEWORK_ALIASES[name] + 1] = variant_name
      end
   end
end

local FRAMEWORK_NAMES = utils.keys(FRAMEWORKS)
local CLI_FRAMEWORK_CHOICES = utils.concat(FRAMEWORK_NAMES, utils.keys(FRAMEWORK_ALIASES))

local TESTS = {
   "add_empty_entity",
   "add_entities",
   "remove_entities",
   "get_component",
   "get_components",
   "add_component",
   "add_components",
   "remove_component",
   "remove_components",
   "system_update",
}

local ENTITY_COUNTS = { 10, 100, 1000, 10000 }

local HEADERS = {
   "entities",
   "test",
   "framework",
   "unit",
   "timestamp",
   "median",
   "ci_lower",
   "ci_upper",
   "rounds",
}

--- Log benchmark info when progress bar is disabled.
--- @param specs table<string, table> Framework specs.
--- @param test_name string Name of the test.
--- @param max_entities? number Optional max_entities limit.
local function log_benchmark_info(specs, test_name, max_entities)
   local names = utils.keys(specs)
   table.sort(names)

   local limit_info = max_entities and string.format(" (max_entities=%d)", max_entities) or ""
   utils.printf(
      "[%s] Running %d frameworks%s: %s",
      test_name,
      #names,
      limit_info,
      table.concat(names, ", ")
   )
end

local BENCHMARK_TYPES = {
   { fn = luamark.compare_time, label = "time" },
   { fn = luamark.compare_memory, label = "memory" },
}

--- Run time and memory benchmarks for a set of specs.
--- @param specs table<string, table> Framework specs to benchmark.
--- @param counts number[] Entity counts to benchmark.
--- @param test_name string Name of the test.
--- @param all_stats table[] Accumulator for CSV rows.
--- @param max_entities? number Optional max_entities limit for logging.
--- @param show_log boolean Whether to show log output.
--- @param on_benchmark? function Callback after each benchmark type (receives label).
local function run_benchmarks(
   specs,
   counts,
   test_name,
   all_stats,
   max_entities,
   show_log,
   on_benchmark
)
   if show_log then
      log_benchmark_info(specs, test_name, max_entities)
   end

   local params = { params = { n_entities = counts } }

   for _, bench in ipairs(BENCHMARK_TYPES) do
      collectgarbage("collect")
      for _, r in ipairs(bench.fn(specs, params)) do
         all_stats[#all_stats + 1] = {
            r.n_entities,
            test_name,
            r.name,
            r.unit,
            r.timestamp,
            r.median,
            r.ci_lower,
            r.ci_upper,
            r.rounds,
         }
      end
      if on_benchmark then
         on_benchmark(bench.label)
      end
   end
end

--- Filter entity counts to those at or below a limit.
--- @param counts number[] Entity counts.
--- @param max_allowed number Maximum allowed count.
--- @return number[] Filtered counts.
local function filter_counts(counts, max_allowed)
   local filtered = {}
   for _, n in ipairs(counts) do
      if n <= max_allowed then
         filtered[#filtered + 1] = n
      end
   end
   return filtered
end

--- Run benchmarks.
--- @param output? string Output CSV file path.
--- @param framework_names? string[] Framework names to benchmark.
--- @param tests? string[] Test names to run.
--- @param entity_counts? number[] Entity counts to benchmark.
--- @param opts? table Options (no_progress: boolean).
local function main(output, framework_names, tests, entity_counts, opts)
   opts = opts or {}
   framework_names = framework_names or FRAMEWORK_NAMES
   tests = tests or TESTS
   entity_counts = entity_counts or ENTITY_COUNTS

   local all_stats = {}
   local max_count = entity_counts[#entity_counts]

   -- Each test runs 2 benchmarks (time + memory)
   local bar = Progress({
      total = #tests * 2,
      template = "{bar} {pct} | {msg} | {elapsed} < {eta}",
      disable = opts.no_progress,
   })
   bar:start()

   local show_log = bar.disable
   local progress_count = 0
   for _, test_name in ipairs(tests) do
      -- Group frameworks by their max_entities limit (nil means unlimited)
      local groups = {}

      for _, name in ipairs(framework_names) do
         local tests_for_framework = FRAMEWORKS[name]
         local spec = tests_for_framework and tests_for_framework[test_name]
         if spec then
            local limit = spec.max_entities
            -- Treat limits >= max requested count as unlimited
            if limit and limit < max_count then
               groups[limit] = groups[limit] or {}
               groups[limit][name] = spec
            else
               groups.unlimited = groups.unlimited or {}
               groups.unlimited[name] = spec
            end
         end
      end

      -- Progress callback
      local function on_benchmark(label)
         progress_count = progress_count + 1
         bar:update(progress_count, string.format("%s (%s)", test_name, label))
      end

      -- Run unlimited group first (full entity counts)
      if groups.unlimited then
         run_benchmarks(
            groups.unlimited,
            entity_counts,
            test_name,
            all_stats,
            nil,
            show_log,
            on_benchmark
         )
         groups.unlimited = nil
      end

      -- Run limited groups with filtered counts
      for limit, specs in pairs(groups) do
         local counts = filter_counts(entity_counts, limit)
         if #counts > 0 then
            run_benchmarks(specs, counts, test_name, all_stats, limit, show_log, on_benchmark)
         end
      end
   end

   bar:stop(string.format("Completed %d tests in {elapsed}", #tests * 2))

   if output then
      utils.write_csv(all_stats, output, HEADERS, ",")
      print("Wrote results to " .. output)
   end
end

local function cli()
   local desc = "Benchmark ECS (Entity-Component-System)-Frameworks in Lua"
   local parser = argparse("lua-ecs-benchmark", desc)
   parser:option("-o --output", "CSV file where the results will be saved."):convert(utils.mkdir)
   parser
      :option("--framework", "ECS frameworks to benchmark")
      :choices(CLI_FRAMEWORK_CHOICES)
      :default(CLI_FRAMEWORK_CHOICES)
      :args("+")
   parser:option("--test", "Tests to run"):choices(TESTS):default(TESTS):args("+")
   parser
      :option("-n --entities", "Entity counts to benchmark")
      :convert(tonumber)
      :default(ENTITY_COUNTS)
      :args("+")
   parser:flag("--no-progress", "Disable live progress display")
   local args = parser:parse()

   -- Expand aliases (e.g., "ecs-lua" -> {"ecs-lua-batch", "ecs-lua-nobatch"})
   local frameworks = utils.expand_names(args.framework, FRAMEWORK_ALIASES)

   main(args.output, frameworks, args.test, args.entities, { no_progress = args.no_progress })
end

cli()
