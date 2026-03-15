---@diagnostic disable: unused-local
local Concord = require("lib.Concord.concord.init")
local config = require("src.lib.config")
local utils = require("src.lib.utils")

local shuffle = utils.shuffle
local unpack = utils.unpack

local concord_component = Concord.component
local concord_entity = Concord.entity
local concord_system = Concord.system
local concord_world = Concord.world

local DT = config.DT
local WORLD_MULTIPLIER = config.WORLD_MULTIPLIER
local N_SYSTEMS = config.N_SYSTEMS
local ORIGINAL_SERIALIZE = concord_entity.SERIALIZE_BY_DEFAULT

-- ----------------------------------------------------------------------------
-- Setup
-- ----------------------------------------------------------------------------

concord_component("Position", function(c, x, y)
   c.x = x or 0
   c.y = y or 0
end)

concord_component("Velocity", function(c, x, y)
   c.x = x or 0
   c.y = y or 0
end)

concord_component("Health", function(c, current, max)
   c.current = current or 100
   c.max = max or 100
end)

concord_component("Name", function(c, value)
   c.value = value or ""
end)

concord_component("Aggro")
concord_component("Alive")

concord_component("A", function(c, v)
   c.v = v or 0
end)
concord_component("B", function(c, v)
   c.v = v or 0
end)
concord_component("C", function(c, v)
   c.v = v or 0
end)
concord_component("D", function(c, v)
   c.v = v or 0
end)
concord_component("E", function(c, v)
   c.v = v or 0
end)

-- Components for multi-system tests (Comp1-Comp10)
concord_component("Comp1", function(c, v)
   c.value = v or 0
end)
concord_component("Comp2", function(c, v)
   c.value = v or 0
end)
concord_component("Comp3", function(c, v)
   c.value = v or 0
end)
concord_component("Comp4", function(c, v)
   c.value = v or 0
end)
concord_component("Comp5", function(c, v)
   c.value = v or 0
end)
concord_component("Comp6", function(c, v)
   c.value = v or 0
end)
concord_component("Comp7", function(c, v)
   c.value = v or 0
end)
concord_component("Comp8", function(c, v)
   c.value = v or 0
end)
concord_component("Comp9", function(c, v)
   c.value = v or 0
end)
concord_component("Comp10", function(c, v)
   c.value = v or 0
end)

concord_component("NonExistent", function(c, v)
   c.value = v or 0
end)

-- Buff components for archetype fragmentation tests
local BUFF_NAMES = config.generate_buff_names(config.N_BUFFS)
for _, name in ipairs(BUFF_NAMES) do
   concord_component(name, function(c, level)
      c.level = level or 0
   end)
end

local function make_default_entity(world)
   return concord_entity(world):give("Position", 0.0, 0.0):give("Velocity", 0.0, 0.0):give("Alive")
end

--- Factory: returns a `before` function that creates a populated world.
--- (WORLD_MULTIPLIER - 1) * N background + N tracked entities.
--- @param make_entity? fun(world: table): table Factory for tracked entities.
--- @return fun(_ctx: table, p: { n_entities: number }): { world: table, entities: table[] }
local function create_world(make_entity)
   make_entity = make_entity or make_default_entity
   return function(_ctx, p)
      local world = concord_world()

      -- Background entities
      for _ = 1, p.n_entities * (WORLD_MULTIPLIER - 1) do
         concord_entity(world):give("Health", 100, 100):give("Name", "monster"):give("Aggro")
      end

      -- Tracked entities for test operations
      local entities = {}
      for i = 1, p.n_entities do
         entities[i] = make_entity(world)
      end

      shuffle(entities)
      world:__flush()
      return { world = world, entities = entities }
   end
end

--- Clear the world.
--- @param ctx { world: table } Context with world.
local function clear_world(ctx)
   ctx.world:clear()
   ctx.world = nil
   ctx.entities = nil
end

-- ----------------------------------------------------------------------------
-- Entity Tests
-- ----------------------------------------------------------------------------

