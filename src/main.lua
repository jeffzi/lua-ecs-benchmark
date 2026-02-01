local Progress = require("src.lib.progress")
local argparse = require("argparse")
local luamark = require("luamark")
local utils = require("src.lib.utils")

-- ----------------------------------------------------------------------------
-- Configuration
-- ----------------------------------------------------------------------------

local ENTITY_COUNTS = { 10, 100, 1000, 10000 }

local GROUPS = {
   { name = "entity", tests = { "create_empty", "create_with_components", "destroy" } },
   {
      name = "component",
      tests = { "get", "get_multi", "add", "add_multi", "remove", "remove_multi" },
   },
   { name = "system", tests = { "update" } },
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

local BENCHMARK_TYPES = {
   { fn = luamark.compare_time, label = "time" },
   { fn = luamark.compare_memory, label = "memory" },
}

-- ----------------------------------------------------------------------------
-- Framework Registry
-- ----------------------------------------------------------------------------

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

-- ----------------------------------------------------------------------------
-- Helper Functions
-- ----------------------------------------------------------------------------

--- Return entity counts at or below max_allowed.
--- @param counts number[] Entity counts.
--- @param max_allowed number Maximum allowed count.
--- @return number[]
local function filter_counts(counts, max_allowed)
   local filtered = {}
   for _, n in ipairs(counts) do
      if n <= max_allowed then
         filtered[#filtered + 1] = n
      end
   end
   return filtered
end

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

--- Group frameworks by their max_entities limit for a given test.
--- @param framework_names string[] Framework names to check.
--- @param group_name string Test group name.
--- @param test_name string Test name.
--- @param max_count number Maximum entity count being benchmarked.
--- @return table<number|"unlimited", table<string, BenchmarkSpec>>
local function group_by_entity_limit(framework_names, group_name, test_name, max_count)
   local groups = {}
   for _, name in ipairs(framework_names) do
      local grouped_tests = FRAMEWORKS[name]
      local group_tests = grouped_tests and grouped_tests[group_name]
      local spec = group_tests and group_tests[test_name]
      if spec then
         local limit = spec.max_entities
         if limit and limit < max_count then
            groups[limit] = groups[limit] or {}
            groups[limit][name] = spec
         else
            groups.unlimited = groups.unlimited or {}
            groups.unlimited[name] = spec
         end
      end
   end
   return groups
end

--- Log benchmark info to stdout when progress bar is disabled.
--- @param specs table<string, table> Framework specs.
--- @param test_name string Test name (e.g., "entity/create_empty").
--- @param max_entities? number Max entities limit for display.
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

-- ----------------------------------------------------------------------------
-- Benchmark Runner
-- ----------------------------------------------------------------------------

--- Execute time and memory benchmarks, appending results to all_stats.
--- @param specs table<string, table> Framework specs to benchmark.
--- @param counts number[] Entity counts to benchmark.
--- @param group_name string Test group name.
--- @param test_name string Test name within group.
--- @param all_stats table[] Accumulator for CSV rows.
--- @param max_entities? number Max entities limit for logging.
--- @param show_log boolean Show log output.
--- @param on_benchmark? fun(label: string) Callback after each benchmark type.
local function run_benchmarks(
   specs,
   counts,
   group_name,
   test_name,
   all_stats,
   max_entities,
   show_log,
   on_benchmark
)
   local full_name = group_name .. "/" .. test_name
   if show_log then
      log_benchmark_info(specs, full_name, max_entities)
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
      end
      if on_benchmark then
         on_benchmark(bench.label)
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
   local max_count = entity_counts[#entity_counts]
   local total_tests = count_tests(group_filter, test_filter)
   local bar = Progress({
      total = total_tests * 2,
      template = "{bar} {pct} | {msg} | {elapsed} < {eta}",
      disable = opts.no_progress,
   })
   bar:start()

   local show_log = bar.disable
   local progress_count = 0

   for _, group in ipairs(group_filter) do
      local group_name = group.name

      for _, test_name in ipairs(group.tests) do
         if not test_filter or test_filter[test_name] then
            local entity_limit_groups =
               group_by_entity_limit(framework_names, group_name, test_name, max_count)

            local full_name = group_name .. "/" .. test_name
            local function on_benchmark(label)
               progress_count = progress_count + 1
               bar:update(progress_count, string.format("%s (%s)", full_name, label))
            end

            -- Run unlimited frameworks first (all entity counts)
            if entity_limit_groups.unlimited then
               run_benchmarks(
                  entity_limit_groups.unlimited,
                  entity_counts,
                  group_name,
                  test_name,
                  all_stats,
                  nil,
                  show_log,
                  on_benchmark
               )
               entity_limit_groups.unlimited = nil
            end

            -- Run limited frameworks with filtered entity counts
            for limit, specs in pairs(entity_limit_groups) do
               if type(limit) == "number" then
                  local counts = filter_counts(entity_counts, limit)
                  if #counts > 0 then
                     run_benchmarks(
                        specs,
                        counts,
                        group_name,
                        test_name,
                        all_stats,
                        limit,
                        show_log,
                        on_benchmark
                     )
                  end
               end
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

local CLI_FRAMEWORK_CHOICES = utils.concat(FRAMEWORK_NAMES, utils.keys(FRAMEWORK_ALIASES))

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
      :choices(CLI_FRAMEWORK_CHOICES)
      :default(CLI_FRAMEWORK_CHOICES)
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
