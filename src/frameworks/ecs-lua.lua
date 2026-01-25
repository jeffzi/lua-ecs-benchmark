--[[
   ECS-Lua uses a deferred entity lifecycle model:
   - Entities created with world:Entity() have isAlive=false and are NOT in the repository
   - world:Update() activates entities (isAlive=true) and inserts them into the repository
   - Component changes on alive entities update the repository immediately (no Update needed)
   - Lifecycle events (OnEnter/OnExit) are deferred to Update(), but this is an optimization -
     structural work happens immediately

   We call Update() in before functions to make entities alive. We do NOT call Update()
   in component modification fn functions because ECS-Lua's optimization is that structural
   changes (archetype moves, query visibility) happen immediately.
--]]

---@diagnostic disable: unused-local
local ECS = require("lib.ecs-lua.ECS")
local shuffle = require("src.lib.utils").shuffle

local ecs_Component = ECS.Component
local ecs_System = ECS.System
local ecs_Query = ECS.Query
local ecs_World = ECS.World

-- ----------------------------------------------------------------------------
-- Setup
-- ----------------------------------------------------------------------------

local Position = ecs_Component({ x = 0.0, y = 0.0 })
local Velocity = ecs_Component({ x = 0.0, y = 0.0 })
local Optional = ecs_Component()
local Padding1 = ecs_Component()
local Padding2 = ecs_Component()
local Padding3 = ecs_Component()

local DT = 1000 / 60 / 1000

--- Create a new ECS world with timing info.
--- @return { world: table, timestep: number, dt: number } Context with world and timing.
local function create_world()
   return { world = ecs_World(nil, 60, false), timestep = 1, dt = DT }
end

--- Create a world populated with entities (with components).
--- @param _ctx table Unused previous context.
--- @param p { n_entities: number } Benchmark parameters.
--- @return { world: table, entities: table[], timestep: number, dt: number } Context.
local function create_populated_world(_ctx, p)
   local world = ecs_World(nil, 60, false)
   local entities = {}
   for i = 1, p.n_entities do
      entities[i] =
         world:Entity(Position({ x = 0.0, y = 0.0 }), Velocity({ x = 0.0, y = 0.0 }), Optional())
   end
   world:Update("process", DT) -- Make entities alive
   shuffle(entities)
   return { world = world, entities = entities, timestep = 1, dt = DT }
end

--- Create a world populated with empty entities.
--- @param _ctx table Unused previous context.
--- @param p { n_entities: number } Benchmark parameters.
--- @return { world: table, entities: table[], timestep: number, dt: number } Context.
local function create_empty_entities(_ctx, p)
   local world = ecs_World(nil, 60, false)
   local entities = {}
   for i = 1, p.n_entities do
      entities[i] = world:Entity()
   end
   world:Update("process", DT) -- Make entities alive
   shuffle(entities)
   return { world = world, entities = entities, timestep = 1, dt = DT }
end

--- Destroy the world.
--- @param ctx { world: table } Context with world.
local function destroy_world(ctx)
   ctx.world:Destroy()
end

--- Create system_update before function.
--- @param _ctx table Unused previous context.
--- @param p { n_entities: number } Benchmark parameters.
--- @return { world: table, timestep: number, dt: number } Context.
local function create_system_world(_ctx, p)
   local world = ecs_World(nil, 60, false)

   for i = 1, p.n_entities do
      local entity = world:Entity(Position({ x = 0.0, y = 0.0 }), Velocity({ x = 0.0, y = 0.0 }))

      local padding = i % 4
      if padding == 1 then
         entity.Padding1 = Padding1()
      elseif padding == 2 then
         entity.Padding2 = Padding2()
      elseif padding == 3 then
         entity.Padding3 = Padding3()
      end

      local should_shuffle = (i + 1) % 4
      if should_shuffle == 0 then
         entity:Unset(Position)
      elseif should_shuffle == 1 then
         entity:Unset(Velocity)
      end
   end

   ---@diagnostic disable-next-line: redefined-local
   local MovementSystem = ecs_System(
      "process",
      1,
      ecs_Query.All(Position, Velocity),
      function(self, Time)
         local dt = Time.DeltaFixed
         self:Result():ForEach(function(e)
            local position = e[Position]
            local velocity = e[Velocity]
            position.x = position.x + velocity.x * dt
            position.y = position.y + velocity.y * dt
         end)
      end
   )

   world:AddSystem(MovementSystem)
   return { world = world, timestep = 1, dt = DT }
end

-- ----------------------------------------------------------------------------
-- Default Tests
-- ----------------------------------------------------------------------------

