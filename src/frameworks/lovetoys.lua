---@diagnostic disable: unused-local
local lovetoys = require("lovetoys")
local shuffle = require("src.lib.utils").shuffle

lovetoys.initialize()
local lt_class = lovetoys.class
local lt_Component = lovetoys.Component
local lt_Engine = lovetoys.Engine
local lt_Entity = lovetoys.Entity
local lt_System = lovetoys.System

-- ----------------------------------------------------------------------------
-- Setup
-- ----------------------------------------------------------------------------

local Position = lt_Component.create("Position", { "x", "y" }, { x = 0, y = 0 })
local Velocity = lt_Component.create("Velocity", { "x", "y" }, { x = 0, y = 0 })
local Optional = lt_Component.create("Optional")
local Padding1 = lt_Component.create("Padding1")
local Padding2 = lt_Component.create("Padding2")
local Padding3 = lt_Component.create("Padding3")

--- Create a new engine.
--- @return { engine: table } Context with engine.
local function create_engine()
   return { engine = lt_Engine() }
end

--- Create an engine populated with entities (with components).
--- @param _ctx table Unused previous context.
--- @param p { n_entities: number } Benchmark parameters.
--- @return { engine: table, entities: table[] } Context with engine and entities.
local function create_populated_engine(_ctx, p)
   local engine = lt_Engine()
   local entities = {}
   for i = 1, p.n_entities do
      local e = lt_Entity()
      e:initialize()
      e:add(Position(0, 0))
      e:add(Velocity(0, 0))
      e:add(Optional())
      engine:addEntity(e)
      entities[i] = e
   end
   shuffle(entities)
   return { engine = engine, entities = entities }
end

--- Create an engine populated with empty entities.
--- @param _ctx table Unused previous context.
--- @param p { n_entities: number } Benchmark parameters.
--- @return { engine: table, entities: table[] } Context with engine and entities.
local function create_empty_entities(_ctx, p)
   local engine = lt_Engine()
   local entities = {}
   for i = 1, p.n_entities do
      local e = lt_Entity()
      e:initialize()
      engine:addEntity(e)
      entities[i] = e
   end
   shuffle(entities)
   return { engine = engine, entities = entities }
end

--- Clear the engine (no-op, just nil out for GC).
--- @param ctx { engine: table } Context with engine.
local function clear_engine(ctx)
   ctx.engine = nil
end

--- Create system_update before function.
--- @param _ctx table Unused previous context.
--- @param p { n_entities: number } Benchmark parameters.
--- @return { engine: table } Context with engine.
local function create_system_engine(_ctx, p)
   local engine = lt_Engine()
   for i = 1, p.n_entities do
      local e = lt_Entity()
      e:initialize()
      e:add(Position(0, 0))
      e:add(Velocity(0, 0))
      engine:addEntity(e)

      local padding = i % 4
      if padding == 1 then
         e:add(Padding1())
      elseif padding == 2 then
         e:add(Padding2())
      elseif padding == 3 then
         e:add(Padding3())
      end

      local should_shuffle = (i + 1) % 4
      if should_shuffle == 0 then
         e:remove("Position")
      elseif should_shuffle == 1 then
         e:remove("Velocity")
      end
   end

   local MovementSystem = lt_class("MovementSystem", lt_System)

   function MovementSystem:requires()
      return { "Position", "Velocity" }
   end

   function MovementSystem:update(dt)
      for _, e in pairs(self.targets) do
         local position = e:get("Position")
         local velocity = e:get("Velocity")
         position.x = position.x + velocity.x * dt
         position.y = position.y + velocity.y * dt
      end
   end

   engine:addSystem(MovementSystem())
   return { engine = engine }
end

-- ----------------------------------------------------------------------------
-- Entity Tests
-- ----------------------------------------------------------------------------

--- @type BenchmarkSpec
local create_empty = {
   fn = function(ctx, p)
      local engine = ctx.engine
      for _ = 1, p.n_entities do
         local e = lt_Entity()
         e:initialize()
         engine:addEntity(e)
      end
   end,
   before = create_engine,
   after = clear_engine,
}

--- @type BenchmarkSpec
local create_with_components = {
   fn = function(ctx, p)
      local engine = ctx.engine
      for _ = 1, p.n_entities do
         local e = lt_Entity()
         e:initialize()
         e:add(Position(0, 0))
         e:add(Velocity(0, 0))
         engine:addEntity(e)
      end
   end,
   before = create_engine,
   after = clear_engine,
}

--- @type BenchmarkSpec
local destroy = {
   fn = function(ctx, _p)
      local engine, entities = ctx.engine, ctx.entities
      for i = 1, #entities do
         engine:removeEntity(entities[i])
      end
   end,
   before = create_populated_engine,
   after = clear_engine,
}

-- ----------------------------------------------------------------------------
-- Component Tests
-- ----------------------------------------------------------------------------

--- @type BenchmarkSpec
local get = {
   fn = function(ctx, _p)
      local entities = ctx.entities
      for i = 1, #entities do
         local e = entities[i]
         local _ = e:get("Position")
         _ = e:get("Velocity")
         _ = e:get("Optional")
      end
   end,
   before = create_populated_engine,
   after = clear_engine,
}

--- @type BenchmarkSpec
local remove = {
   fn = function(ctx, _p)
      local entities = ctx.entities
      for i = 1, #entities do
         local e = entities[i]
         e:remove("Position")
         e:remove("Velocity")
         e:remove("Optional")
      end
   end,
   before = create_populated_engine,
   after = clear_engine,
}

--- @type BenchmarkSpec
local nobatch_add = {
   fn = function(ctx, _p)
      local entities = ctx.entities
      for i = 1, #entities do
         local e = entities[i]
         e:add(Position(0, 0))
         e:add(Velocity(0, 0))
         e:add(Optional())
      end
   end,
   before = create_empty_entities,
   after = clear_engine,
}

--- @type BenchmarkSpec
local batch_add = {
   fn = function(ctx, _p)
      local entities = ctx.entities
      for i = 1, #entities do
         entities[i]:addMultiple({ Position(0, 0), Velocity(0, 0), Optional() })
      end
   end,
   before = create_empty_entities,
   after = clear_engine,
}

-- ----------------------------------------------------------------------------
-- System Tests
-- ----------------------------------------------------------------------------

--- @type BenchmarkSpec
local update = {
   fn = function(ctx, _p)
      ctx.engine:update(1 / 60)
   end,
   before = create_system_engine,
   after = clear_engine,
}

-- ----------------------------------------------------------------------------
-- Module Export
-- ----------------------------------------------------------------------------

--- @type VariantModule
return {
   variants = {
      ["lovetoys"] = {
         entity = {
            create_empty = create_empty,
            create_with_components = create_with_components,
            destroy = destroy,
         },
         component = {
            get = get,
            remove = remove,
         },
         system = {
            update = update,
         },
      },
      ["lovetoys-nobatch"] = {
         component = {
            add = nobatch_add,
         },
      },
      ["lovetoys-batch"] = {
         component = {
            add = batch_add,
         },
      },
   },
}
