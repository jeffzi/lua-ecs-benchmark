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
local config = require("src.lib.config")
local shuffle = require("src.lib.utils").shuffle

local ecs_Component = ECS.Component
local ecs_System = ECS.System
local ecs_Query = ECS.Query
local ecs_World = ECS.World

local DT = config.DT
local WORLD_MULTIPLIER = config.WORLD_MULTIPLIER
local N_SYSTEMS = config.N_SYSTEMS

-- ----------------------------------------------------------------------------
-- Setup
-- ----------------------------------------------------------------------------

local Position = ecs_Component({ x = 0.0, y = 0.0 })
local Velocity = ecs_Component({ x = 0.0, y = 0.0 })
local Health = ecs_Component({ current = 100, max = 100 })
local Name = ecs_Component({ value = "" })
local Aggro = ecs_Component()
local Alive = ecs_Component()

local A = ecs_Component({ v = 0 })
local B = ecs_Component({ v = 0 })
local C = ecs_Component({ v = 0 })
local D = ecs_Component({ v = 0 })
local E = ecs_Component({ v = 0 })

-- Components for multi-system tests (Comp1-Comp10)
local Comp1 = ecs_Component({ value = 0 })
local Comp2 = ecs_Component({ value = 0 })
local Comp3 = ecs_Component({ value = 0 })
local Comp4 = ecs_Component({ value = 0 })
local Comp5 = ecs_Component({ value = 0 })
local Comp6 = ecs_Component({ value = 0 })
local Comp7 = ecs_Component({ value = 0 })
local Comp8 = ecs_Component({ value = 0 })
local Comp9 = ecs_Component({ value = 0 })
local Comp10 = ecs_Component({ value = 0 })

local NonExistent = ecs_Component({ value = 0 })

