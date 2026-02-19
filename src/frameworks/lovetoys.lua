---@diagnostic disable: unused-local
local config = require("src.lib.config")
local lovetoys = require("lovetoys")
local shuffle = require("src.lib.utils").shuffle

lovetoys.initialize()
local lt_class = lovetoys.class
local lt_Component = lovetoys.Component
local lt_Engine = lovetoys.Engine
local lt_Entity = lovetoys.Entity
local lt_System = lovetoys.System

local DT = config.DT
local WORLD_MULTIPLIER = config.WORLD_MULTIPLIER

-- ----------------------------------------------------------------------------
-- Setup
-- ----------------------------------------------------------------------------

local Position = lt_Component.create("Position", { "x", "y" }, { x = 0, y = 0 })
local Velocity = lt_Component.create("Velocity", { "x", "y" }, { x = 0, y = 0 })
local Health = lt_Component.create("Health", { "current", "max" }, { current = 100, max = 100 })
local Name = lt_Component.create("Name", { "value" }, { value = "" })
local Aggro = lt_Component.create("Aggro")
local Alive = lt_Component.create("Alive")

local A = lt_Component.create("A", { "v" }, { v = 0 })
local B = lt_Component.create("B", { "v" }, { v = 0 })
local C = lt_Component.create("C", { "v" }, { v = 0 })
local D = lt_Component.create("D", { "v" }, { v = 0 })
local E = lt_Component.create("E", { "v" }, { v = 0 })

-- Components for multi-system tests (Comp1-Comp10)
local Comp1 = lt_Component.create("Comp1", { "value" }, { value = 0 })
local Comp2 = lt_Component.create("Comp2", { "value" }, { value = 0 })
local Comp3 = lt_Component.create("Comp3", { "value" }, { value = 0 })
local Comp4 = lt_Component.create("Comp4", { "value" }, { value = 0 })
local Comp5 = lt_Component.create("Comp5", { "value" }, { value = 0 })
local Comp6 = lt_Component.create("Comp6", { "value" }, { value = 0 })
local Comp7 = lt_Component.create("Comp7", { "value" }, { value = 0 })
local Comp8 = lt_Component.create("Comp8", { "value" }, { value = 0 })
local Comp9 = lt_Component.create("Comp9", { "value" }, { value = 0 })
local Comp10 = lt_Component.create("Comp10", { "value" }, { value = 0 })

lt_Component.create("NonExistent", { "value" }, { value = 0 })

local BUFFS = {}
for i, name in ipairs(config.generate_buff_names(config.N_BUFFS)) do
   BUFFS[i] = lt_Component.create(name, { "level" }, { level = 0 })
end

local function make_default_entity(engine)
   local e = lt_Entity()
   e:initialize()
   e:add(Position(0, 0))
   e:add(Velocity(0, 0))
   e:add(Alive())
   engine:addEntity(e)
   return e
end

--- Factory: returns a `before` function that creates a populated engine.
--- (WORLD_MULTIPLIER - 1) * N background + N tracked entities.
--- @param make_entity? fun(engine: table): table Factory for tracked entities.
--- @return fun(_ctx: table, p: { n_entities: number }): { engine: table, entities: table[] }
local function create_world(make_entity)
   make_entity = make_entity or make_default_entity
   return function(_ctx, p)
      local engine = lt_Engine()

      -- Background entities
      for _ = 1, p.n_entities * (WORLD_MULTIPLIER - 1) do
         local e = lt_Entity()
         e:initialize()
         e:add(Health(100, 100))
         e:add(Name("monster"))
         e:add(Aggro())
         engine:addEntity(e)
      end

      -- Tracked entities for test operations
      local entities = {}
      for i = 1, p.n_entities do
         entities[i] = make_entity(engine)
      end

      shuffle(entities)
      return { engine = engine, entities = entities }
   end
end

--- Clear the engine.
--- @param ctx { engine: table } Context with engine.
local function clear_engine(ctx)
   ctx.engine = nil
   ctx.entities = nil
end

-- ----------------------------------------------------------------------------
-- Entity Tests
-- ----------------------------------------------------------------------------

