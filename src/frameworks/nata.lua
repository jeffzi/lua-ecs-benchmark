---@diagnostic disable: unused-local
local config = require("src.lib.config")
local nata = require("lib.nata.nata")
local shuffle = require("src.lib.utils").shuffle

local nata_new = nata.new

local DT = config.DT
local WORLD_MULTIPLIER = config.WORLD_MULTIPLIER

-- ----------------------------------------------------------------------------
-- Setup
-- ----------------------------------------------------------------------------

local function make_default_entity()
   return {
      Position = { x = 0.0, y = 0.0 },
      Velocity = { x = 0.0, y = 0.0 },
      Alive = true,
   }
end

--- Factory: returns a `before` function that creates a populated pool.
--- (WORLD_MULTIPLIER - 1) * N background + N tracked entities.
--- @param make_entity? fun(): table Factory for tracked entities.
--- @return fun(_ctx: table, p: { n_entities: number }): { pool: table, entities: table[] }
local function create_world(make_entity)
   make_entity = make_entity or make_default_entity
   return function(_ctx, p)
      -- Disable default OOP system: it fires on every 'add' event during flush,
      -- iterating all entities per insertion → O(N²).
      local pool = nata_new({ systems = {} })

      -- Background entities
      for _ = 1, p.n_entities * (WORLD_MULTIPLIER - 1) do
         pool:queue({
            Health = { current = 100, max = 100 },
            Name = { value = "monster" },
            Aggro = true,
         })
      end

      -- Tracked entities for test operations
      local entities = {}
      for i = 1, p.n_entities do
         entities[i] = pool:queue(make_entity())
      end

      pool:flush()
      shuffle(entities)
      return { pool = pool, entities = entities }
   end
end

--- Clear the pool.
--- @param ctx { pool: table } Context with pool.
local function clear_pool(ctx)
   ctx.pool = nil
   ctx.entities = nil
end

local BUFF_NAMES = config.generate_buff_names(config.N_BUFFS)

-- ----------------------------------------------------------------------------
-- Entity Tests
-- ----------------------------------------------------------------------------

--- @type BenchmarkTests
local entity = {
   create_empty = {
      fn = function(ctx, p)
         local pool = ctx.pool
         for _ = 1, p.n_entities do
            pool:queue({})
         end
         pool:flush()
      end,
      before = create_world(),
      after = clear_pool,
   },

   create_with_components = {
      fn = function(ctx, p)
         local pool = ctx.pool
         for _ = 1, p.n_entities do
            pool:queue({
               Position = { x = 0, y = 0 },
               Alive = true,
            })
         end
         pool:flush()
      end,
      before = create_world(),
      after = clear_pool,
   },

   destroy = {
      fn = function(ctx, _p)
         local pool, entities = ctx.pool, ctx.entities
         local entity_set = {}
         for i = 1, #entities do
            entity_set[entities[i]] = true
         end
         pool:remove(function(e)
            return entity_set[e]
         end)
      end,
      before = create_world(),
      after = clear_pool,
   },
}

-- ----------------------------------------------------------------------------
-- Component Tests
-- ----------------------------------------------------------------------------

--- @type BenchmarkTests
local component = {
   get = {
      fn = function(ctx, _p)
         local entities = ctx.entities
         for i = 1, #entities do
            local pos = entities[i].Position
            local _ = pos.x
            local _ = pos.y
         end
      end,
      before = create_world(),
      after = clear_pool,
   },

   set = {
      fn = function(ctx, _p)
         local entities = ctx.entities
         for i = 1, #entities do
            local pos = entities[i].Position
            pos.x = 1.0
            pos.y = 1.0
         end
      end,
      before = create_world(),
      after = clear_pool,
   },

   add = {
      fn = function(ctx, _p)
         local pool, entities = ctx.pool, ctx.entities
         for i = 1, #entities do
            entities[i].Name = { value = "monster" }
            pool:queue(entities[i])
         end
         pool:flush()
      end,
      before = create_world(),
      after = clear_pool,
   },

   remove = {
      fn = function(ctx, _p)
         local pool, entities = ctx.pool, ctx.entities
         for i = 1, #entities do
            entities[i].Velocity = nil
            pool:queue(entities[i])
         end
         pool:flush()
      end,
      before = create_world(),
      after = clear_pool,
   },
}

-- ----------------------------------------------------------------------------
-- Tag Tests
-- ----------------------------------------------------------------------------

