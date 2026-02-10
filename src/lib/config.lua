--- Benchmark configuration constants.
local config = {}

--- Multiplier for pre-populating worlds in entity/component tests.
--- Total world size = multiplier * N entities, with N tracked for operations.
config.WORLD_MULTIPLIER = 5

--- Delta time for system update ticks (60 FPS).
config.DT = 1 / 60

--- Number of unique tags for fragmented iteration tests.
config.N_TAGS = 20

--- Default entity counts for benchmarks.
config.ENTITY_COUNTS = { 100, 1000, 10000, 50000 }

--- Generate array of tag names {"Tag1", "Tag2", ..., "TagN"}.
--- @param n number Number of tags to generate.
--- @return string[] Array of tag name strings.
function config.generate_tag_names(n)
   local tags = {}
   for i = 1, n do
      tags[i] = "Tag" .. i
   end
   return tags
end

return config
