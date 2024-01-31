---@diagnostic disable: unused-local
local Benchmark = require("src.Benchmark")
local class = require("pl.class")
local nata = require("lib.nata.nata")

local NataBenchmark = class(Benchmark)

function NataBenchmark:setup()
   self.pool = nata.new()
end
function NataBenchmark:teardown()
   self.pool = nil
end

local create_empty_entity = class(NataBenchmark)
function create_empty_entity:run()
   for _ = 1, self.n_entities do
      self.pool:queue({})
   end
   self.pool:flush()
end

local create_entities = class.create_entities(NataBenchmark)

function create_entities:run()
   for _ = 1, self.n_entities do
      self.pool:queue({
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
   self.pool:flush()
end

local EntityFactory = class(NataBenchmark)

function EntityFactory:setup(empty)
   self.pool = nata.new()
   self.entities = {}
   local entity
   for _ = 1, self.n_entities do
      if empty then
         entity = self.pool:queue({})
      else
         entity = self.pool:queue({
            Position = {
               x = 0.0,
               y = 0.0,
            },
            Velocity = {
               x = 0.0,
               y = 0.0,
            },
            Optional = {},
         })
      end

      table.insert(self.entities, entity)
   end
   self.pool:flush()
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
   local component, entity
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
   --luacheck: ignore
   for i = 1, #self.entities do
      self.entities[i].Position = {
         x = 0.0,
         y = 0.0,
      }
   end
end

local add_components = class(add_component)

function add_components:run()
   --luacheck: ignore
   local entity
   for i = 1, #self.entities do
      entity = self.entities[i]
      entity.Position = {
         x = 0.0,
         y = 0.0,
      }
      entity.Velocity = {
         x = 0.0,
         y = 0.0,
      }
      entity.Optional = {}
   end
end

local remove_component = class(EntityFactory)

function remove_component:run()
   for i = 1, #self.entities do
      self.entities[i].Position = nil
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

local system_update = class(NataBenchmark)

function system_update:setup()
   local MovementSystem = {}

   function MovementSystem:update(dt)
      local position, velocity
      for _, e in pairs(self.pool.groups.move.entities) do
         position = e.Position
         velocity = e.Velocity
         position.x = position.x + velocity.x * dt
         position.y = position.y + velocity.y * dt
      end
   end

   self.pool = nata.new({
      groups = {
         move = { filter = { "Position", "Velocity" } },
      },
      systems = {
         MovementSystem,
      },
   })

   local entity, padding, shuffle
   for i = 1, self.n_entities do
      entity = self.pool:queue({
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
   self.pool:flush()
end

function system_update:run()
   self.pool:emit("update", 1 / 60)
end

return {
   create_empty_entity = create_empty_entity,
   create_entities = create_entities,
   get_component = get_component,
   get_components = get_components,
   add_component = add_component,
   add_components = add_components,
   remove_component = remove_component,
   remove_components = remove_components,
   system_update = system_update,
}
