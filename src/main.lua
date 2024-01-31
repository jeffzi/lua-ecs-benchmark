local argparse = require("argparse")
local tablex = require("pl.tablex")
local printf = require("pl.utils").printf
local data = require("pl.data")
local path = require("pl.path")

local FRAMEWORKS = {
   ["ecs-lua"] = require("src.ecs-lua"),
   concord = require("src.concord"),
   echoes = require("src.echoes"),
   lovetoys = require("src.lovetoys"),
   nata = require("src.nata"),
   tinyecs = require("src.tinyecs"),
}
local FRAMEWORK_NAMES = tablex.keys(FRAMEWORKS)

local TESTS = {
   "create_empty_entity",
   "create_entities",
   "get_component",
   "get_components",
   "add_component",
   "add_components",
   "remove_component",
   "remove_components",
   "system_update",
}

local N_ENTITIES = { 10, 100, 1000, 10000, 100000, 1000000 }

local HEADERS = {
   "n_entities",
   "test",
   "framework",
   "unit",
   "timestamp",
   "median",
   "mean",
   "stddev",
   "min",
   "max",
   "rounds",
}

--- @param num integer
--- @param precision integer
--- @return string
local function format_number(num, precision)
   local formatted, _ = string.format("%." .. precision .. "f", num):gsub("%.?0+$", "")
   return formatted
end

--- Convert benchmark results to a table compatbile with pl.array2d.
--- @param stats table
--- @param extra table
--- @return table
local function to_array2d(stats, extra)
   local array2d = {}

   for key, value in pairs(extra) do
      stats[key] = value
   end

   local value
   for i = 1, #HEADERS do
      value = stats[HEADERS[i]]
      if value ~= nil then
         if type(value) == "number" then
            value = format_number(value, stats.precision)
         end
         table.insert(array2d, value)
      end
   end
   return array2d
end

--- @param output? string
--- @param frameworks? string[]
--- @param tests? string[]
local function main(output, frameworks, tests)
   frameworks = frameworks or FRAMEWORK_NAMES
   tests = tests or TESTS

   local stats = {}
   local total = tablex.size(frameworks) * tablex.size(tests) * tablex.size(N_ENTITIES)
   local i = 0
   local framework, benchmark_cls, benchmark, row, extra
   for _, n_entities in pairs(N_ENTITIES) do
      extra = { n_entities = n_entities }

      for _, test_name in pairs(tests) do
         extra["test"] = test_name

         for _, framework_name in pairs(frameworks) do
            i = i + 1
            framework = FRAMEWORKS[framework_name]
            benchmark_cls = framework[test_name]

            printf(
               "[%d/%d][%d entities][%s]: %s\n",
               i,
               total,
               n_entities,
               test_name,
               benchmark_cls and framework_name
                  or (framework_name .. "." .. test_name .. " not found, skipping")
            )

            if benchmark_cls then
               extra["framework"] = framework_name
               benchmark = benchmark_cls(n_entities)

               row = benchmark:timeit()
               extra["unit"] = "s"
               table.insert(stats, to_array2d(row, extra))

               row = benchmark:memit()
               extra["unit"] = "kb"
               table.insert(stats, to_array2d(row, extra))
            end
         end
      end
   end

   if output then
      data.write(stats, output, HEADERS, ",")
      print("\nWrote results to " .. output)
   end
end

--- Ensure that base directory exists and convert it to absolute path.
--- @param filepath string
--- @return string
local function mkdir(filepath)
   local dir = path.dirname(filepath)
   if not path.exists(dir) then
      path.mkdir(dir)
   end
   return filepath
end

local function cli()
   local desc = "Benchmark ECS (Entity-Component-System)-Frameworks in Lua"
   local parser = argparse("lua-ecs-benchmark", desc)
   parser:option("-o --output", "CSV file where the results will be saved."):convert(mkdir)
   parser
      :option("--framework", "ECS frameworks to benchmark")
      :choices(FRAMEWORK_NAMES)
      :default(FRAMEWORK_NAMES)
      :args("+")
   local args = parser:parse()

   main(args.output, args.framework)
end

cli()
