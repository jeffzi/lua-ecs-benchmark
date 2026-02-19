local Progress = require("src.lib.progress")
local argparse = require("argparse")
local config = require("src.lib.config")
local luamark = require("luamark")
local utils = require("src.lib.utils")

-- ----------------------------------------------------------------------------
-- Configuration
-- ----------------------------------------------------------------------------

local ENTITY_COUNTS = config.ENTITY_COUNTS

local GROUPS = {
   { name = "entity", tests = { "create_empty", "create_with_components", "destroy" } },
   { name = "component", tests = { "get", "set", "add", "remove" } },
   { name = "tag", tests = { "has", "add", "remove" } },
   {
      name = "system",
      tests = { "throughput", "overlap", "fragmented", "chained", "multi_20", "empty_systems" },
   },
}

local HEADERS = {
   "entities",
   "group",
   "test",
   "framework",
   "unit",
   "timestamp",
   "median",
   "ci_lower",
   "ci_upper",
   "rounds",
}

local jit_off = jit and jit.off
local jit_on = jit and jit.on

local BENCHMARK_TYPES = {
   { fn = luamark.compare_time, label = "time" },
   {
      fn = function(funcs, opts)
         if jit_off then
            jit_off()
         end
         local results = luamark.compare_memory(funcs, opts)
         if jit_on then
            jit_on()
         end
         return results
      end,
      label = "memory",
   },
}

-- ----------------------------------------------------------------------------
-- Framework Registry
-- ----------------------------------------------------------------------------

