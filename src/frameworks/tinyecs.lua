---@diagnostic disable: unused-local
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

-- ----------------------------------------------------------------------------
-- Setup
-- ----------------------------------------------------------------------------

--- Create a new tiny world.
--- @return { world: table } Context with world.
local function create_world()
   return { world = tiny_world() }
end

--- Create a world populated with entities (with components).
--- @param _ctx table Unused previous context.
--- @param p { n_entities: number } Benchmark parameters.
--- @return { world: table, entities: table[] } Context with world and entities.
local function create_populated_world(_ctx, p)
   local world = tiny_world()
   local entities = {}
   for i = 1, p.n_entities do
      entities[i] = tiny_addEntity(world, {
         Position = { x = 0.0, y = 0.0 },
         Velocity = { x = 0.0, y = 0.0 },
         Optional = true,
      })
   end
   shuffle(entities)
   return { world = world, entities = entities }
end

--- Create a world populated with empty entities.
--- @param _ctx table Unused previous context.
--- @param p { n_entities: number } Benchmark parameters.
--- @return { world: table, entities: table[] } Context with world and entities.
local function create_empty_entities(_ctx, p)
   local world = tiny_world()
   local entities = {}
   for i = 1, p.n_entities do
      entities[i] = tiny_addEntity(world, {})
   end
   shuffle(entities)
   return { world = world, entities = entities }
end

--- Clear the world.
--- @param ctx { world: table } Context with world.
local function clear_world(ctx)
   tiny_clearEntities(ctx.world)
   tiny_clearSystems(ctx.world)
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
            tiny_addEntity(world, {})
         end
         tiny_refresh(world)
      end,
      before = create_world,
      after = clear_world,
   },

   create_with_components = {
      fn = function(ctx, p)
         local world = ctx.world
         for _ = 1, p.n_entities do
            tiny_addEntity(world, {
               Position = { x = 0.0, y = 0.0 },
               Velocity = { x = 0.0, y = 0.0 },
            })
         end
         tiny_refresh(world)
      end,
      before = create_world,
      after = clear_world,
   },

   destroy = {
      fn = function(ctx, _p)
         local world, entities = ctx.world, ctx.entities
         for i = 1, #entities do
            tiny_removeEntity(world, entities[i])
         end
         tiny_refresh(world)
      end,
      before = create_populated_world,
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
            local e = entities[i]
            local _ = e.Position
            _ = e.Velocity
            _ = e.Optional
         end
      end,
      before = create_populated_world,
      after = clear_world,
   },

   add = {
      fn = function(ctx, _p)
         local world, entities = ctx.world, ctx.entities
         for i = 1, #entities do
            local e = entities[i]
            e.Position = { x = 0.0, y = 0.0 }
            e.Velocity = { x = 0.0, y = 0.0 }
            e.Optional = true
            tiny_addEntity(world, e)
         end
         tiny_refresh(world)
      end,
      before = create_empty_entities,
      after = clear_world,
   },

   remove = {
      fn = function(ctx, _p)
         local world, entities = ctx.world, ctx.entities
         for i = 1, #entities do
            local e = entities[i]
            e.Position = nil
            e.Velocity = nil
            e.Optional = nil
            tiny_addEntity(world, e)
         end
         tiny_refresh(world)
      end,
      before = create_populated_world,
      after = clear_world,
   },
}

-- ----------------------------------------------------------------------------
-- System Tests
-- ----------------------------------------------------------------------------

--- @type BenchmarkTests
local system = {
   update = {
      fn = function(ctx, _p)
         tiny_update(ctx.world, 1 / 60)
      end,
      before = function(_ctx, p)
         local world = tiny_world()
         for i = 1, p.n_entities do
            local e = tiny_addEntity(world, {
               Position = { x = 0.0, y = 0.0 },
               Velocity = { x = 0.0, y = 0.0 },
            })

            local padding = i % 4
            if padding == 1 then
               e.Padding1 = {}
            elseif padding == 2 then
               e.Padding2 = {}
            elseif padding == 3 then
               e.Padding3 = {}
            end

            local should_shuffle = (i + 1) % 4
            if should_shuffle == 0 then
               e.Position = nil
            elseif should_shuffle == 1 then
               e.Velocity = nil
            end
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
         return { world = world }
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
}
