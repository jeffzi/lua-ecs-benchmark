--- Benchmark configuration constants.
local config = {}

--- Multiplier for pre-populating worlds in entity/component tests.
--- Total world size = multiplier * N entities, with N tracked for operations.
config.WORLD_MULTIPLIER = 5

--- Delta time for system update ticks (60 FPS).
config.DT = 1 / 60

--- Number of unique buff components for fragmented iteration tests.
config.N_BUFFS = 20

--- Number of background systems for structural scaling tests.
config.N_SYSTEMS = 20

--- Default entity counts for benchmarks.
config.ENTITY_COUNTS = { 100, 1000, 10000 }

--- Generate array of buff names {"Buff1", "Buff2", ..., "BuffN"}.
--- @param n number Number of buffs to generate.
--- @return string[] Array of buff name strings.
function config.generate_buff_names(n)
   local buffs = {}
   for i = 1, n do
      buffs[i] = "Buff" .. i
   end
   return buffs
end

return config