--- @type luamark.Spec
local create_empty = {
   fn = function(ctx, p)
      local engine = ctx.engine
      for _ = 1, p.n_entities do
         local e = lt_Entity()
         e:initialize()
         engine:addEntity(e)
      end
   end,
   before = create_world(),
   after = clear_engine,
}

--- @type luamark.Spec
local create_with_components = {
   fn = function(ctx, p)
      local engine = ctx.engine
      for _ = 1, p.n_entities do
         local e = lt_Entity()
         e:initialize()
         e:add(Position(0, 0))
         e:add(Alive())
         engine:addEntity(e)
      end
   end,
   before = create_world(),
   after = clear_engine,
}

--- @type luamark.Spec
local destroy = {
   fn = function(ctx, _p)
      local engine, entities = ctx.engine, ctx.entities
      for i = 1, #entities do
         engine:removeEntity(entities[i])
      end
   end,
   before = create_world(),
   after = clear_engine,
}

-- ----------------------------------------------------------------------------
-- Component Tests
-- ----------------------------------------------------------------------------

--- @type luamark.Spec
local get = {
   fn = function(ctx, _p)
      local entities = ctx.entities
      for i = 1, #entities do
         local pos = entities[i]:get("Position")
         local _ = pos.x
         local _ = pos.y
      end
   end,
   before = create_world(),
   after = clear_engine,
}

--- @type luamark.Spec
local set = {
   fn = function(ctx, _p)
      local entities = ctx.entities
      for i = 1, #entities do
         local pos = entities[i]:get("Position")
         pos.x = 1.0
         pos.y = 1.0
      end
   end,
   before = create_world(),
   after = clear_engine,
}

--- @type luamark.Spec
local remove = {
   fn = function(ctx, _p)
      local entities = ctx.entities
      for i = 1, #entities do
         entities[i]:remove("Velocity")
      end
   end,
   before = create_world(),
   after = clear_engine,
}

--- @type luamark.Spec
local nobatch_add = {
   fn = function(ctx, _p)
      local entities = ctx.entities
      for i = 1, #entities do
         entities[i]:add(Name("monster"))
      end
   end,
   before = create_world(),
   after = clear_engine,
}

-- NOTE: addMultiple internally loops individual add() calls, firing a
-- ComponentAdded event per component. No true batching benefit.
--- @type luamark.Spec
local batch_add = {
   fn = function(ctx, _p)
      local entities = ctx.entities
      for i = 1, #entities do
         entities[i]:addMultiple({ Name("monster") })
      end
   end,
   before = create_world(),
   after = clear_engine,
}

-- ----------------------------------------------------------------------------
-- Tag Tests
-- ----------------------------------------------------------------------------

--- @type luamark.Spec
local has = {
   fn = function(ctx, _p)
      local entities = ctx.entities
      for i = 1, #entities do
         local _ = entities[i].components["Alive"] ~= nil
      end
   end,
   before = create_world(),
   after = clear_engine,
}

--- @type luamark.Spec
local nobatch_tag_add = {
   fn = function(ctx, _p)
      local entities = ctx.entities
      for i = 1, #entities do
         entities[i]:add(Aggro())
      end
   end,
   before = create_world(),
   after = clear_engine,
}

--- @type luamark.Spec
local batch_tag_add = {
   fn = function(ctx, _p)
      local entities = ctx.entities
      for i = 1, #entities do
         entities[i]:addMultiple({ Aggro() })
      end
   end,
   before = create_world(),
   after = clear_engine,
}

--- @type luamark.Spec
local tag_remove = {
   fn = function(ctx, _p)
      local entities = ctx.entities
      for i = 1, #entities do
         entities[i]:remove("Alive")
      end
   end,
   before = create_world(),
   after = clear_engine,
}

-- ----------------------------------------------------------------------------
-- System Tests
-- ----------------------------------------------------------------------------

