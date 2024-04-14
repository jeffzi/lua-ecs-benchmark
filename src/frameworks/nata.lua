---@diagnostic disable: unused-local
local Benchmark = require("src.Benchmark")
local class = require("pl.class")
local nata = require("lib.nata.nata")

local NataBenchmark = class(Benchmark)

function NataBenchmark:iteration_setup()
   self.pool = nata.new()
end
function NataBenchmark:iteration_teardown()
   self.pool = nil
end

local add_empty_entity = class(NataBenchmark)
function add_empty_entity:run()
   local pool = self.pool
   for _ = 1, self.n_entities do
      pool:queue({})
   end
   pool:flush()
end

local add_entities = class.add_entities(NataBenchmark)

function add_entities:run()
   local pool = self.pool
   for _ = 1, self.n_entities do
      pool:queue({
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
   pool:flush()
end

local EntityFactory = class(NataBenchmark)

function EntityFactory:iteration_setup(empty)
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

local remove_entities = class(EntityFactory)

local function should_remove(entity)
   return entity.dead
end

function remove_entities:run()
   local pool, entities = self.pool, self.entities
   for i = 1, #entities do
      entities[i].dead = true
   end
   pool:remove(should_remove)
end

local get_component = class(EntityFactory)

function get_component:run()
   local entities = self.entities
   for i = 1, #entities do
      --luacheck: ignore
      local component = entities[i].Position
   end
end

local get_components = class(EntityFactory)
function get_components:run()
   local entities = self.entities
   for i = 1, #entities do
      local entity = entities[i]
      --luacheck: ignore
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
   local pool, entities = self.pool, self.entities
   for i = 1, #entities do
      local entity = entities[i]
      entity.Position = {
         x = 0.0,
         y = 0.0,
      }
      pool:queue(entity)
   end
   pool:flush()
end

local add_components = class(add_component)

function add_components:run()
   local pool, entities = self.pool, self.entities
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
      entity.Optional = {}
      pool:queue(entity)
   end
   pool:flush()
end

local remove_component = class(EntityFactory)

function remove_component:run()
   local pool, entities = self.pool, self.entities
   for i = 1, #entities do
      local entity = entities[i]
      entity.Position = nil
      pool:queue(entity)
   end
   pool:flush()
end

local remove_components = class(EntityFactory)

function remove_components:run()
   local pool = self.pool
   local entities = self.entities
   for i = 1, #entities do
      local entity = entities[i]
      entity.Position = nil
      entity.Velocity = nil
      entity.Optional = nil
      pool:queue(entity)
   end
   pool:flush()
end

local system_update = class(NataBenchmark)

function system_update:global_setup()
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

function system_update:global_teardown()
   self.pool = nil
end

function system_update:run()
   self.pool:emit("update", 1 / 60)
end

return {
   add_empty_entity = add_empty_entity,
   add_entities = add_entities,
   get_component = get_component,
   get_components = get_components,
   add_component = add_component,
   add_components = add_components,
   remove_component = remove_component,
   remove_components = remove_components,
   system_update = system_update,
}