local default = {
   add_empty_entity = {
      fn = function(ctx, p)
         local world = ctx.world
         local timestep = ctx.timestep + 1
         for _ = 1, p.n_entities do
            world:Entity()
         end
         world:Update("process", timestep * ctx.dt)
         ctx.timestep = timestep
      end,
      before = create_world,
      after = destroy_world,
   },

   remove_entities = {
      fn = function(ctx, _p)
         local world, entities = ctx.world, ctx.entities
         for i = 1, #entities do
            world:Remove(entities[i])
         end
         world:Update("process", ctx.timestep * ctx.dt)
      end,
      before = create_populated_world,
      after = destroy_world,
   },

   get_component = {
      fn = function(ctx, _p)
         local entities = ctx.entities
         for i = 1, #entities do
            local _ = entities[i][Position]
         end
      end,
      before = create_populated_world,
      after = destroy_world,
   },

   add_component = {
      fn = function(ctx, _p)
         local entities = ctx.entities
         for i = 1, #entities do
            entities[i][Position] = Position({ x = 0.0, y = 0.0 })
         end
      end,
      before = create_empty_entities,
      after = destroy_world,
   },

   remove_component = {
      fn = function(ctx, _p)
         local entities = ctx.entities
         for i = 1, #entities do
            entities[i]:Unset(Position)
         end
      end,
      before = create_populated_world,
      after = destroy_world,
   },

   system_update = {
      fn = function(ctx, _p)
         local timestep = ctx.timestep + 1
         ctx.world:Update("process", timestep * ctx.dt)
         ctx.timestep = timestep
      end,
      before = create_system_world,
      after = destroy_world,
   },
}

-- ----------------------------------------------------------------------------
-- Non-batch Tests
-- ----------------------------------------------------------------------------

local nobatch = {
   add_entities = {
      fn = function(ctx, p)
         local world = ctx.world
         local timestep = ctx.timestep + 1
         for _ = 1, p.n_entities do
            local e = world:Entity()
            e[Position] = Position({ x = 0.0, y = 0.0 })
            e[Velocity] = Velocity({ x = 0.0, y = 0.0 })
         end
         world:Update("process", timestep * ctx.dt)
         ctx.timestep = timestep
      end,
      before = create_world,
      after = destroy_world,
   },

   add_components = {
      fn = function(ctx, _p)
         local entities = ctx.entities
         for i = 1, #entities do
            local e = entities[i]
            e[Position] = Position({ x = 0.0, y = 0.0 })
            e[Velocity] = Velocity({ x = 0.0, y = 0.0 })
            e[Optional] = Optional()
         end
      end,
      before = create_empty_entities,
      after = destroy_world,
   },

   get_components = {
      fn = function(ctx, _p)
         local entities = ctx.entities
         for i = 1, #entities do
            local e = entities[i]
            local _ = e[Position]
            _ = e[Velocity]
            _ = e[Optional]
         end
      end,
      before = create_populated_world,
      after = destroy_world,
   },

   remove_components = {
      fn = function(ctx, _p)
         local entities = ctx.entities
         for i = 1, #entities do
            local e = entities[i]
            e:Unset(Position)
            e:Unset(Velocity)
            e:Unset(Optional)
         end
      end,
      before = create_populated_world,
      after = destroy_world,
   },
}

-- ----------------------------------------------------------------------------
-- Batch Tests
-- ----------------------------------------------------------------------------

local batch = {
   add_entities = {
      fn = function(ctx, p)
         local world = ctx.world
         local timestep = ctx.timestep + 1
         for _ = 1, p.n_entities do
            world:Entity(Position({ x = 0.0, y = 0.0 }), Velocity({ x = 0.0, y = 0.0 }))
         end
         world:Update("process", timestep * ctx.dt)
         ctx.timestep = timestep
      end,
      before = create_world,
      after = destroy_world,
   },

   add_components = {
      fn = function(ctx, _p)
         local entities = ctx.entities
         for i = 1, #entities do
            entities[i]:Set(
               Position({ x = 0.0, y = 0.0 }),
               Velocity({ x = 0.0, y = 0.0 }),
               Optional()
            )
         end
      end,
      before = create_empty_entities,
      after = destroy_world,
   },

   get_components = {
      fn = function(ctx, _p)
         local entities = ctx.entities
         for i = 1, #entities do
            local _ = entities[i]:Get(Position, Velocity, Optional)
         end
      end,
      before = create_populated_world,
      after = destroy_world,
   },

   remove_components = {
      fn = function(ctx, _p)
         local entities = ctx.entities
         for i = 1, #entities do
            entities[i]:Unset(Position, Velocity, Optional)
         end
      end,
      before = create_populated_world,
      after = destroy_world,
   },
}

-- ----------------------------------------------------------------------------
-- Module Export
-- ----------------------------------------------------------------------------

return {
   variants = {
      ["ecs-lua-default"] = default,
      ["ecs-lua-nobatch"] = nobatch,
      ["ecs-lua-batch"] = batch,
   },
}