--- @type BenchmarkTests
local tag = {
   has = {
      fn = function(ctx, _p)
         local entities = ctx.entities
         for i = 1, #entities do
            local _ = entities[i].Alive ~= nil
         end
      end,
      before = create_world(),
      after = clear_pool,
   },

   add = {
      fn = function(ctx, _p)
         local pool, entities = ctx.pool, ctx.entities
         for i = 1, #entities do
            entities[i].Aggro = true
            pool:queue(entities[i])
         end
         pool:flush()
      end,
      before = create_world(),
      after = clear_pool,
   },

   remove = {
      fn = function(ctx, _p)
         local pool, entities = ctx.pool, ctx.entities
         for i = 1, #entities do
            entities[i].Alive = nil
            pool:queue(entities[i])
         end
         pool:flush()
      end,
      before = create_world(),
      after = clear_pool,
   },
}

-- ----------------------------------------------------------------------------
-- System Tests
-- ----------------------------------------------------------------------------

--- @type BenchmarkTests
local system = {
   throughput = {
      fn = function(ctx, _p)
         ctx.pool:emit("update", DT)
      end,
      before = function(_ctx, p)
         local MovementSystem = {}
         function MovementSystem:update(dt)
            local entities = self.pool.groups.move.entities
            for i = 1, #entities do
               local e = entities[i]
               local position = e.Position
               local velocity = e.Velocity
               position.x = position.x + velocity.x * dt
               position.y = position.y + velocity.y * dt
            end
         end

         local pool = nata_new({
            groups = { move = { filter = { "Position", "Velocity" } } },
            systems = { MovementSystem },
         })

         for _ = 1, p.n_entities do
            pool:queue({
               Position = { x = 0.0, y = 0.0 },
               Velocity = { x = 0.0, y = 0.0 },
            })
         end
         pool:flush()
         pool:emit("update", DT)
         return { pool = pool }
      end,
      after = clear_pool,
   },

   overlap = {
      fn = function(ctx, _p)
         ctx.pool:emit("update", DT)
      end,
      before = function(_ctx, p)
         local SwapAB = {}
         function SwapAB:update(_dt)
            local entities = self.pool.groups.ab.entities
            for i = 1, #entities do
               local e = entities[i]
               e.A.v, e.B.v = e.B.v, e.A.v
            end
         end

         local SwapCD = {}
         function SwapCD:update(_dt)
            local entities = self.pool.groups.cd.entities
            for i = 1, #entities do
               local e = entities[i]
               e.C.v, e.D.v = e.D.v, e.C.v
            end
         end

         local SwapCE = {}
         function SwapCE:update(_dt)
            local entities = self.pool.groups.ce.entities
            for i = 1, #entities do
               local e = entities[i]
               e.C.v, e.E.v = e.E.v, e.C.v
            end
         end

         local pool = nata_new({
            groups = {
               ab = { filter = { "A", "B" } },
               cd = { filter = { "C", "D" } },
               ce = { filter = { "C", "E" } },
            },
            systems = { SwapAB, SwapCD, SwapCE },
         })

         for i = 1, p.n_entities do
            local archetype = i % 4
            local e = pool:queue({
               A = { v = 0 },
               B = { v = 0 },
            })
            if archetype >= 1 then
               e.C = { v = 0 }
            end
            if archetype >= 2 then
               e.D = { v = 0 }
            end
            if archetype == 3 then
               e.D = nil
               e.E = { v = 0 }
            end
         end
         pool:flush()
         pool:emit("update", DT)

         return { pool = pool }
      end,
      after = clear_pool,
   },

   fragmented = {
      fn = function(ctx, _p)
         ctx.pool:emit("update", DT)
      end,
      before = function(_ctx, p)
         local sum = 0

         local PositionSystem = {}
         function PositionSystem:update(_dt)
            local entities = self.pool.groups.position.entities
            for i = 1, #entities do
               local pos = entities[i].Position
               sum = sum + pos.x + pos.y
            end
         end

         local Buff1System = {}
         function Buff1System:update(_dt)
            local entities = self.pool.groups.buff1.entities
            for i = 1, #entities do
               sum = sum + entities[i].Buff1.level
            end
         end

         local pool = nata_new({
            groups = {
               position = { filter = { "Position" } },
               buff1 = { filter = { "Buff1" } },
            },
            systems = { PositionSystem, Buff1System },
         })

         for i = 1, p.n_entities do
            local buff_index = ((i - 1) % #BUFF_NAMES) + 1
            local e = pool:queue({
               Position = { x = 0.0, y = 0.0 },
            })
            e[BUFF_NAMES[buff_index]] = { level = buff_index }
         end
         pool:flush()
         pool:emit("update", DT)
         return { pool = pool }
      end,
      after = clear_pool,
   },

   chained = {
      fn = function(ctx, _p)
         ctx.pool:emit("update", DT)
      end,
      before = function(_ctx, p)
         local SysAB = {}
         function SysAB:update(_dt)
            local entities = self.pool.groups.ab.entities
            for i = 1, #entities do
               local e = entities[i]
               e.B.v = e.A.v
            end
         end

         local SysBC = {}
         function SysBC:update(_dt)
            local entities = self.pool.groups.bc.entities
            for i = 1, #entities do
               local e = entities[i]
               e.C.v = e.B.v
            end
         end

         local SysCD = {}
         function SysCD:update(_dt)
            local entities = self.pool.groups.cd.entities
            for i = 1, #entities do
               local e = entities[i]
               e.D.v = e.C.v
            end
         end

         local SysDE = {}
         function SysDE:update(_dt)
            local entities = self.pool.groups.de.entities
            for i = 1, #entities do
               local e = entities[i]
               e.E.v = e.D.v
            end
         end

         local pool = nata_new({
            groups = {
               ab = { filter = { "A", "B" } },
               bc = { filter = { "B", "C" } },
               cd = { filter = { "C", "D" } },
               de = { filter = { "D", "E" } },
            },
            systems = { SysAB, SysBC, SysCD, SysDE },
         })

         for _ = 1, p.n_entities do
            pool:queue({
               A = { v = 1 },
               B = { v = 0 },
               C = { v = 0 },
               D = { v = 0 },
               E = { v = 0 },
            })
         end
         pool:flush()
         pool:emit("update", DT)

         return { pool = pool }
      end,
      after = clear_pool,
   },

   multi_20 = {
      fn = function(ctx, _p)
         ctx.pool:emit("update", DT)
      end,
      before = function(_ctx, p)
         local systems = {}
         local groups = {}

         local comp_names = {
            "Comp1",
            "Comp2",
            "Comp3",
            "Comp4",
            "Comp5",
            "Comp6",
            "Comp7",
            "Comp8",
            "Comp9",
            "Comp10",
         }

         local sum = 0

         for _, comp_name in ipairs(comp_names) do
            local group_name = string.lower(comp_name)
            groups[group_name] = { filter = { comp_name } }

            local sys1 = {}
            function sys1:update(_dt)
               local entities = self.pool.groups[group_name].entities
               for i = 1, #entities do
                  sum = sum + entities[i][comp_name].value
               end
            end
            systems[#systems + 1] = sys1

            local sys2 = {}
            function sys2:update(_dt)
               local entities = self.pool.groups[group_name].entities
               for i = 1, #entities do
                  sum = sum + entities[i][comp_name].value
               end
            end
            systems[#systems + 1] = sys2
         end

         local pool = nata_new({
            groups = groups,
            systems = systems,
         })

         for _ = 1, p.n_entities do
            pool:queue({
               Comp1 = { value = 0 },
               Comp2 = { value = 0 },
               Comp3 = { value = 0 },
               Comp4 = { value = 0 },
               Comp5 = { value = 0 },
               Comp6 = { value = 0 },
               Comp7 = { value = 0 },
               Comp8 = { value = 0 },
               Comp9 = { value = 0 },
               Comp10 = { value = 0 },
            })
         end
         pool:flush()
         pool:emit("update", DT)
         return { pool = pool }
      end,
      after = clear_pool,
   },

   empty_systems = {
      fn = function(ctx, _p)
         ctx.pool:emit("update", DT)
      end,
      before = function(_ctx, p)
         local systems = {}
         for _ = 1, 20 do
            local sys = {}
            function sys:update(dt)
               local entities = self.pool.groups.nonexistent.entities
               for i = 1, #entities do
                  local e = entities[i]
                  e.NonExistent.value = e.NonExistent.value + dt
               end
            end
            systems[#systems + 1] = sys
         end

         local pool = nata_new({
            groups = {
               nonexistent = { filter = { "NonExistent" } },
            },
            systems = systems,
         })

         for _ = 1, p.n_entities do
            pool:queue({
               Position = { x = 0.0, y = 0.0 },
            })
         end
         pool:flush()
         pool:emit("update", DT)
         return { pool = pool }
      end,
      after = clear_pool,
   },
}

-- ----------------------------------------------------------------------------
-- Module Export
-- ----------------------------------------------------------------------------

--- @type BenchmarkModule
return {
   entity = entity,
   component = component,
   tag = tag,
   system = system,
}
