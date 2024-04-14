local class = require("pl.class")
local luamark = require("luamark")

--- @class Benchmark

--- Class for running and timing benchmarks.
--- @field n_entities number: The number of entities to be used in the benchmark.
local Benchmark = class()

--- Benchmark constructor.
--- Initializes a new instance of the Benchmark class with a specified number of entities.
--- @param n_entities number: The number of entities to be used in the benchmark.
function Benchmark:_init(n_entities)
   self.n_entities = n_entities
end

--- Abstract method to run the function to be measured.
--- This function should be implemented in derived classes to perform the actual benchmarking task.
function Benchmark:run()
   local info = debug.getinfo(1, "n")
   error(info.name .. ":run not implemented")
end

--- Setup method to execute before each execution of `run`
--- This function can be overridden in derived classes to perform any iteration_setup required before the benchmark run.
function Benchmark:iteration_setup() end

--- Teardown method to execute after each execution of `run`
--- This function can be overridden in derived classes to perform any cleanup required after the benchmark run.
function Benchmark:iteration_teardown() end

--- Setup method to execute before the first execution of `run`
--- This function can be overridden in derived classes to perform any iteration_setup required before the benchmark run.
function Benchmark:global_setup() end

--- Teardown method to execute after the last execution of `run`
--- This function can be overridden in derived classes to perform any cleanup required after the benchmark run.
function Benchmark:global_teardown() end

---@param measure_func function The measurement function to use.
function Benchmark:_measure(measure_func)
   self:global_setup()
   local stats = measure_func(function()
      self:run()
   end, {
      setup = function()
         self:iteration_setup()
      end,
      teardown = function()
         self:iteration_teardown()
      end,
   })
   self:global_teardown()
   return stats
end

--- Runs the benchmark a specified number of times and measures the execution time.
--- This method sets up the benchmark, runs it for the specified number of entities, and then tears it down.
--- @vararg any: Optional arguments that can be passed to the 'luamark.timeit' method.
--- @return table: Returns a table containing statistics about the benchmark run (such as time taken).
function Benchmark:timeit()
   return self:_measure(luamark.timeit)
end

--- Runs the benchmark a specified number of times and measures the memory usage.
--- This method sets up the benchmark, runs it for the specified number of entities, and then tears it down.
--- @vararg any: Optional arguments that can be passed to the 'luamark.memit' method.
--- @return table: Returns a table containing statistics about the benchmark run (such as time taken).
function Benchmark:memit()
   return self:_measure(luamark.memit)
end

return Benchmark
