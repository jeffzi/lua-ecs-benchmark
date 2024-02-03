---@diagnostic disable: unused-local
local Benchmark = require("src.Benchmark")
local ECS = require("lib.ecs-lua.ECS")
local class = require("pl.class")

local Component, System, Query = ECS.Component, ECS.System, ECS.Query

local Position = Component({
   x = 0.0,
   y = 0.0,
})

local Velocity = Component({
   x = 0.0,
   y = 0.0,
})

local Optional = Component()
local Padding1 = Component()
local Padding2 = Component()
local Padding3 = Component()

local ECSBenchmark = class(Benchmark)

function ECSBenchmark:iteration_setup()
   self.world = ECS.World(nil, 60, false)
   self.timestep = 1
   self.dt = 1000 / 60 / 1000
end

function ECSBenchmark:iteration_teardown()
   self.world:Destroy()
   self.world = nil
end

local add_empty_entity = class(ECSBenchmark)

function add_empty_entity:run()
   for _ = 1, self.n_entities do
      self.world:Entity()
   end
   self.timestep = self.timestep + 1
   self.world:Update("process", self.timestep * self.dt)
end

local add_entities = class.add_entities(ECSBenchmark)

function add_entities:run()
   for _ = 1, self.n_entities do
      self.world:Entity(
         Position({
            x = 0.0,
            y = 0.0,
         }),
         Velocity({
            x = 0.0,
            y = 0.0,
         })
      )
   end
   self.timestep = self.timestep + 1
   self.world:Update("process", self.timestep * self.dt)
end

local EntityFactory = class(ECSBenchmark)

function EntityFactory:iteration_setup(empty)
   self.world = ECS.World(nil, 60, false)
   self.timestep = 1
   self.dt = 1000 / 60 / 1000

   self.entities = {}
   local entity
   for _ = 1, self.n_entities do
      if empty then
         entity = self.world:Entity()
      else
         entity = self.world:Entity(
            Position({
               x = 0.0,
               y = 0.0,
            }),
            Velocity({
               x = 0.0,
               y = 0.0,
            }, Optional())
         )
      end
      table.insert(self.entities, entity)
   end
end

local remove_entities = class(EntityFactory)

function remove_entities:run()
   for i = 1, #self.entities do
      self.world:Remove(self.entities[i])
   end
   self.world:Update("process", self.timestep * self.dt)
end

local get_component = class(EntityFactory)

function get_component:run()
   --luacheck: ignore
   local component
   for i = 1, #self.entities do
      component = self.entities[i][Position]
   end
end

local get_components = class(EntityFactory)

function get_components:run()
   --luacheck: ignore
   local components, entity
   for i = 1, #self.entities do
      entity = self.entities[i]
      components = entity:Get(Position, Velocity, Position)
   end
end

local add_component = class(EntityFactory)

function add_component:iteration_setup()
   EntityFactory.iteration_setup(self, true)
end

function add_component:run()
   --luacheck: ignore
   for i = 1, #self.entities do
      self.entities[i].Position = Position({
         x = 0.0,
         y = 0.0,
      })
   end
end

local add_components = class(add_component)

function add_components:run()
   --luacheck: ignore
   for i = 1, #self.entities do
      self.entities[i]:Set(
         Position({
            x = 0.0,
            y = 0.0,
         }),
         Velocity({
            x = 0.0,
            y = 0.0,
         }),
         Optional()
      )
   end
end

local remove_component = class(EntityFactory)

function remove_component:run()
   for i = 1, #self.entities do
      -- = nil doesn't work
      self.entities[i]:Unset(Position)
   end
end

local remove_components = class(EntityFactory)

function remove_components:run()
   for i = 1, #self.entities do
      self.entities[i]:Unset(Position, Velocity, Optional)
   end
end

local system_update = class(Benchmark)
function system_update:global_setup()
   self.world = ECS.World(nil, 60, false)
   self.timestep = 1
   self.dt = 1000 / 60 / 1000

   local entity, padding, shuffle
   for i = 1, self.n_entities do
      entity = self.world:Entity(
         Position({
            x = 0.0,
            y = 0.0,
         }),
         Velocity({
            x = 0.0,
            y = 0.0,
         })
      )
      padding = i % 4
      if padding == 1 then
         entity.Padding1 = Padding1()
      elseif padding == 2 then
         entity.Padding2 = Padding2()
      elseif padding == 3 then
         entity.Padding3 = Padding3()
      end

      shuffle = (i + 1) % 4
      if shuffle == 0 then
         entity:Unset(Position)
      elseif shuffle == 1 then
         entity:Unset(Velocity)
      end
   end

   ---@diagnostic disable-next-line: redefined-local
   local MovementSystem = System("process", 1, Query.All(Position, Velocity), function(self, Time)
      local dt = Time.DeltaFixed

      self:Result():ForEach(function(e)
         local position = e[Position]
         local velocity = e[Velocity]
         position.x = position.y + velocity.x * dt
         position.y = position.y + velocity.y * dt
      end)
   end)

   self.world:AddSystem(MovementSystem)
end

function system_update:global_teardown()
   self.world:Destroy()
   self.world = nil
end

function system_update:run()
   self.timestep = self.timestep + 1
   self.world:Update("process", self.timestep * self.dt)
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
