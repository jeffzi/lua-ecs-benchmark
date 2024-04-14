---@diagnostic disable: unused-local
local Benchmark = require("src.Benchmark")
local class = require("pl.class")
local lovetoys = require("lovetoys")

lovetoys.initialize()
local Engine, Entity, Component, System =
   lovetoys.Engine, lovetoys.Entity, lovetoys.Component, lovetoys.System

local Position = Component.create("Position", { "x", "y" }, { x = 0, y = 0 })
local Velocity = Component.create("Velocity", { "x", "y" }, { x = 0, y = 0 })
local Optional = Component.create("Optional")
local Padding1 = Component.create("Padding1")
local Padding2 = Component.create("Padding2")
local Padding3 = Component.create("Padding3")

local LovetoysBenchmark = class(Benchmark)

function LovetoysBenchmark:iteration_setup()
   self.engine = Engine()
end
function LovetoysBenchmark:iteration_teardown()
   self.engine = nil
end

local add_empty_entity = class(LovetoysBenchmark)
function add_empty_entity:run()
   local engine = self.engine
   for _ = 1, self.n_entities do
      local entity = Entity()
      entity:initialize()
      engine:addEntity(entity)
   end
end

local add_entities = class.add_entities(LovetoysBenchmark)

function add_entities:run()
   local engine = self.engine
   for _ = 1, self.n_entities do
      local entity = Entity()
      entity:initialize()
      entity:add(Position(0, 0))
      entity:add(Velocity(0, 0))
      engine:addEntity(entity)
   end
end

local EntityFactory = class(LovetoysBenchmark)

function EntityFactory:iteration_setup(empty)
   self.engine = Engine()
   self.entities = {}
   local entity
   for _ = 1, self.n_entities do
      entity = Entity()
      if not empty then
         entity:add(Position(0, 0))
         entity:add(Velocity(0, 0))
         entity:add(Optional())
      end
      table.insert(self.entities, entity)
   end
end

local remove_entities = class(EntityFactory)

function remove_entities:run()
   local engine, entities = self.engine, self.entities
   for i = 1, #entities do
      engine:removeEntity(entities[i])
   end
end

local get_component = class(EntityFactory)

function get_component:run()
   local entities = self.entities
   for i = 1, #entities do
      --luacheck: ignore
      local component = entities[i]:get("Position")
   end
end

local get_components = class(EntityFactory)

function get_components:run()
   local entities = self.entities
   for i = 1, #entities do
      local entity = entities[i]
      --luacheck: ignore
      local component = entity:get("Position")
      component = entity:get("Velocity")
      component = entity:get("Optional")
   end
end

local add_component = class(EntityFactory)

function add_component:iteration_setup()
   EntityFactory.iteration_setup(self, true)
end

function add_component:run()
   local entities = self.entities
   for i = 1, #entities do
      entities[i]:add(Position(0, 0))
   end
end

local add_components = class(add_component)

function add_components:run()
   local entities = self.entities
   for i = 1, #entities do
      local entity = entities[i]
      entity:addMultiple({ Position(0, 0), Velocity(0, 0), Optional() })
   end
end

local remove_component = class(EntityFactory)

function remove_component:run()
   local entities = self.entities
   for i = 1, #entities do
      entities[i]:remove("Position")
   end
end

local remove_components = class(EntityFactory)

function remove_components:run()
   local entities = self.entities
   for i = 1, #entities do
      local entity = entities[i]
      entity:remove("Position")
      entity:remove("Velocity")
      entity:remove("Optional")
   end
end

local system_update = class(Benchmark)

function system_update:global_setup()
   self.engine = Engine()
   local entity, padding, shuffle
   for i = 1, self.n_entities do
      entity = Entity()
      entity:initialize()
      entity:add(Position(0, 0))
      entity:add(Velocity(0, 0))
      self.engine:addEntity(entity)

      padding = i % 4
      if padding == 1 then
         entity:add(Padding1())
      elseif padding == 2 then
         entity:add(Padding2())
      elseif padding == 3 then
         entity:add(Padding3())
      end

      shuffle = (i + 1) % 4
      if shuffle == 0 then
         entity:remove("Position")
      elseif shuffle == 1 then
         entity:remove("Velocity")
      end
   end

   local MovementSystem = lovetoys.class("MovementSystem", System)

   function MovementSystem:requires()
      return { "Position", "Velocity" }
   end

   function MovementSystem:update(dt)
      local position, velocity
      for _, e in pairs(self.targets) do
         position = e:get("Position")
         velocity = e:get("Velocity")
         position.x = position.x + velocity.x * dt
         position.y = position.y + velocity.y * dt
      end
   end

   self.engine:addSystem(MovementSystem())
end

function system_update:global_teardown()
   self.engine = nil
end

function system_update:run()
   self.engine:update(1 / 60)
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