--- @type luamark.Spec
local throughput = {
   fn = function(ctx, _p)
      ctx.engine:update(DT)
   end,
   before = function(_ctx, p)
      local engine = lt_Engine()

      for _ = 1, p.n_entities do
         local e = lt_Entity()
         e:initialize()
         e:add(Position(0, 0))
         e:add(Velocity(0, 0))
         engine:addEntity(e)
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
      engine:update(DT)
      return { engine = engine }
   end,
   after = clear_engine,
}

--- @type luamark.Spec
local overlap = {
   fn = function(ctx, _p)
      ctx.engine:update(DT)
   end,
   before = function(_ctx, p)
      local engine = lt_Engine()

      for i = 1, p.n_entities do
         local archetype = i % 4
         local e = lt_Entity()
         e:initialize()
         e:add(A(0))
         e:add(B(0))
         if archetype >= 1 then
            e:add(C(0))
         end
         if archetype >= 2 then
            e:add(D(0))
         end
         if archetype == 3 then
            e:remove("D")
            e:add(E(0))
         end
         engine:addEntity(e)
      end

      local SwapAB = lt_class("SwapAB", lt_System)
      function SwapAB:requires()
         return { "A", "B" }
      end
      function SwapAB:update(_dt)
         for _, e in pairs(self.targets) do
            local a_comp = e:get("A")
            local b_comp = e:get("B")
            a_comp.v, b_comp.v = b_comp.v, a_comp.v
         end
      end

      local SwapCD = lt_class("SwapCD", lt_System)
      function SwapCD:requires()
         return { "C", "D" }
      end
      function SwapCD:update(_dt)
         for _, e in pairs(self.targets) do
            local c_comp = e:get("C")
            local d_comp = e:get("D")
            c_comp.v, d_comp.v = d_comp.v, c_comp.v
         end
      end

      local SwapCE = lt_class("SwapCE", lt_System)
      function SwapCE:requires()
         return { "C", "E" }
      end
      function SwapCE:update(_dt)
         for _, e in pairs(self.targets) do
            local c_comp = e:get("C")
            local e_comp = e:get("E")
            c_comp.v, e_comp.v = e_comp.v, c_comp.v
         end
      end

      engine:addSystem(SwapAB())
      engine:addSystem(SwapCD())
      engine:addSystem(SwapCE())
      engine:update(DT)

      return { engine = engine }
   end,
   after = clear_engine,
}

