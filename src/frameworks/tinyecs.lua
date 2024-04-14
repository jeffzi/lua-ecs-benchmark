---@diagnostic disable: unused-local
local Benchmark = require("src.Benchmark")
local class = require("pl.class")
local tiny = require("tiny")

local tiny_addEntity, tiny_removeEntity = tiny.addEntity, tiny.removeEntity
local tiny_refresh, tiny_update = tiny.refresh, tiny.update

local TinyBenchmark = class(Benchmark)

function TinyBenchmark:iteration_setup()
   self.world = tiny.world()
end

function TinyBenchmark:iteration_teardown()
   tiny.clearEntities(self.world)
   tiny.clearSystems(self.world)
   self.world = nil
end

local add_empty_entity = class(TinyBenchmark)
function add_empty_entity:run()
   local world = self.world
   for _ = 1, self.n_entities do
      tiny_addEntity(world, {})
   end
   tiny_refresh(world)
end

local add_entities = class.add_entities(TinyBenchmark)

function add_entities:run()
   local world = self.world
   for _ = 1, self.n_entities do
      tiny_addEntity(world, {
         Position = {
            x = 0.0,
            y = 0.0,
         },
         Velocity = {
            x = 0.0,
            y = 0.0,
         },
      })
   end
   tiny_refresh(world)
end

local EntityFactory = class(TinyBenchmark)

function EntityFactory:iteration_setup(empty)
   self.world = tiny.world()
   self.entities = {}
   local entity
   for _ = 1, self.n_entities do
      if empty then
         entity = {}
      else
         entity = tiny_addEntity(self.world, {
            Position = {
               x = 0.0,
               y = 0.0,
            },
            Velocity = {
               x = 0.0,
               y = 0.0,
            },
            Optional = true,
         })
      end
      entity = tiny_addEntity(self.world, entity)
      table.insert(self.entities, entity)
   end
   Benchmark.shuffle(self.entities)
end

local remove_entities = class(EntityFactory)

function remove_entities:run()
   local world, entities = self.world, self.entities
   for i = 1, #entities do
      tiny_removeEntity(world, entities[i])
   end
   tiny_refresh(world)
end

local get_component = class(EntityFactory)

function get_component:run()
   --luacheck: ignore
   local entities = self.entities
   for i = 1, #entities do
      local component = entities[i].Position
   end
end

local get_components = class(EntityFactory)
function get_components:run()
   --luacheck: ignore
   local entities = self.entities
   for i = 1, #entities do
      local entity = entities[i]
      local component = entity.Position
      component = entity.Velocity
      component = entity.Optional
   end
end

local add_component = class(EntityFactory)

function add_component:iteration_setup()
   EntityFactory.iteration_setup(self, true)
end

function add_component:run()
   --luacheck: ignore
   local world, entities = self.world, self.entities
   for i = 1, #entities do
      local entity = entities[i]
      entity.Position = {
         x = 0.0,
         y = 0.0,
      }
      tiny_addEntity(world, entity)
   end
   -- tiny_refresh(world)
end

local add_components = class(add_component)

function add_components:run()
   --luacheck: ignore
   local world, entities = self.world, self.entities
   for i = 1, #entities do
      local entity = entities[i]
      entity.Position = {
         x = 0.0,
         y = 0.0,
      }
      entity.Velocity = {
         x = 0.0,
         y = 0.0,
      }
      entity.Optional = true
      tiny_addEntity(world, entity)
   end
   tiny_refresh(world)
end

local remove_component = class(EntityFactory)

function remove_component:run()
   local world, entities = self.world, self.entities
   for i = 1, #entities do
      local entity = entities[i]
      entity.Position = nil
      tiny_addEntity(world, entity)
   end
   tiny_refresh(world)
end

local remove_components = class(EntityFactory)

function remove_components:run()
   local world, entities = self.world, self.entities
   for i = 1, #entities do
      local entity = entities[i]
      entity.Position = nil
      entity.Velocity = nil
      entity.Optional = nil
      tiny_addEntity(world, entity)
   end
   tiny_refresh(world)
end

local system_update = class(Benchmark)

function system_update:global_setup()
   self.world = tiny.world()
   local entity, padding, shuffle
   for i = 1, self.n_entities do
      entity = tiny_addEntity(self.world, {
         Position = {
            x = 0.0,
            y = 0.0,
         },
         Velocity = {
            x = 0.0,
            y = 0.0,
         },
      })

      padding = i % 4
      if padding == 1 then
         entity.Padding1 = {}
      elseif padding == 2 then
         entity.Padding2 = {}
      elseif padding == 3 then
         entity.Padding3 = {}
      end

      shuffle = (i + 1) % 4
      if shuffle == 0 then
         entity.Position = nil
      elseif shuffle == 1 then
         entity.Velocity = nil
      end
   end

   local MovementSystem = tiny.processingSystem()
   MovementSystem.filter = tiny.requireAll("Position", "Velocity")

   function MovementSystem:process(e, dt)
      local position = e.Position
      local velocity = e.Velocity
      position.x = position.x + velocity.x * dt
      position.y = position.y + velocity.y * dt
   end

   tiny.addSystem(self.world, MovementSystem)
end

function system_update:global_teardown()
   tiny.clearEntities(self.world)
   tiny.clearSystems(self.world)
   self.world = nil
end

function system_update:run()
   tiny_update(self.world, 1 / 60)
end

return {
   add_empty_entity = add_empty_entity,
   add_entities = add_entities,
   remove_entities = remove_entities,
   get_component = get_component,
   get_components = get_components,
   add_component = add_component,
   add_components = add_components,
   remove_component = remove_component,
   remove_components = remove_components,
   system_update = system_update,
}
