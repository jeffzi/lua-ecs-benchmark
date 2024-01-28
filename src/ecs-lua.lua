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

function ECSBenchmark:setup()
   self.world = ECS.World()
   self.world:SetFrequency(60)
end

function ECSBenchmark:teardown()
   self.world:Destroy()
   self.world = nil
end

local create_empty_entity = class(ECSBenchmark)
function create_empty_entity:run()
   for _ = 1, self.n_entities do
      self.world:Entity()
   end
end

local create_entities = class.create_entities(ECSBenchmark)

function create_entities:run()
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
end

local EntityFactory = class(ECSBenchmark)

function EntityFactory:setup()
   self.world = ECS.World()
   self.entities = {}
   local entity
   for _ = 1, self.n_entities do
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
      table.insert(self.entities, entity)
   end
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

local set_component = class(EntityFactory)

function set_component:run()
   --luacheck: ignore
   for i = 1, #self.entities do
      self.entities[i].Position = Position({
         x = 0.0,
         y = 0.0,
      })
   end
end

local set_components = class(EntityFactory)

function set_components:run()
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

local system_update = class(ECSBenchmark)
function system_update:setup()
   self.world = ECS.World(nil, 60, false)
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
   self.timestep = 1
   self.dt = 1000 / 60 / 1000
end

function system_update:run()
   self.timestep = self.timestep + 1
   self.world:Update("process", self.timestep * self.dt)
end

return {
   create_empty_entity = create_empty_entity,
   create_entities = create_entities,
   get_component = get_component,
   get_components = get_components,
   set_component = set_component,
   set_components = set_components,
   remove_component = remove_component,
   remove_components = remove_components,
   system_update = system_update,
}