--- @type luamark.Spec
local fragmented = {
   fn = function(ctx, _p)
      ctx.engine:update(DT)
   end,
   before = function(_ctx, p)
      local engine = lt_Engine()

      for i = 1, p.n_entities do
         local buff_index = ((i - 1) % #BUFFS) + 1
         local e = lt_Entity()
         e:initialize()
         e:add(Position(0, 0))
         e:add(BUFFS[buff_index](buff_index))
         engine:addEntity(e)
      end

      local sum = 0

      local PositionSystem = lt_class("PositionSystem", lt_System)
      function PositionSystem:requires()
         return { "Position" }
      end
      function PositionSystem:update(_dt)
         for _, e in pairs(self.targets) do
            local pos = e:get("Position")
            sum = sum + pos.x + pos.y
         end
      end

      local Buff1System = lt_class("Buff1System", lt_System)
      function Buff1System:requires()
         return { "Buff1" }
      end
      function Buff1System:update(_dt)
         for _, e in pairs(self.targets) do
            sum = sum + e:get("Buff1").level
         end
      end

      engine:addSystem(PositionSystem())
      engine:addSystem(Buff1System())
      engine:update(DT)
      return { engine = engine }
   end,
   after = clear_engine,
}

--- @type luamark.Spec
local chained = {
   fn = function(ctx, _p)
      ctx.engine:update(DT)
   end,
   before = function(_ctx, p)
      local engine = lt_Engine()

      for _ = 1, p.n_entities do
         local e = lt_Entity()
         e:initialize()
         e:add(A(1))
         e:add(B(0))
         e:add(C(0))
         e:add(D(0))
         e:add(E(0))
         engine:addEntity(e)
      end

      local SysAB = lt_class("SysAB", lt_System)
      function SysAB:requires()
         return { "A", "B" }
      end
      function SysAB:update(_dt)
         for _, e in pairs(self.targets) do
            e:get("B").v = e:get("A").v
         end
      end

      local SysBC = lt_class("SysBC", lt_System)
      function SysBC:requires()
         return { "B", "C" }
      end
      function SysBC:update(_dt)
         for _, e in pairs(self.targets) do
            e:get("C").v = e:get("B").v
         end
      end

      local SysCD = lt_class("SysCD", lt_System)
      function SysCD:requires()
         return { "C", "D" }
      end
      function SysCD:update(_dt)
         for _, e in pairs(self.targets) do
            e:get("D").v = e:get("C").v
         end
      end

      local SysDE = lt_class("SysDE", lt_System)
      function SysDE:requires()
         return { "D", "E" }
      end
      function SysDE:update(_dt)
         for _, e in pairs(self.targets) do
            e:get("E").v = e:get("D").v
         end
      end

      engine:addSystem(SysAB())
      engine:addSystem(SysBC())
      engine:addSystem(SysCD())
      engine:addSystem(SysDE())
      engine:update(DT)

      return { engine = engine }
   end,
   after = clear_engine,
}

--- @type luamark.Spec
local multi_20 = {
   fn = function(ctx, _p)
      ctx.engine:update(DT)
   end,
   before = function(_ctx, p)
      local engine = lt_Engine()

      for _ = 1, p.n_entities do
         local e = lt_Entity()
         e:initialize()
         e:add(Comp1(0))
         e:add(Comp2(0))
         e:add(Comp3(0))
         e:add(Comp4(0))
         e:add(Comp5(0))
         e:add(Comp6(0))
         e:add(Comp7(0))
         e:add(Comp8(0))
         e:add(Comp9(0))
         e:add(Comp10(0))
         engine:addEntity(e)
      end

      local comp_names = {
         "Comp1",
         "Comp2",
         "Comp3",
         "Comp4",
         "Comp5",
         "Comp6",
         "Comp7",
         "Comp8",
         "Comp9",
         "Comp10",
      }

      local sum = 0

      for i, comp_name in ipairs(comp_names) do
         local Sys1 = lt_class("Sys" .. i .. "a", lt_System)
         Sys1.comp_name = comp_name
         function Sys1:requires()
            return { self.class.comp_name }
         end
         function Sys1:update(_dt)
            local cname = self.class.comp_name
            for _, e in pairs(self.targets) do
               sum = sum + e:get(cname).value
            end
         end
         engine:addSystem(Sys1())

         local Sys2 = lt_class("Sys" .. i .. "b", lt_System)
         Sys2.comp_name = comp_name
         function Sys2:requires()
            return { self.class.comp_name }
         end
         function Sys2:update(_dt)
            local cname = self.class.comp_name
            for _, e in pairs(self.targets) do
               sum = sum + e:get(cname).value
            end
         end
         engine:addSystem(Sys2())
      end

      engine:update(DT)
      return { engine = engine }
   end,
   after = clear_engine,
}

--- @type luamark.Spec
local empty_systems = {
   fn = function(ctx, _p)
      ctx.engine:update(DT)
   end,
   before = function(_ctx, p)
      local engine = lt_Engine()

      for _ = 1, p.n_entities do
         local e = lt_Entity()
         e:initialize()
         e:add(Position(0, 0))
         engine:addEntity(e)
      end

      for i = 1, 20 do
         local EmptySys = lt_class("EmptySys" .. i, lt_System)
         function EmptySys:requires()
            return { "NonExistent" }
         end
         function EmptySys:update(dt)
            for _, e in pairs(self.targets) do
               e:get("NonExistent").value = e:get("NonExistent").value + dt
            end
         end
         engine:addSystem(EmptySys())
      end

      engine:update(DT)
      return { engine = engine }
   end,
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
      },
      ["lovetoys-nobatch"] = {
         component = {
            add = nobatch_add,
         },
         tag = {
            add = nobatch_tag_add,
         },
      },
      ["lovetoys-batch"] = {
         component = {
            add = batch_add,
         },
         tag = {
            add = batch_tag_add,
         },
      },
   },
}
