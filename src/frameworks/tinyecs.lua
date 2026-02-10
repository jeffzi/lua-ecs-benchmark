---@diagnostic disable: unused-local
local config = require("src.lib.config")
local tiny = require("tiny")
local shuffle = require("src.lib.utils").shuffle

local tiny_addEntity = tiny.addEntity
local tiny_addSystem = tiny.addSystem
local tiny_clearEntities = tiny.clearEntities
local tiny_clearSystems = tiny.clearSystems
local tiny_processingSystem = tiny.processingSystem
local tiny_refresh = tiny.refresh
local tiny_removeEntity = tiny.removeEntity
local tiny_requireAll = tiny.requireAll
local tiny_update = tiny.update
local tiny_world = tiny.world

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

--- Factory: returns a `before` function that creates a populated world.
--- (WORLD_MULTIPLIER - 1) * N background + N tracked entities.
--- @param make_entity? fun(): table Factory for tracked entities.
--- @return fun(_ctx: table, p: { n_entities: number }): { world: table, entities: table[] }
local function create_world(make_entity)
   make_entity = make_entity or make_default_entity
   return function(_ctx, p)
      local world = tiny_world()

      -- Background entities
      for _ = 1, p.n_entities * (WORLD_MULTIPLIER - 1) do
         tiny_addEntity(world, {
            Health = { current = 100, max = 100 },
            Name = { value = "monster" },
            Aggro = true,
         })
      end

      -- Tracked entities for test operations
      local entities = {}
      for i = 1, p.n_entities do
         entities[i] = tiny_addEntity(world, make_entity())
      end

      shuffle(entities)
      tiny_refresh(world)
      return { world = world, entities = entities }
   end
end

--- Clear the world.
--- @param ctx { world: table } Context with world.
local function clear_world(ctx)
   tiny_clearEntities(ctx.world)
   tiny_clearSystems(ctx.world)
end

local TAG_NAMES = config.generate_tag_names(config.N_TAGS)

-- ----------------------------------------------------------------------------
-- Entity Tests
-- ----------------------------------------------------------------------------