--- @type BenchmarkTests
local entity = {
   create_empty = {
      fn = function(ctx, p)
         local world = ctx.world
         for _ = 1, p.n_entities do
            concord_entity(world)
         end
         world:__flush()
      end,
      before = create_world(),
      after = clear_world,
   },

   create_with_components = {
      fn = function(ctx, p)
         local world = ctx.world
         for _ = 1, p.n_entities do
            concord_entity(world):give("Position", 0.0, 0.0):give("Alive")
         end
         world:__flush()
      end,
      before = create_world(),
      after = clear_world,
   },

   destroy = {
      fn = function(ctx, _p)
         local world, entities = ctx.world, ctx.entities
         for i = 1, #entities do
            world:removeEntity(entities[i])
         end
         world:__flush()
      end,
      before = create_world(),
      after = clear_world,
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
      after = clear_world,
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
      after = clear_world,
   },

   add = {
      fn = function(ctx, _p)
         local world, entities = ctx.world, ctx.entities
         for i = 1, #entities do
            entities[i]:give("Name", "monster")
         end
         world:__flush()
      end,
      before = create_world(),
      after = clear_world,
   },

   remove = {
      fn = function(ctx, _p)
         local world, entities = ctx.world, ctx.entities
         for i = 1, #entities do
            entities[i]:remove("Velocity")
         end
         world:__flush()
      end,
      before = create_world(),
      after = clear_world,
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
            local _ = entities[i]:has("Alive")
         end
      end,
      before = create_world(),
      after = clear_world,
   },

   add = {
      fn = function(ctx, _p)
         local world, entities = ctx.world, ctx.entities
         for i = 1, #entities do
            entities[i]:give("Aggro")
         end
         world:__flush()
      end,
      before = create_world(),
      after = clear_world,
   },

   remove = {
      fn = function(ctx, _p)
         local world, entities = ctx.world, ctx.entities
         for i = 1, #entities do
            entities[i]:remove("Alive")
         end
         world:__flush()
      end,
      before = create_world(),
      after = clear_world,
   },
}

-- ----------------------------------------------------------------------------
-- System Tests
-- ----------------------------------------------------------------------------