-- Buff components for archetype fragmentation tests
local BUFFS = {}
for _ = 1, config.N_BUFFS do
   BUFFS[#BUFFS + 1] = ecs_Component({ level = 0 })
end

local function make_default_entity(world)
   return world:Entity(Position({ x = 0.0, y = 0.0 }), Velocity({ x = 0.0, y = 0.0 }), Alive())
end

--- Factory: returns a `before` function that creates a populated world.
--- (WORLD_MULTIPLIER - 1) * N background + N tracked entities.
--- @param make_entity? fun(world: table): table Factory for tracked entities.
--- @return fun(_ctx: table, p: { n_entities: number }): { world: table, entities: table[], timestep: number, dt: number }
local function create_world(make_entity)
   make_entity = make_entity or make_default_entity
   return function(_ctx, p)
      local world = ecs_World(nil, 60, false)

      -- Background entities
      for _ = 1, p.n_entities * (WORLD_MULTIPLIER - 1) do
         world:Entity(Health({ current = 100, max = 100 }), Name({ value = "monster" }), Aggro())
      end

      -- Tracked entities for test operations
      local entities = {}
      for i = 1, p.n_entities do
         entities[i] = make_entity(world)
      end

      world:Update("process", DT)
      shuffle(entities)
      return { world = world, entities = entities, timestep = 1, dt = DT }
   end
end

--- Destroy the world.
--- @param ctx { world: table } Context with world.
local function destroy_world(ctx)
   ctx.world:Destroy()
   ctx.world = nil
   ctx.entities = nil
end

-- ----------------------------------------------------------------------------
-- Entity Tests
-- ----------------------------------------------------------------------------

--- @type luamark.Spec
local create_empty = {
   fn = function(ctx, p)
      local world = ctx.world
      local timestep = ctx.timestep + 1
      for _ = 1, p.n_entities do
         world:Entity()
      end
      world:Update("process", timestep * ctx.dt)
      ctx.timestep = timestep
   end,
   before = create_world(),
   after = destroy_world,
}

--- @type luamark.Spec
local destroy = {
   fn = function(ctx, _p)
      local world, entities = ctx.world, ctx.entities
      local timestep = ctx.timestep + 1
      for i = 1, #entities do
         world:Remove(entities[i])
      end
      world:Update("process", timestep * ctx.dt)
      ctx.timestep = timestep
   end,
   before = create_world(),
   after = destroy_world,
}

--- @type luamark.Spec
local nobatch_create_with_components = {
   fn = function(ctx, p)
      local world = ctx.world
      local timestep = ctx.timestep + 1
      for _ = 1, p.n_entities do
         local e = world:Entity()
         e[Position] = Position({ x = 0, y = 0 })
         e[Alive] = Alive()
      end
      world:Update("process", timestep * ctx.dt)
      ctx.timestep = timestep
   end,
   before = create_world(),
   after = destroy_world,
}

--- @type luamark.Spec
local batch_create_with_components = {
   fn = function(ctx, p)
      local world = ctx.world
      local timestep = ctx.timestep + 1
      for _ = 1, p.n_entities do
         world:Entity(Position({ x = 0, y = 0 }), Alive())
      end
      world:Update("process", timestep * ctx.dt)
      ctx.timestep = timestep
   end,
   before = create_world(),
   after = destroy_world,
}

-- ----------------------------------------------------------------------------
-- Component Tests
-- ----------------------------------------------------------------------------

--- @type luamark.Spec
local get = {
   fn = function(ctx, _p)
      local entities = ctx.entities
      for i = 1, #entities do
         local pos = entities[i][Position]
         local _ = pos.x
         local _ = pos.y
      end
   end,
   before = create_world(),
   after = destroy_world,
}

--- @type luamark.Spec
local set = {
   fn = function(ctx, _p)
      local entities = ctx.entities
      for i = 1, #entities do
         local pos = entities[i][Position]
         pos.x = 1.0
         pos.y = 1.0
      end
   end,
   before = create_world(),
   after = destroy_world,
}

--- @type luamark.Spec
local remove = {
   fn = function(ctx, _p)
      local entities = ctx.entities
      for i = 1, #entities do
         entities[i]:Unset(Velocity)
      end
   end,
   before = create_world(),
   after = destroy_world,
}

--- @type luamark.Spec
local nobatch_add = {
   fn = function(ctx, _p)
      local entities = ctx.entities
      for i = 1, #entities do
         entities[i][Name] = Name({ value = "monster" })
      end
   end,
   before = create_world(),
   after = destroy_world,
}

--- @type luamark.Spec
local batch_add = {
   fn = function(ctx, _p)
      local entities = ctx.entities
      for i = 1, #entities do
         entities[i]:Set(Name({ value = "monster" }))
      end
   end,
   before = create_world(),
   after = destroy_world,
}

-- ----------------------------------------------------------------------------
-- Tag Tests
-- ----------------------------------------------------------------------------

--- @type luamark.Spec
local has = {
   fn = function(ctx, _p)
      local entities = ctx.entities
      for i = 1, #entities do
         local _ = entities[i][Alive] ~= nil
      end
   end,
   before = create_world(),
   after = destroy_world,
}

--- @type luamark.Spec
local tag_remove = {
   fn = function(ctx, _p)
      local entities = ctx.entities
      for i = 1, #entities do
         entities[i]:Unset(Alive)
      end
   end,
   before = create_world(),
   after = destroy_world,
}

--- @type luamark.Spec
local nobatch_tag_add = {
   fn = function(ctx, _p)
      local entities = ctx.entities
      for i = 1, #entities do
         entities[i][Aggro] = Aggro()
      end
   end,
   before = create_world(),
   after = destroy_world,
}

--- @type luamark.Spec
local batch_tag_add = {
   fn = function(ctx, _p)
      local entities = ctx.entities
      for i = 1, #entities do
         entities[i]:Set(Aggro())
      end
   end,
   before = create_world(),
   after = destroy_world,
}

-- ----------------------------------------------------------------------------
-- System Tests
-- ----------------------------------------------------------------------------

--- @type luamark.Spec
local throughput = {
   fn = function(ctx, _p)
      local timestep = ctx.timestep + 1
      ctx.world:Update("process", timestep * ctx.dt)
      ctx.timestep = timestep
   end,
   before = function(_ctx, p)
      local world = ecs_World(nil, 60, false)

      for _ = 1, p.n_entities do
         world:Entity(Position({ x = 0.0, y = 0.0 }), Velocity({ x = 0.0, y = 0.0 }))
      end

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
      world:Update("process", DT)
      return { world = world, timestep = 1, dt = DT }
   end,
   after = destroy_world,
}

--- @type luamark.Spec
local overlap = {
   fn = function(ctx, _p)
      local timestep = ctx.timestep + 1
      ctx.world:Update("process", timestep * ctx.dt)
      ctx.timestep = timestep
   end,
   before = function(_ctx, p)
      local world = ecs_World(nil, 60, false)

      for i = 1, p.n_entities do
         local archetype = i % 4
         local e = world:Entity(A({ v = 0 }), B({ v = 0 }))
         if archetype >= 1 then
            e[C] = C({ v = 0 })
         end
         if archetype >= 2 then
            e[D] = D({ v = 0 })
         end
         if archetype == 3 then
            e:Unset(D)
            e[E] = E({ v = 0 })
         end
      end

      local SwapAB = ecs_System("process", 1, ecs_Query.All(A, B), function(self, _Time)
         self:Result():ForEach(function(e)
            e[A].v, e[B].v = e[B].v, e[A].v
         end)
      end)

      local SwapCD = ecs_System("process", 2, ecs_Query.All(C, D), function(self, _Time)
         self:Result():ForEach(function(e)
            e[C].v, e[D].v = e[D].v, e[C].v
         end)
      end)

      local SwapCE = ecs_System("process", 3, ecs_Query.All(C, E), function(self, _Time)
         self:Result():ForEach(function(e)
            e[C].v, e[E].v = e[E].v, e[C].v
         end)
      end)

      world:AddSystem(SwapAB)
      world:AddSystem(SwapCD)
      world:AddSystem(SwapCE)
      world:Update("process", DT)

      return { world = world, timestep = 1, dt = DT }
   end,
   after = destroy_world,
}

--- @type luamark.Spec
local fragmented = {
   fn = function(ctx, _p)
      local timestep = ctx.timestep + 1
      ctx.world:Update("process", timestep * ctx.dt)
      ctx.timestep = timestep
   end,
   before = function(_ctx, p)
      local world = ecs_World(nil, 60, false)

      for i = 1, p.n_entities do
         local buff_index = ((i - 1) % #BUFFS) + 1
         local e = world:Entity(Position({ x = 0.0, y = 0.0 }))
         e[BUFFS[buff_index]] = BUFFS[buff_index]({ level = buff_index })
      end

      local sum = 0

      local PositionSystem = ecs_System("process", 1, ecs_Query.All(Position), function(self, _Time)
         self:Result():ForEach(function(e)
            local pos = e[Position]
            sum = sum + pos.x + pos.y
         end)
      end)

      local Buff1System = ecs_System("process", 2, ecs_Query.All(BUFFS[1]), function(self, _Time)
         self:Result():ForEach(function(e)
            sum = sum + e[BUFFS[1]].level
         end)
      end)

      world:AddSystem(PositionSystem)
      world:AddSystem(Buff1System)
      world:Update("process", DT)
      return { world = world, timestep = 1, dt = DT }
   end,
   after = destroy_world,
}

--- @type luamark.Spec
local chained = {
   fn = function(ctx, _p)
      local timestep = ctx.timestep + 1
      ctx.world:Update("process", timestep * ctx.dt)
      ctx.timestep = timestep
   end,
   before = function(_ctx, p)
      local world = ecs_World(nil, 60, false)

      for _ = 1, p.n_entities do
         world:Entity(A({ v = 1 }), B({ v = 0 }), C({ v = 0 }), D({ v = 0 }), E({ v = 0 }))
      end

      local SysAB = ecs_System("process", 1, ecs_Query.All(A, B), function(self, _Time)
         self:Result():ForEach(function(e)
            e[B].v = e[A].v
         end)
      end)

      local SysBC = ecs_System("process", 2, ecs_Query.All(B, C), function(self, _Time)
         self:Result():ForEach(function(e)
            e[C].v = e[B].v
         end)
      end)

      local SysCD = ecs_System("process", 3, ecs_Query.All(C, D), function(self, _Time)
         self:Result():ForEach(function(e)
            e[D].v = e[C].v
         end)
      end)

      local SysDE = ecs_System("process", 4, ecs_Query.All(D, E), function(self, _Time)
         self:Result():ForEach(function(e)
            e[E].v = e[D].v
         end)
      end)

      world:AddSystem(SysAB)
      world:AddSystem(SysBC)
      world:AddSystem(SysCD)
      world:AddSystem(SysDE)
      world:Update("process", DT)

      return { world = world, timestep = 1, dt = DT }
   end,
   after = destroy_world,
}

--- @type luamark.Spec
local multi_20 = {
   fn = function(ctx, _p)
      local timestep = ctx.timestep + 1
      ctx.world:Update("process", timestep * ctx.dt)
      ctx.timestep = timestep
   end,
   before = function(_ctx, p)
      local world = ecs_World(nil, 60, false)

      for _ = 1, p.n_entities do
         world:Entity(
            Comp1({ value = 0 }),
            Comp2({ value = 0 }),
            Comp3({ value = 0 }),
            Comp4({ value = 0 }),
            Comp5({ value = 0 }),
            Comp6({ value = 0 }),
            Comp7({ value = 0 }),
            Comp8({ value = 0 }),
            Comp9({ value = 0 }),
            Comp10({ value = 0 })
         )
      end

      local comps = { Comp1, Comp2, Comp3, Comp4, Comp5, Comp6, Comp7, Comp8, Comp9, Comp10 }
      local sum = 0
      local priority = 1

      for _, comp in ipairs(comps) do
         local sys1 = ecs_System("process", priority, ecs_Query.All(comp), function(self, _Time)
            local c = self.comp
            self:Result():ForEach(function(e)
               sum = sum + e[c].value
            end)
         end)
         sys1.comp = comp
         world:AddSystem(sys1)
         priority = priority + 1

         local sys2 = ecs_System("process", priority, ecs_Query.All(comp), function(self, _Time)
            local c = self.comp
            self:Result():ForEach(function(e)
               sum = sum + e[c].value
            end)
         end)
         sys2.comp = comp
         world:AddSystem(sys2)
         priority = priority + 1
      end

      world:Update("process", DT)
      return { world = world, timestep = 1, dt = DT }
   end,
   after = destroy_world,
}

--- @type luamark.Spec
local empty_systems = {
   fn = function(ctx, _p)
      local timestep = ctx.timestep + 1
      ctx.world:Update("process", timestep * ctx.dt)
      ctx.timestep = timestep
   end,
   before = function(_ctx, p)
      local world = ecs_World(nil, 60, false)

      for _ = 1, p.n_entities do
         world:Entity(Position({ x = 0.0, y = 0.0 }))
      end

      for i = 1, 20 do
         local sys = ecs_System("process", i, ecs_Query.All(NonExistent), function(self, Time)
            local dt = Time.DeltaFixed
            self:Result():ForEach(function(e)
               e[NonExistent].value = e[NonExistent].value + dt
            end)
         end)
         world:AddSystem(sys)
      end

      world:Update("process", DT)
      return { world = world, timestep = 1, dt = DT }
   end,
   after = destroy_world,
}

-- ----------------------------------------------------------------------------
-- Structural Scaling Tests
-- ----------------------------------------------------------------------------

--- Factory: returns a `before` that creates a populated world with N_SYSTEMS background systems.
--- @param make_entity? fun(world: table): table Factory for tracked entities.
--- @return fun(_ctx: table, p: { n_entities: number }): table
local function create_scaling_world(make_entity)
   make_entity = make_entity or make_default_entity
   return function(_ctx, p)
      local world = ecs_World(nil, 60, false)

      for i = 1, N_SYSTEMS do
         local sys = ecs_System("process", i, ecs_Query.All(Position, Velocity), function() end)
         world:AddSystem(sys)
      end

      -- Background entities
      for _ = 1, p.n_entities * (WORLD_MULTIPLIER - 1) do
         world:Entity(Health({ current = 100, max = 100 }), Name({ value = "monster" }), Aggro())
      end

      -- Tracked entities for test operations
      local entities = {}
      for i = 1, p.n_entities do
         entities[i] = make_entity(world)
      end

      world:Update("process", DT)
      shuffle(entities)
      return { world = world, entities = entities, timestep = 1, dt = DT }
   end
end

--- @type luamark.Spec
local scaling_destroy = {
   fn = function(ctx, _p)
      local world, entities = ctx.world, ctx.entities
      local timestep = ctx.timestep + 1
      for i = 1, #entities do
         world:Remove(entities[i])
      end
      world:Update("process", timestep * ctx.dt)
      ctx.timestep = timestep
   end,
   before = create_scaling_world(),
   after = destroy_world,
}

--- @type luamark.Spec
local nobatch_scaling_create = {
   fn = function(ctx, p)
      local world = ctx.world
      local timestep = ctx.timestep + 1
      for _ = 1, p.n_entities do
         local e = world:Entity()
         e[Position] = Position({ x = 0, y = 0 })
         e[Alive] = Alive()
      end
      world:Update("process", timestep * ctx.dt)
      ctx.timestep = timestep
   end,
   before = create_scaling_world(),
   after = destroy_world,
}

--- @type luamark.Spec
local batch_scaling_create = {
   fn = function(ctx, p)
      local world = ctx.world
      local timestep = ctx.timestep + 1
      for _ = 1, p.n_entities do
         world:Entity(Position({ x = 0, y = 0 }), Alive())
      end
      world:Update("process", timestep * ctx.dt)
      ctx.timestep = timestep
   end,
   before = create_scaling_world(),
   after = destroy_world,
}

--- @type luamark.Spec
local nobatch_scaling_add_component = {
   fn = function(ctx, _p)
      local entities = ctx.entities
      for i = 1, #entities do
         entities[i][Name] = Name({ value = "monster" })
      end
   end,
   before = create_scaling_world(),
   after = destroy_world,
}

--- @type luamark.Spec
local batch_scaling_add_component = {
   fn = function(ctx, _p)
      local entities = ctx.entities
      for i = 1, #entities do
         entities[i]:Set(Name({ value = "monster" }))
      end
   end,
   before = create_scaling_world(),
   after = destroy_world,
}

-- ----------------------------------------------------------------------------
-- Module Export
-- ----------------------------------------------------------------------------

--- @type VariantModule
return {
   variants = {
      ["ecs-lua"] = {
         entity = {
            create_empty = create_empty,
            destroy = destroy,
         },
         component = {
            get = get,
            set = set,
            remove = remove,
         },
         tag = {
            has = has,
            remove = tag_remove,
         },
         system = {
            throughput = throughput,
            overlap = overlap,
            fragmented = fragmented,
            chained = chained,
            multi_20 = multi_20,
            empty_systems = empty_systems,
         },
         structural_scaling = {
            destroy = scaling_destroy,
         },
      },
      ["ecs-lua-nobatch"] = {
         entity = {
            create_with_components = nobatch_create_with_components,
         },
         component = {
            add = nobatch_add,
         },
         tag = {
            add = nobatch_tag_add,
         },
         structural_scaling = {
            create = nobatch_scaling_create,
            add_component = nobatch_scaling_add_component,
         },
      },
      ["ecs-lua-batch"] = {
         entity = {
            create_with_components = batch_create_with_components,
         },
         component = {
            add = batch_add,
         },
         tag = {
            add = batch_tag_add,
         },
         structural_scaling = {
            create = batch_scaling_create,
            add_component = batch_scaling_add_component,
         },
      },
   },
}