--- @type BenchmarkTests
local entity = {
   create_empty = {
      fn = function(ctx, p)
         local world = ctx.world
         for _ = 1, p.n_entities do
            tiny_addEntity(world, {})
         end
         tiny_refresh(world)
      end,
      before = create_world(),
      after = clear_world,
   },

   create_with_components = {
      fn = function(ctx, p)
         local world = ctx.world
         for _ = 1, p.n_entities do
            tiny_addEntity(world, {
               Position = { x = 0, y = 0 },
               Alive = true,
            })
         end
         tiny_refresh(world)
      end,
      before = create_world(),
      after = clear_world,
   },

   destroy = {
      fn = function(ctx)
         local world, entities = ctx.world, ctx.entities
         for i = 1, #entities do
            tiny_removeEntity(world, entities[i])
         end
         tiny_refresh(world)
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
      fn = function(ctx)
         local entities = ctx.entities
         for i = 1, #entities do
            local e = entities[i]
            local _ = e.Position.x
            _ = e.Alive
         end
      end,
      before = create_world(),
      after = clear_world,
   },

   set = {
      fn = function(ctx)
         local entities = ctx.entities
         for i = 1, #entities do
            local e = entities[i]
            e.Position.x = 1.0
            e.Alive = false
         end
      end,
      before = create_world(),
      after = clear_world,
   },

   add = {
      fn = function(ctx)
         local world, entities = ctx.world, ctx.entities
         for i = 1, #entities do
            local e = entities[i]
            e.Name = { value = "monster" }
            e.Aggro = true
            tiny_addEntity(world, e)
         end
         tiny_refresh(world)
      end,
      before = create_world(),
      after = clear_world,
   },

   remove = {
      fn = function(ctx)
         local world, entities = ctx.world, ctx.entities
         for i = 1, #entities do
            local e = entities[i]
            e.Velocity = nil
            e.Alive = nil
            tiny_addEntity(world, e)
         end
         tiny_refresh(world)
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
         tiny_update(ctx.world, DT)
      end,
      before = function(_ctx, p)
         local world = tiny_world()
         for _ = 1, p.n_entities do
            tiny_addEntity(world, {
               Position = { x = 0.0, y = 0.0 },
               Velocity = { x = 0.0, y = 0.0 },
            })
         end

         local MovementSystem = tiny_processingSystem()
         MovementSystem.filter = tiny_requireAll("Position", "Velocity")

         function MovementSystem:process(e, dt)
            local position = e.Position
            local velocity = e.Velocity
            position.x = position.x + velocity.x * dt
            position.y = position.y + velocity.y * dt
         end

         tiny_addSystem(world, MovementSystem)
         tiny_refresh(world)
         tiny_update(world, DT)
         return { world = world }
      end,
      after = clear_world,
   },

   overlap = {
      fn = function(ctx, _p)
         tiny_update(ctx.world, DT)
      end,
      before = function(_ctx, p)
         local world = tiny_world()
         for i = 1, p.n_entities do
            local archetype = i % 4
            local e = tiny_addEntity(world, {
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

         local SwapAB = tiny_processingSystem()
         SwapAB.filter = tiny_requireAll("A", "B")
         function SwapAB:process(e, _dt)
            e.A.v, e.B.v = e.B.v, e.A.v
         end

         local SwapCD = tiny_processingSystem()
         SwapCD.filter = tiny_requireAll("C", "D")
         function SwapCD:process(e, _dt)
            e.C.v, e.D.v = e.D.v, e.C.v
         end

         local SwapCE = tiny_processingSystem()
         SwapCE.filter = tiny_requireAll("C", "E")
         function SwapCE:process(e, _dt)
            e.C.v, e.E.v = e.E.v, e.C.v
         end

         tiny_addSystem(world, SwapAB)
         tiny_addSystem(world, SwapCD)
         tiny_addSystem(world, SwapCE)
         tiny_refresh(world)
         tiny_update(world, DT)

         return { world = world }
      end,
      after = clear_world,
   },

   fragmented = {
      fn = function(ctx, _p)
         tiny_update(ctx.world, DT)
      end,
      before = function(_ctx, p)
         local world = tiny_world()
         for i = 1, p.n_entities do
            local tag_index = ((i - 1) % #TAG_NAMES) + 1
            local e = tiny_addEntity(world, {
               Position = { x = 0.0, y = 0.0 },
            })
            e[TAG_NAMES[tag_index]] = { id = tag_index }
         end

         local sum = 0

         local PositionSystem = tiny_processingSystem()
         PositionSystem.filter = tiny_requireAll("Position")

         function PositionSystem:process(e, _dt)
            local pos = e.Position
            sum = sum + pos.x + pos.y
         end

         local Tag1System = tiny_processingSystem()
         Tag1System.filter = tiny_requireAll("Tag1")

         function Tag1System:process(e, _dt)
            local pos = e.Position
            sum = sum + pos.x + pos.y
         end

         tiny_addSystem(world, PositionSystem)
         tiny_addSystem(world, Tag1System)
         tiny_refresh(world)
         tiny_update(world, DT)
         return { world = world }
      end,
      after = clear_world,
   },

   chained = {
      fn = function(ctx, _p)
         tiny_update(ctx.world, DT)
      end,
      before = function(_ctx, p)
         local world = tiny_world()

         for _ = 1, p.n_entities do
            tiny_addEntity(world, {
               A = { v = 1 },
               B = { v = 0 },
               C = { v = 0 },
               D = { v = 0 },
               E = { v = 0 },
            })
         end

         local SysAB = tiny_processingSystem()
         SysAB.filter = tiny_requireAll("A", "B")
         function SysAB:process(e, _dt)
            e.B.v = e.A.v
         end

         local SysBC = tiny_processingSystem()
         SysBC.filter = tiny_requireAll("B", "C")
         function SysBC:process(e, _dt)
            e.C.v = e.B.v
         end

         local SysCD = tiny_processingSystem()
         SysCD.filter = tiny_requireAll("C", "D")
         function SysCD:process(e, _dt)
            e.D.v = e.C.v
         end

         local SysDE = tiny_processingSystem()
         SysDE.filter = tiny_requireAll("D", "E")
         function SysDE:process(e, _dt)
            e.E.v = e.D.v
         end

         tiny_addSystem(world, SysAB)
         tiny_addSystem(world, SysBC)
         tiny_addSystem(world, SysCD)
         tiny_addSystem(world, SysDE)
         tiny_refresh(world)
         tiny_update(world, DT)

         return { world = world }
      end,
      after = clear_world,
   },

   multi_20 = {
      fn = function(ctx, _p)
         tiny_update(ctx.world, DT)
      end,
      before = function(_ctx, p)
         local world = tiny_world()

         for _ = 1, p.n_entities do
            tiny_addEntity(world, {
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
            local sys1 = tiny_processingSystem()
            sys1.filter = tiny_requireAll(comp_name)
            function sys1:process(e, _dt)
               sum = sum + e[comp_name].value
            end
            tiny_addSystem(world, sys1)

            local sys2 = tiny_processingSystem()
            sys2.filter = tiny_requireAll(comp_name)
            function sys2:process(e, _dt)
               sum = sum + e[comp_name].value
            end
            tiny_addSystem(world, sys2)
         end

         tiny_refresh(world)
         tiny_update(world, DT)
         return { world = world }
      end,
      after = clear_world,
   },

   empty_systems = {
      fn = function(ctx, _p)
         tiny_update(ctx.world, DT)
      end,
      before = function(_ctx, p)
         local world = tiny_world()

         for _ = 1, p.n_entities do
            tiny_addEntity(world, {
               Position = { x = 0.0, y = 0.0 },
            })
         end

         for _ = 1, 20 do
            local sys = tiny_processingSystem()
            sys.filter = tiny_requireAll("NonExistent")
            function sys:process(e, dt)
               e.NonExistent.value = e.NonExistent.value + dt
            end
            tiny_addSystem(world, sys)
         end

         tiny_refresh(world)
         tiny_update(world, DT)
         return { world = world }
      end,
      after = clear_world,
   },
}

-- ----------------------------------------------------------------------------
-- Stress Tests
-- ----------------------------------------------------------------------------

--- @type BenchmarkTests
local stress = {
   archetype_churn = {
      fn = function(ctx, _p)
         local world, entities = ctx.world, ctx.entities
         for i = 1, #entities do
            local e = entities[i]
            for _ = 1, 100 do
               e.B = { v = 0 }
               tiny_addEntity(world, e)
               tiny_refresh(world)
               e.B = nil
               tiny_addEntity(world, e)
               tiny_refresh(world)
            end
         end
      end,
      before = function(_ctx, p)
         local world = tiny_world()
         local entities = {}
         for i = 1, p.n_entities do
            entities[i] = tiny_addEntity(world, { A = { v = 0 } })
         end
         shuffle(entities)
         return { world = world, entities = entities }
      end,
      after = clear_world,
   },
}

-- ----------------------------------------------------------------------------
-- Module Export
-- ----------------------------------------------------------------------------

--- @type BenchmarkModule
return {
   entity = entity,
   component = component,
   system = system,
   stress = stress,
}
