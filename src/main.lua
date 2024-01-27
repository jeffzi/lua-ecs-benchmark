local argparse = require("argparse")
local tablex = require("pl.tablex")
local printf = require("pl.utils").printf

local FRAMEWORKS = { tinyecs = require("src.tinyecs") }
local FRAMEWORK_NAMES = tablex.keys(FRAMEWORKS)

local TESTS = {
   "create_empty",
   "create_entities",
   "get_components",
   "remove_component",
   "query",
}

local N_ENTITIES = { 100, 1000, 10000, 100000, 1000000 }

--- @param frameworks? string[]
--- @param tests? string[]
local function main(frameworks, tests)
   frameworks = frameworks or FRAMEWORK_NAMES
   tests = tests or TESTS

   local total = tablex.size(frameworks) * tablex.size(tests) * tablex.size(N_ENTITIES)
   local i = 0

   for _, test_name in pairs(tests) do
      for _, framework_name in pairs(frameworks) do
         local framework = FRAMEWORKS[framework_name]

         for _, n_entities in pairs(N_ENTITIES) do
            i = i + 1

            printf(
               "[%d/%d][%s][%s] Benchmarking execution time: %d entities\n",
               i,
               total,
               test_name,
               framework_name,
               n_entities
            )

            local benchmark = framework[test_name](n_entities)
            local time_stats = benchmark:timeit()
            print(time_stats)
         end
      end
   end
end

local function cli()
   local desc = "Benchmark ECS (Entity-Component-System)-Frameworks in Lua"
   local parser = argparse("lua-ecs-benchmark", desc)
   parser
      :option("--framework", "ECS frameworks to benchmark")
      :choices(FRAMEWORK_NAMES)
      :default(FRAMEWORK_NAMES)
      :args("+")
   local args = parser:parse()

   main(args.framework)
end

cli()
