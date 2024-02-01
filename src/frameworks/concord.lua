---@diagnostic disable: unused-local
local Benchmark = require("src.Benchmark")
local Concord = require("lib.Concord.concord.init")
local class = require("pl.class")

local Entity = Concord.entity
local Component = Concord.component
local System = Concord.system
local World = Concord.world

Component("Position", function(component, x, y)
   component.x = x or 0
   component.y = y or 0
end)

Component("Velocity", function(component, x, y)
   component.x = x or 0
   component.y = y or 0
end)

Component("Optional")
Component("Padding1")
Component("Padding2")
Component("Padding3")

local ConcordBenchmark = class(Benchmark)

function ConcordBenchmark:setup()
   self.world = World()
end
function ConcordBenchmark:teardown()
   self.world:clear()
   self.world = nil
end

local create_empty_entity = class(ConcordBenchmark)
function create_empty_entity:run()
   for _ = 1, self.n_entities do
      self.world:addEntity(Entity())
   end
   self.world:__flush()
end

local create_entities = class.create_entities(ConcordBenchmark)

function create_entities:run()
   for _ = 1, self.n_entities do
      self.world:addEntity(Entity():give("Position", 0.0, 0.0):give("Velocity", 0.0, 0.0))
   end
   self.world:__flush()
end

local EntityFactory = class(ConcordBenchmark)

function EntityFactory:setup(empty)
   self.world = World()
   self.entities = {}
   local entity
   for _ = 1, self.n_entities do
      entity = Entity(self.world)
      if not empty then
         entity:give("Position", 0.0, 0.0):give("Velocity", 0.0, 0.0):give("Optional")
      end
      table.insert(self.entities, entity)
   end
end

local remove_entities = class(EntityFactory)

function remove_entities:run()
   for i = 1, #self.entities do
      self.world:removeEntity(self.entities[i])
   end
   self.world:__flush()
end

local get_component = class(EntityFactory)

function get_component:run()
   --luacheck: ignore
   local component
   for i = 1, #self.entities do
      component = self.entities[i].Position
   end
end

local get_components = class(EntityFactory)
function get_components:run()
   --luacheck: ignore
   local component, entity, all_components
   for i = 1, #self.entities do
      entity = self.entities[i]
      component = entity.Position
      component = entity.Velocity
      component = entity.Optional
   end
end

local add_component = class(EntityFactory)

function add_component:setup()
   EntityFactory.setup(self, true)
end

function add_component:run()
   for i = 1, #self.entities do
      self.entities[i]:give("Position", 0.0, 0.0)
   end
end

local add_components = class(add_component)

function add_components:run()
   for i = 1, #self.entities do
      self.entities[i]:give("Position", 0.0, 0.0):give("Velocity", 0.0, 0.0):give("Optional")
   end
end

local remove_component = class(EntityFactory)

function remove_component:run()
   for i = 1, #self.entities do
      self.entities[i]:remove("Position")
   end
   self.world:__flush()
end

local remove_components = class(EntityFactory)

function remove_components:run()
   for i = 1, #self.entities do
      self.entities[i]:remove("Position"):remove("Velocity"):remove("Optional")
   end
   self.world:__flush()
end

local system_update = class(ConcordBenchmark)
function system_update:setup()
   self.world = World()
   local entity, padding, shuffle
   for i = 1, self.n_entities do
      entity = Entity(self.world)
      entity:give("Position", 0.0, 0.0):give("Velocity", 0.0, 0.0)

      padding = i % 4
      if padding == 1 then
         entity:give("Padding1")
      elseif padding == 2 then
         entity:give("Padding2")
      elseif padding == 3 then
         entity:give("Padding3")
      end

      shuffle = (i + 1) % 4
      if shuffle == 0 then
         entity:remove("Position")
      elseif shuffle == 1 then
         entity:remove("Velocity")
      end
   end

   local MovementSystem = System({
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

   self.world:addSystems(MovementSystem)
end

function system_update:run()
   self.world:emit("update", 1 / 60)
end

return {
   create_empty_entity = create_empty_entity,
   create_entities = create_entities,
   remove_entities = remove_entities,
   get_component = get_component,
   get_components = get_components,
   add_component = add_component,
   add_components = add_components,
   remove_component = remove_component,
   remove_components = remove_components,
   system_update = system_update,
}
