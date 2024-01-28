local Benchmark = require("src.Benchmark")
local class = require("pl.class")
local tiny = require("tiny")

local TinyBenchmark = class(Benchmark)

function TinyBenchmark:setup()
   self.world = tiny.world()
end
function TinyBenchmark:teardown()
   tiny.clearEntities(self.world)
   tiny.clearSystems(self.world)
   self.world = nil
end

local create_empty_entity = class(TinyBenchmark)
function create_empty_entity:run()
   for _ = 1, self.n_entities do
      tiny.addEntity(self.world, {})
   end
end

local create_entities = class.create_entities(TinyBenchmark)

function create_entities:run()
   for _ = 1, self.n_entities do
      tiny.addEntity(self.world, {
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
end

local EntityFactory = class(TinyBenchmark)

function EntityFactory:setup()
   self.world = tiny.world()
   self.entities = {}
   for _ = 1, self.n_entities do
      local entity = tiny.addEntity(self.world, {
         Position = {
            x = 0.0,
            y = 0.0,
         },
         Velocity = {
            x = 0.0,
            y = 0.0,
         },
         Optional = nil,
      })
      table.insert(self.entities, entity)
   end
end

local get_component = class(EntityFactory)

function get_component:run()
   --luacheck: ignore
   local component
   for i = 1, #self.entities do
      local entity = self.entities[i]
      component = entity.Position
   end
end

local get_components = class(EntityFactory)

function get_components:run()
   --luacheck: ignore
   local component
   for i = 1, #self.entities do
      local entity = self.entities[i]
      component = entity.Position
      component = entity.Velocity
      component = entity.Optional
   end
end

local remove_component = class(EntityFactory)

function remove_component:run()
   for i = 1, #self.entities do
      local entity = self.entities[i]
      entity.Position = nil
   end
end

local remove_components = class(EntityFactory)

function remove_components:run()
   for i = 1, #self.entities do
      local entity = self.entities[i]
      entity.Position = nil
      entity.Velocity = nil
      entity.Optional = nil
   end
end

local query = class(TinyBenchmark)
function query:setup()
   self.world = tiny.world()
   local padding, shuffle
   for i = 1, self.n_entities do
      local entity = tiny.addEntity(self.world, {
         Position = {
            x = 0.0,
            y = 0.0,
         },
         Velocity = {
            x = 0.0,
            y = 0.0,
         },
         Health = { health = 100.0 },
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
      elseif shuffle == 2 then
         entity.Health = nil
      end
   end

   local MovementSystem = tiny.processingSystem()
   MovementSystem.filter = tiny.requireAll("Position", "Velocity")
   function MovementSystem:process(e, dt) end
end

function query:run()
   tiny.update(self.world, 1 / 60)
end

return {
   create_empty_entity = create_empty_entity,
   create_entities = create_entities,
   get_component = get_component,
   get_components = get_components,
   remove_component = remove_component,
   remove_components = remove_components,
   query = query,
}
