---@diagnostic disable: unused-local
local Concord = require("lib.Concord.concord.init")
local shuffle = require("src.lib.utils").shuffle

local concord_component = Concord.component
local concord_entity = Concord.entity
local concord_system = Concord.system
local concord_world = Concord.world

-- ----------------------------------------------------------------------------
-- Setup
-- ----------------------------------------------------------------------------

concord_component("Position", function(component, x, y)
   component.x = x or 0
   component.y = y or 0
end)

concord_component("Velocity", function(component, x, y)
   component.x = x or 0
   component.y = y or 0
end)

concord_component("Optional")
concord_component("Padding1")
concord_component("Padding2")
concord_component("Padding3")

--- Create a new world.
--- @return { world: table } Context with world.
local function create_world()
   return { world = concord_world() }
end

--- Create a world populated with entities (with components).
--- @param _ctx table Unused previous context.
--- @param p { n_entities: number } Benchmark parameters.
--- @return { world: table, entities: table[] } Context with world and entities.
local function create_populated_world(_ctx, p)
   local world = concord_world()
   local entities = {}
   for i = 1, p.n_entities do
      local entity = concord_entity(world)
      entity:give("Position", 0.0, 0.0):give("Velocity", 0.0, 0.0):give("Optional")
      entities[i] = entity
   end
   shuffle(entities)
   return { world = world, entities = entities }
end

--- Create a world populated with empty entities.
--- @param _ctx table Unused previous context.
--- @param p { n_entities: number } Benchmark parameters.
--- @return { world: table, entities: table[] } Context with world and entities.
local function create_empty_entities(_ctx, p)
   local world = concord_world()
   local entities = {}
   for i = 1, p.n_entities do
      entities[i] = concord_entity(world)
   end
   shuffle(entities)
   return { world = world, entities = entities }
end

--- Clear the world.
--- @param ctx { world: table } Context with world.
local function clear_world(ctx)
   ctx.world:clear()
end

-- ----------------------------------------------------------------------------
-- Tests
-- ----------------------------------------------------------------------------

--- @type BenchmarkModule
return {
   add_empty_entity = {
      fn = function(ctx, p)
         local world = ctx.world
         for _ = 1, p.n_entities do
            concord_entity(world)
         end
         world:__flush()
      end,
      before = create_world,
      after = clear_world,
   },

   add_entities = {
      fn = function(ctx, p)
         local world = ctx.world
         for _ = 1, p.n_entities do
            concord_entity(world):give("Position", 0.0, 0.0):give("Velocity", 0.0, 0.0)
         end
         world:__flush()
      end,
      before = create_world,
      after = clear_world,
   },

   remove_entities = {
      fn = function(ctx, _p)
         local world, entities = ctx.world, ctx.entities
         for i = 1, #entities do
            world:removeEntity(entities[i])
         end
         world:__flush()
      end,
      before = create_populated_world,
      after = clear_world,
   },

   get_component = {
      fn = function(ctx, _p)
         local entities = ctx.entities
         for i = 1, #entities do
            local _ = entities[i].Position
         end
      end,
      before = create_populated_world,
      after = clear_world,
   },

   get_components = {
      fn = function(ctx, _p)
         local entities = ctx.entities
         for i = 1, #entities do
            local entity = entities[i]
            local _ = entity.Position
            _ = entity.Velocity
            _ = entity.Optional
         end
      end,
      before = create_populated_world,
      after = clear_world,
   },

   add_component = {
      fn = function(ctx, _p)
         local world, entities = ctx.world, ctx.entities
         for i = 1, #entities do
            entities[i]:give("Position", 0.0, 0.0)
         end
         world:__flush()
      end,
      before = create_empty_entities,
      after = clear_world,
   },

   add_components = {
      fn = function(ctx, _p)
         local world, entities = ctx.world, ctx.entities
         for i = 1, #entities do
            local entity = entities[i]
            entity:give("Position", 0.0, 0.0):give("Velocity", 0.0, 0.0):give("Optional")
         end
         world:__flush()
      end,
      before = create_empty_entities,
      after = clear_world,
   },

   remove_component = {
      fn = function(ctx, _p)
         local world, entities = ctx.world, ctx.entities
         for i = 1, #entities do
            entities[i]:remove("Position")
         end
         world:__flush()
      end,
      before = create_populated_world,
      after = clear_world,
   },

   remove_components = {
      fn = function(ctx, _p)
         local world, entities = ctx.world, ctx.entities
         for i = 1, #entities do
            local entity = entities[i]
            entity:remove("Position")
            entity:remove("Velocity")
            entity:remove("Optional")
         end
         world:__flush()
      end,
      before = create_populated_world,
      after = clear_world,
   },

   system_update = {
      fn = function(ctx, _p)
         ctx.world:emit("update", 1 / 60)
      end,
      before = function(_ctx, p)
         local world = concord_world()

         local entity, padding, should_shuffle
         for i = 1, p.n_entities do
            entity = concord_entity(world)
            entity:give("Position", 0.0, 0.0):give("Velocity", 0.0, 0.0)

            padding = i % 4
            if padding == 1 then
               entity:give("Padding1")
            elseif padding == 2 then
               entity:give("Padding2")
            elseif padding == 3 then
               entity:give("Padding3")
            end

            should_shuffle = (i + 1) % 4
            if should_shuffle == 0 then
               entity:remove("Position")
            elseif should_shuffle == 1 then
               entity:remove("Velocity")
            end
         end

         local MovementSystem = concord_system({
            pool = { "Position", "Velocity" },
         })
         function MovementSystem:update(dt)
            local position, velocity
            for _, e in ipairs(self.pool) do
               position = e.Position
               velocity = e.Velocity
               position.x = position.x + velocity.x * dt
               position.y = position.y + velocity.y * dt
            end
         end

         world:addSystems(MovementSystem)
         return { world = world }
      end,
      after = clear_world,
   },
}
