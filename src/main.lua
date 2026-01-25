local argparse = require("argparse")
local luamark = require("luamark")
local utils = require("src.utils")

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
   if mod.variants then
      FRAMEWORK_ALIASES[name] = {}
      for variant_name, tests in pairs(mod.variants) do
         FRAMEWORKS[variant_name] = tests
         FRAMEWORK_ALIASES[name][#FRAMEWORK_ALIASES[name] + 1] = variant_name
      end
   else
      FRAMEWORKS[name] = mod
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

local ENTITY_COUNTS = { 10, 100, 1000, 10000, 100000 }

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

--- Run time and memory benchmarks for a set of specs, logging progress.
--- @param specs table<string, table> Framework specs to benchmark.
--- @param counts number[] Entity counts to benchmark.
--- @param test_name string Name of the test.
--- @param all_stats table[] Accumulator for results.
--- @param max_entities? number Optional max_entities limit for logging.
local function run_benchmarks(specs, counts, test_name, all_stats, max_entities)
   local names = utils.keys(specs)
   table.sort(names)

   local limit_info = max_entities and string.format(" (max_entities=%d)", max_entities) or ""
   utils.printf(
      "[%s] Running %d frameworks%s: %s\n",
      test_name,
      #names,
      limit_info,
      table.concat(names, ", ")
   )

   local params = { params = { n_entities = counts } }

   for _, benchmark_fn in ipairs({ luamark.compare_time, luamark.compare_memory }) do
      collectgarbage("collect")
      for _, result in ipairs(benchmark_fn(specs, params)) do
         all_stats[#all_stats + 1] = {
            result.n_entities,
            test_name,
            result.name,
            result.unit,
            result.timestamp,
            result.median,
            result.ci_lower,
            result.ci_upper,
            result.rounds,
         }
      end
   end
end

--- Filter entity counts to those at or below a limit.
--- @param counts number[] Entity counts.
--- @param limit number Maximum allowed count.
--- @return number[] Filtered counts.
local function filter_counts(counts, limit)
   local filtered = {}
   for _, n in ipairs(counts) do
      if n <= limit then
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
local function main(output, framework_names, tests, entity_counts)
   framework_names = framework_names or FRAMEWORK_NAMES
   tests = tests or TESTS
   entity_counts = entity_counts or ENTITY_COUNTS

   local all_stats = {}
   local max_count = entity_counts[#entity_counts]

   for _, test_name in ipairs(tests) do
      -- Group frameworks by max_entities limit
      local groups = {} -- limit -> { name = spec, ... }

      for _, name in ipairs(framework_names) do
         local spec = FRAMEWORKS[name] and FRAMEWORKS[name][test_name]
         if spec then
            local limit = spec.max_entities
            if not limit or limit >= max_count then
               limit = "unlimited"
            end
            groups[limit] = groups[limit] or {}
            groups[limit][name] = spec
         end
      end

      -- Run each group with appropriate entity counts
      for limit, specs in pairs(groups) do
         if limit == "unlimited" then
            run_benchmarks(specs, entity_counts, test_name, all_stats, nil)
         else
            local counts = filter_counts(entity_counts, limit)
            if #counts > 0 then
               run_benchmarks(specs, counts, test_name, all_stats, limit)
            end
         end
      end
   end

   if output then
      utils.write_csv(all_stats, output, HEADERS, ",")
      print("\nWrote results to " .. output)
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
   local args = parser:parse()

   -- Expand aliases (e.g., "ecs-lua" -> {"ecs-lua-batch", "ecs-lua-nobatch"})
   local frameworks = utils.expand_names(args.framework, FRAMEWORK_ALIASES)

   main(args.output, frameworks, args.test, args.entities)
end

cli()