local MODULES = {
   ["ecs-lua"] = require("src.frameworks.ecs-lua"),
   concord = require("src.frameworks.concord"),
   evolved = require("src.frameworks.evolved"),
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

-- ----------------------------------------------------------------------------
-- Helper Functions
-- ----------------------------------------------------------------------------

--- Return total test count after applying filters.
--- @param groups_to_run BenchmarkGroup[] Groups to run.
--- @param test_filter? table<string, boolean> Test name filter set.
--- @return number
local function count_tests(groups_to_run, test_filter)
   local count = 0
   for _, group in ipairs(groups_to_run) do
      for _, test in ipairs(group.tests) do
         if not test_filter or test_filter[test] then
            count = count + 1
         end
      end
   end
   return count
end

--- Collect benchmark specs for a given test across frameworks.
--- @param framework_names string[] Framework names to check.
--- @param group_name string Test group name.
--- @param test_name string Test name.
--- @return table<string, luamark.Spec>
local function collect_specs(framework_names, group_name, test_name)
   local specs = {}
   for _, name in ipairs(framework_names) do
      local grouped_tests = FRAMEWORKS[name]
      local group_tests = grouped_tests and grouped_tests[group_name]
      local spec = group_tests and group_tests[test_name]
      if spec then
         specs[name] = spec
      end
   end
   return specs
end

--- Compute entity-count-weighted total for progress bar.
--- Each result row contributes its entity count to the total,
--- so higher entity counts (which take longer) get proportionally more weight.
--- @param groups_to_run BenchmarkGroup[] Groups to run.
--- @param test_filter? table<string, boolean> Test name filter set.
--- @param framework_names string[] Framework names to check.
--- @param entity_counts number[] Entity counts to benchmark.
--- @return number
local function compute_total_weight(groups_to_run, test_filter, framework_names, entity_counts)
   local entity_sum = 0
   for i = 1, #entity_counts do
      entity_sum = entity_sum + entity_counts[i]
   end

   local total = 0
   for _, group in ipairs(groups_to_run) do
      for _, test_name in ipairs(group.tests) do
         if not test_filter or test_filter[test_name] then
            local specs = collect_specs(framework_names, group.name, test_name)
            local n_frameworks = 0
            for _ in pairs(specs) do
               n_frameworks = n_frameworks + 1
            end
            -- 2 benchmark types (time, memory) × frameworks × entity count sum
            total = total + 2 * n_frameworks * entity_sum
         end
      end
   end
   return total
end

--- Log benchmark info to stdout when progress bar is disabled.
--- @param specs table<string, table> Framework specs.
--- @param test_name string Test name (e.g., "entity/create_empty").
local function log_benchmark_info(specs, test_name)
   local names = utils.keys(specs)
   table.sort(names)

   utils.printf("[%s] Running %d frameworks: %s", test_name, #names, table.concat(names, ", "))
end

-- ----------------------------------------------------------------------------
-- Benchmark Runner
-- ----------------------------------------------------------------------------

--- Execute time and memory benchmarks, appending results to all_stats.
--- @param specs table<string, luamark.Spec> Framework specs to benchmark.
--- @param counts number[] Entity counts to benchmark.
--- @param group_name string Test group name.
--- @param test_name string Test name within group.
--- @param all_stats table[] Accumulator for CSV rows.
--- @param show_log boolean Show log output.
--- @param on_result? fun(n_entities: number, label: string) Per-result callback.
local function run_benchmarks(specs, counts, group_name, test_name, all_stats, show_log, on_result)
   local full_name = group_name .. "/" .. test_name
   if show_log then
      log_benchmark_info(specs, full_name)
   end

   local params = { params = { n_entities = counts } }

   for _, bench in ipairs(BENCHMARK_TYPES) do
      collectgarbage("collect")
      for _, r in ipairs(bench.fn(specs, params)) do
         all_stats[#all_stats + 1] = {
            r.params.n_entities,
            group_name,
            test_name,
            r.name,
            r.unit,
            r.timestamp,
            r.median,
            r.ci_lower,
            r.ci_upper,
            r.rounds,
         }
         if on_result then
            on_result(r.params.n_entities, bench.label)
         end
      end
   end
end

--- Run benchmarks and write results to CSV.
--- @param output? string Output CSV file path.
--- @param framework_names? string[] Framework names to benchmark.
--- @param group_filter? BenchmarkGroup[] Groups to run.
--- @param test_filter? table<string, boolean> Test name filter set.
--- @param entity_counts? number[] Entity counts to benchmark.
--- @param opts? { no_progress?: boolean } Options.
local function main(output, framework_names, group_filter, test_filter, entity_counts, opts)
   opts = opts or {}
   framework_names = framework_names or FRAMEWORK_NAMES
   group_filter = group_filter or GROUPS
   entity_counts = entity_counts or ENTITY_COUNTS

   local all_stats = {}
   local total_tests = count_tests(group_filter, test_filter)
   local total_weight =
      compute_total_weight(group_filter, test_filter, framework_names, entity_counts)
   local bar = Progress({
      total = total_weight,
      template = "{bar} {pct} | {msg} | {elapsed} < {eta}",
      disable = opts.no_progress,
   })
   bar:start()

   local show_log = bar.disable
   local progress_weight = 0

   for _, group in ipairs(group_filter) do
      local group_name = group.name

      for _, test_name in ipairs(group.tests) do
         if not test_filter or test_filter[test_name] then
            local specs = collect_specs(framework_names, group_name, test_name)
            local full_name = group_name .. "/" .. test_name

            if next(specs) then
               run_benchmarks(
                  specs,
                  entity_counts,
                  group_name,
                  test_name,
                  all_stats,
                  show_log,
                  function(n_entities, label)
                     progress_weight = progress_weight + n_entities
                     bar:update(progress_weight, string.format("%s (%s)", full_name, label))
                  end
               )
            end
         end
      end
   end

   bar:stop(string.format("Completed %d tests in {elapsed}", total_tests * 2))

   if output then
      utils.write_csv(all_stats, output, HEADERS, ",")
      print("Wrote results to " .. output)
   end
end

-- ----------------------------------------------------------------------------
-- CLI
-- ----------------------------------------------------------------------------

local MODULE_NAMES = utils.keys(MODULES)

local GROUP_NAMES = {}
local ALL_TESTS = {}
for _, group in ipairs(GROUPS) do
   GROUP_NAMES[#GROUP_NAMES + 1] = group.name
   for _, test in ipairs(group.tests) do
      ALL_TESTS[#ALL_TESTS + 1] = test
   end
end

--- Parse CLI arguments and run benchmarks.
local function cli()
   local desc = "Benchmark ECS (Entity-Component-System)-Frameworks in Lua"
   local parser = argparse("lua-ecs-benchmark", desc)
   parser:option("-o --output", "CSV file where the results will be saved."):convert(utils.mkdir)
   parser
      :option("--framework", "ECS frameworks to benchmark")
      :choices(MODULE_NAMES)
      :default(MODULE_NAMES)
      :args("+")
   parser:option("--group", "Test groups to run"):choices(GROUP_NAMES):args("*")
   parser:option("--test", "Tests to run"):choices(ALL_TESTS):args("*")
   parser
      :option("-n --entities", "Entity counts to benchmark")
      :convert(tonumber)
      :default(ENTITY_COUNTS)
      :args("+")
   parser:flag("--no-progress", "Disable live progress display")
   local args = parser:parse()

   local frameworks = utils.expand_names(args.framework, FRAMEWORK_ALIASES)

   local group_filter = GROUPS
   if args.group and #args.group > 0 then
      local group_set = {}
      for _, g in ipairs(args.group) do
         group_set[g] = true
      end
      group_filter = {}
      for _, group in ipairs(GROUPS) do
         if group_set[group.name] then
            group_filter[#group_filter + 1] = group
         end
      end
   end

   local test_filter = nil
   if args.test and #args.test > 0 then
      test_filter = {}
      for _, t in ipairs(args.test) do
         test_filter[t] = true
      end
   end

   main(
      args.output,
      frameworks,
      group_filter,
      test_filter,
      args.entities,
      { no_progress = args.no_progress }
   )
end

cli()