--- @type BenchmarkTests
local system = {
   throughput = {
      fn = function(ctx, _p)
         ctx.world:emit("update", DT)
      end,
      before = function(_ctx, p)
         local world = concord_world()
         for _ = 1, p.n_entities do
            concord_entity(world):give("Position", 0.0, 0.0):give("Velocity", 0.0, 0.0)
         end

         local MovementSystem = concord_system({
            pool = { "Position", "Velocity" },
         })
         function MovementSystem:update(dt)
            local pool = self.pool
            for i = 1, #pool do
               local e = pool[i]
               local position = e.Position
               local velocity = e.Velocity
               position.x = position.x + velocity.x * dt
               position.y = position.y + velocity.y * dt
            end
         end

         world:addSystems(MovementSystem)
         world:emit("update", DT)
         return { world = world }
      end,
      after = clear_world,
   },

   overlap = {
      fn = function(ctx, _p)
         ctx.world:emit("update", DT)
      end,
      before = function(_ctx, p)
         local world = concord_world()
         for i = 1, p.n_entities do
            local archetype = i % 4
            local e = concord_entity(world):give("A", 0):give("B", 0)
            if archetype >= 1 then
               e:give("C", 0)
            end
            if archetype >= 2 then
               e:give("D", 0)
            end
            if archetype == 3 then
               e:remove("D")
               e:give("E", 0)
            end
         end

         local SwapAB = concord_system({ pool = { "A", "B" } })
         function SwapAB:update(_dt)
            local pool = self.pool
            for i = 1, #pool do
               local e = pool[i]
               e.A.v, e.B.v = e.B.v, e.A.v
            end
         end

         local SwapCD = concord_system({ pool = { "C", "D" } })
         function SwapCD:update(_dt)
            local pool = self.pool
            for i = 1, #pool do
               local e = pool[i]
               e.C.v, e.D.v = e.D.v, e.C.v
            end
         end

         local SwapCE = concord_system({ pool = { "C", "E" } })
         function SwapCE:update(_dt)
            local pool = self.pool
            for i = 1, #pool do
               local e = pool[i]
               e.C.v, e.E.v = e.E.v, e.C.v
            end
         end

         world:addSystems(SwapAB, SwapCD, SwapCE)
         world:emit("update", DT)

         return { world = world }
      end,
      after = clear_world,
   },

   fragmented = {
      fn = function(ctx, _p)
         ctx.world:emit("update", DT)
      end,
      before = function(_ctx, p)
         local world = concord_world()
         for i = 1, p.n_entities do
            local buff_index = ((i - 1) % #BUFF_NAMES) + 1
            local e = concord_entity(world):give("Position", 0.0, 0.0)
            e:give(BUFF_NAMES[buff_index], buff_index)
         end

         local sum = 0

         local PositionSystem = concord_system({ pool = { "Position" } })
         function PositionSystem:update(_dt)
            local pool = self.pool
            for i = 1, #pool do
               local pos = pool[i].Position
               sum = sum + pos.x + pos.y
            end
         end

         local Buff1System = concord_system({ pool = { "Buff1" } })
         function Buff1System:update(_dt)
            local pool = self.pool
            for i = 1, #pool do
               sum = sum + pool[i].Buff1.level
            end
         end

         world:addSystems(PositionSystem, Buff1System)
         world:emit("update", DT)
         return { world = world }
      end,
      after = clear_world,
   },

   chained = {
      fn = function(ctx, _p)
         ctx.world:emit("update", DT)
      end,
      before = function(_ctx, p)
         local world = concord_world()

         for _ = 1, p.n_entities do
            concord_entity(world):give("A", 1):give("B", 0):give("C", 0):give("D", 0):give("E", 0)
         end

         local SysAB = concord_system({ pool = { "A", "B" } })
         function SysAB:update(_dt)
            local pool = self.pool
            for i = 1, #pool do
               local e = pool[i]
               e.B.v = e.A.v
            end
         end

         local SysBC = concord_system({ pool = { "B", "C" } })
         function SysBC:update(_dt)
            local pool = self.pool
            for i = 1, #pool do
               local e = pool[i]
               e.C.v = e.B.v
            end
         end

         local SysCD = concord_system({ pool = { "C", "D" } })
         function SysCD:update(_dt)
            local pool = self.pool
            for i = 1, #pool do
               local e = pool[i]
               e.D.v = e.C.v
            end
         end

         local SysDE = concord_system({ pool = { "D", "E" } })
         function SysDE:update(_dt)
            local pool = self.pool
            for i = 1, #pool do
               local e = pool[i]
               e.E.v = e.D.v
            end
         end

         world:addSystems(SysAB, SysBC, SysCD, SysDE)
         world:emit("update", DT)

         return { world = world }
      end,
      after = clear_world,
   },

   multi_20 = {
      fn = function(ctx, _p)
         ctx.world:emit("update", DT)
      end,
      before = function(_ctx, p)
         local world = concord_world()

         for _ = 1, p.n_entities do
            concord_entity(world)
               :give("Comp1", 0)
               :give("Comp2", 0)
               :give("Comp3", 0)
               :give("Comp4", 0)
               :give("Comp5", 0)
               :give("Comp6", 0)
               :give("Comp7", 0)
               :give("Comp8", 0)
               :give("Comp9", 0)
               :give("Comp10", 0)
         end

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
         local systems = {}
         for _, comp_name in ipairs(comp_names) do
            local sys1 = concord_system({ pool = { comp_name } })
            function sys1:update(_dt)
               local pool = self.pool
               for i = 1, #pool do
                  sum = sum + pool[i][comp_name].value
               end
            end
            systems[#systems + 1] = sys1

            local sys2 = concord_system({ pool = { comp_name } })
            function sys2:update(_dt)
               local pool = self.pool
               for i = 1, #pool do
                  sum = sum + pool[i][comp_name].value
               end
            end
            systems[#systems + 1] = sys2
         end

         world:addSystems(unpack(systems))
         world:emit("update", DT)
         return { world = world }
      end,
      after = clear_world,
   },

   empty_systems = {
      fn = function(ctx, _p)
         ctx.world:emit("update", DT)
      end,
      before = function(_ctx, p)
         local world = concord_world()

         for _ = 1, p.n_entities do
            concord_entity(world):give("Position", 0.0, 0.0)
         end

         local systems = {}
         for _ = 1, 20 do
            local sys = concord_system({ pool = { "NonExistent" } })
            function sys:update(dt)
               local pool = self.pool
               for i = 1, #pool do
                  local e = pool[i]
                  e.NonExistent.value = e.NonExistent.value + dt
               end
            end
            systems[#systems + 1] = sys
         end

         world:addSystems(unpack(systems))
         world:emit("update", DT)
         return { world = world }
      end,
      after = clear_world,
   },
}

-- ----------------------------------------------------------------------------
-- Structural Scaling Tests
-- ----------------------------------------------------------------------------

--- Factory: returns a `before` that creates a populated world with N_SYSTEMS background systems.
--- @param make_entity? fun(world: table): table Factory for tracked entities.
--- @return fun(_ctx: table, p: { n_entities: number }): { world: table, entities: table[] }
local function create_scaling_world(make_entity)
   make_entity = make_entity or make_default_entity
   return function(_ctx, p)
      local world = concord_world()

      local systems = {}
      for _ = 1, N_SYSTEMS do
         local sys = concord_system({ pool = { "Position", "Velocity" } })
         function sys:update(_dt) end
         systems[#systems + 1] = sys
      end
      world:addSystems(unpack(systems))

      -- Background entities
      for _ = 1, p.n_entities * (WORLD_MULTIPLIER - 1) do
         concord_entity(world):give("Health", 100, 100):give("Name", "monster"):give("Aggro")
      end

      -- Tracked entities for test operations
      local entities = {}
      for i = 1, p.n_entities do
         entities[i] = make_entity(world)
      end

      shuffle(entities)
      world:__flush()
      return { world = world, entities = entities }
   end
end

--- @type BenchmarkTests
local structural_scaling = {
   create = {
      fn = function(ctx, p)
         local world = ctx.world
         for _ = 1, p.n_entities do
            concord_entity(world):give("Position", 0.0, 0.0):give("Alive")
         end
         world:__flush()
      end,
      before = create_scaling_world(),
      after = clear_world,
   },

   add_component = {
      fn = function(ctx, _p)
         local world, entities = ctx.world, ctx.entities
         for i = 1, #entities do
            entities[i]:give("Name", "monster")
         end
         world:__flush()
      end,
      before = create_scaling_world(),
      after = clear_world,
   },

   destroy = {
      fn = function(ctx, _p)
         local world, entities = ctx.world, ctx.entities
         for i = 1, #entities do
            world:removeEntity(entities[i])
         end
         world:__flush()
      end,
      before = create_scaling_world(),
      after = clear_world,
   },
}

-- ----------------------------------------------------------------------------
-- No-Serialize Variant
-- ----------------------------------------------------------------------------

--- Wrap a test spec to disable SERIALIZE_BY_DEFAULT during setup/teardown.
--- @param spec luamark.Spec
--- @return luamark.Spec
local function wrap_no_serialize(spec)
   return {
      fn = spec.fn,
      before = spec.before and function(ctx, p)
         concord_entity.SERIALIZE_BY_DEFAULT = false
         return spec.before(ctx, p)
      end,
      after = spec.after and function(ctx, p)
         spec.after(ctx, p)
         concord_entity.SERIALIZE_BY_DEFAULT = ORIGINAL_SERIALIZE
      end,
   }
end

--- Wrap all tests in a group to disable SERIALIZE_BY_DEFAULT.
--- @param tests BenchmarkTests
--- @return BenchmarkTests
local function wrap_tests_no_serialize(tests)
   local wrapped = {}
   for name, spec in pairs(tests) do
      wrapped[name] = wrap_no_serialize(spec)
   end
   return wrapped
end

-- ----------------------------------------------------------------------------
-- Module Export
-- ----------------------------------------------------------------------------

--- @type VariantModule
return {
   variants = {
      ["concord"] = {
         entity = entity,
         component = component,
         tag = tag,
         system = system,
         structural_scaling = structural_scaling,
      },
      ["concord-no-serialize"] = {
         entity = wrap_tests_no_serialize(entity),
         component = wrap_tests_no_serialize(component),
         tag = wrap_tests_no_serialize(tag),
      },
   },
}
