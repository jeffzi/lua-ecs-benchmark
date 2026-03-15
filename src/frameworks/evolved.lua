---@diagnostic disable: unused-local
local config = require("src.lib.config")
local evo = require("evolved")
local utils = require("src.lib.utils")
local shuffle = utils.shuffle
local tbl_unpack = utils.unpack

local evo_id = evo.id
local evo_spawn = evo.spawn
local evo_destroy = evo.destroy
local evo_get = evo.get
local evo_set = evo.set
local evo_has = evo.has
local evo_remove = evo.remove
local evo_builder = evo.builder
local evo_process_with = evo.process_with
local evo_multi_spawn = evo.multi_spawn
local evo_batch_set = evo.batch_set
local evo_batch_remove = evo.batch_remove
local evo_batch_destroy = evo.batch_destroy

local DT = config.DT
local WORLD_MULTIPLIER = config.WORLD_MULTIPLIER
local N_BUFFS = config.N_BUFFS
local N_SYSTEMS = config.N_SYSTEMS

-- ----------------------------------------------------------------------------
-- Fragment Definitions (component types, created once at module load)
-- ----------------------------------------------------------------------------

-- SoA decomposition: table components split into scalar fragments
local Position_x = evo_id()
local Position_y = evo_id()
local Velocity_x = evo_id()
local Velocity_y = evo_id()
local Health_current = evo_id()
local Health_max = evo_id()
local Name_value = evo_id()

-- Native TAGs: no component data, cheaper migration
local Alive = evo_builder():tag():build()
local Aggro = evo_builder():tag():build()

-- Generic fragments for system tests
local fA = evo_id()
local fB = evo_id()
local fC = evo_id()
local fD = evo_id()
local fE = evo_id()

-- Numbered fragments for multi_20 test
local Comp = {}
for i = 1, 10 do
   Comp[i] = evo_id()
end

-- Buff fragments for fragmented test (storing buff level value)
local BUFFS = {}
for i = 1, N_BUFFS do
   BUFFS[i] = evo_id()
end

-- Sentinel fragment (never assigned to any entity)
local NonExistent = evo_id()

-- ----------------------------------------------------------------------------
-- Setup
-- ----------------------------------------------------------------------------

--- Factory: returns a `before` function that creates a populated world.
--- (WORLD_MULTIPLIER - 1) * N background + N tracked entities.
--- @param make_entity? fun(): table Factory for tracked entities.
--- @return fun(_ctx: table, p: { n_entities: number }): table
local function create_world(make_entity)
   make_entity = make_entity
      or function()
         return {
            [Position_x] = 0.0,
            [Position_y] = 0.0,
            [Velocity_x] = 0.0,
            [Velocity_y] = 0.0,
            [Alive] = true,
         }
      end
   return function(_ctx, p)
      local background = {}
      for i = 1, p.n_entities * (WORLD_MULTIPLIER - 1) do
         background[i] = evo_spawn({
            [Health_current] = 100,
            [Health_max] = 100,
            [Name_value] = "monster",
            [Aggro] = true,
         })
      end

      local entities = {}
      for i = 1, p.n_entities do
         entities[i] = evo_spawn(make_entity())
      end

      shuffle(entities)
      return { entities = entities, background = background }
   end
end

--- Factory: wraps create_world to also build a query matching tracked entities.
--- @param query_frags table Fragments to include in the query.
--- @param make_entity? fun(): table Factory for tracked entities.
--- @return fun(_ctx: table, p: { n_entities: number }): table
local function create_world_with_query(query_frags, make_entity)
   local base_before = create_world(make_entity)
   return function(ctx, p)
      local result = base_before(ctx, p)
      result.query = evo_builder():include(tbl_unpack(query_frags)):build()
      return result
   end
end

--- Destroy all tracked entities.
--- @param ctx table Context with entities, background, created, and systems lists.
local function clear_world(ctx)
   local lists = { ctx.entities, ctx.background, ctx.created, ctx.systems }
   for _, list in ipairs(lists) do
      if list then
         for i = 1, #list do
            evo_destroy(list[i])
         end
      end
   end
   if ctx.query then
      evo_destroy(ctx.query)
   end
   if ctx.stage then
      evo_destroy(ctx.stage)
   end
   ctx.entities = nil
   ctx.background = nil
   ctx.created = nil
   ctx.systems = nil
   ctx.query = nil
   ctx.stage = nil
end

-- ----------------------------------------------------------------------------
-- Shared Tests (identical across API styles)
-- ----------------------------------------------------------------------------

-- NOTE: evolved treats empty entities as bare IDs with no world presence until
-- components are attached. evo_id() is the idiomatic pattern, but it measures
-- only ID allocation (counter increment), not world registration. Other
-- frameworks register the entity in internal structures. evo_spawn({}) also
-- short-circuits to ID allocation, so the difference is architectural.
--- @type luamark.Spec
local create_empty = {
   fn = function(ctx, p)
      local created = {}
      for i = 1, p.n_entities do
         created[i] = evo_id()
      end
      ctx.created = created
   end,
   before = create_world(),
   after = clear_world,
}

--- @type luamark.Spec
local get = {
   fn = function(ctx)
      local entities = ctx.entities
      for i = 1, #entities do
         local _, _ = evo_get(entities[i], Position_x, Position_y)
      end
   end,
   before = create_world(),
   after = clear_world,
}

--- @type luamark.Spec
local set = {
   fn = function(ctx)
      local entities = ctx.entities
      for i = 1, #entities do
         evo_set(entities[i], Position_x, 1.0)
         evo_set(entities[i], Position_y, 1.0)
      end
   end,
   before = create_world(),
   after = clear_world,
}

-- ----------------------------------------------------------------------------
-- Nobatch Tests (per-entity immediate operations)
-- ----------------------------------------------------------------------------

--- @type luamark.Spec
local nobatch_create_with_components = {
   fn = function(ctx, p)
      local created = {}
      local b = evo_builder()
      b:set(Position_x, 0)
      b:set(Position_y, 0)
      b:set(Alive, true)
      for i = 1, p.n_entities do
         created[i] = b:build()
      end
      ctx.created = created
   end,
   before = create_world(),
   after = clear_world,
}

--- @type luamark.Spec
local nobatch_destroy = {
   fn = function(ctx)
      local entities = ctx.entities
      for i = 1, #entities do
         evo_destroy(entities[i])
      end
   end,
   before = create_world(),
   after = clear_world,
}

--- @type luamark.Spec
local nobatch_add = {
   fn = function(ctx)
      local entities = ctx.entities
      for i = 1, #entities do
         evo_set(entities[i], Name_value, "monster")
      end
   end,
   before = create_world(),
   after = clear_world,
}

--- @type luamark.Spec
local nobatch_remove = {
   fn = function(ctx)
      local entities = ctx.entities
      for i = 1, #entities do
         evo_remove(entities[i], Velocity_x, Velocity_y)
      end
   end,
   before = create_world(),
   after = clear_world,
}

-- ----------------------------------------------------------------------------
-- Batch Tests (query-level bulk operations)
-- ----------------------------------------------------------------------------

--- @type luamark.Spec
local batch_create_with_components = {
   fn = function(ctx, p)
      local entity_list = evo_multi_spawn(p.n_entities, {
         [Position_x] = 0,
         [Position_y] = 0,
         [Alive] = true,
      })
      ctx.created = entity_list
   end,
   before = create_world(),
   after = clear_world,
}

--- @type luamark.Spec
local batch_destroy = {
   fn = function(ctx)
      evo_batch_destroy(ctx.query)
   end,
   before = create_world_with_query({ Position_x }),
   after = clear_world,
}

--- @type luamark.Spec
local batch_add = {
   fn = function(ctx)
      evo_batch_set(ctx.query, Name_value, "monster")
   end,
   before = create_world_with_query({ Position_x }),
   after = clear_world,
}

--- @type luamark.Spec
local batch_remove = {
   fn = function(ctx)
      evo_batch_remove(ctx.query, Velocity_x, Velocity_y)
   end,
   before = create_world_with_query({ Position_x }),
   after = clear_world,
}

-- ----------------------------------------------------------------------------
-- Tag Tests
-- ----------------------------------------------------------------------------

--- @type luamark.Spec
local has = {
   fn = function(ctx)
      local entities = ctx.entities
      for i = 1, #entities do
         local _ = evo_has(entities[i], Alive)
      end
   end,
   before = create_world(),
   after = clear_world,
}

--- @type luamark.Spec
local nobatch_tag_add = {
   fn = function(ctx)
      local entities = ctx.entities
      for i = 1, #entities do
         evo_set(entities[i], Aggro)
      end
   end,
   before = create_world(),
   after = clear_world,
}

--- @type luamark.Spec
local nobatch_tag_remove = {
   fn = function(ctx)
      local entities = ctx.entities
      for i = 1, #entities do
         evo_remove(entities[i], Alive)
      end
   end,
   before = create_world(),
   after = clear_world,
}

--- @type luamark.Spec
local batch_tag_add = {
   fn = function(ctx)
      evo_batch_set(ctx.query, Aggro)
   end,
   before = create_world_with_query({ Position_x }),
   after = clear_world,
}

--- @type luamark.Spec
local batch_tag_remove = {
   fn = function(ctx)
      evo_batch_remove(ctx.query, Alive)
   end,
   before = create_world_with_query({ Position_x }),
   after = clear_world,
}

-- ----------------------------------------------------------------------------
-- System Tests
-- ----------------------------------------------------------------------------

--- @type BenchmarkTests
local system = {
   throughput = {
      fn = function(ctx, _p)
         evo_process_with(ctx.stage, DT)
      end,
      before = function(_ctx, p)
         local entities = {}
         for i = 1, p.n_entities do
            entities[i] = evo_spawn({
               [Position_x] = 0.0,
               [Position_y] = 0.0,
               [Velocity_x] = 0.0,
               [Velocity_y] = 0.0,
            })
         end

         local stage = evo_id()
         local sys = evo_builder()
            :group(stage)
            :include(Position_x, Position_y, Velocity_x, Velocity_y)
            :execute(function(chunk, _entity_list, entity_count, dt)
               local px, py = chunk:components(Position_x, Position_y)
               local vx, vy = chunk:components(Velocity_x, Velocity_y)
               for i = 1, entity_count do
                  px[i] = px[i] + vx[i] * dt
                  py[i] = py[i] + vy[i] * dt
               end
            end)
            :build()

         evo_process_with(stage, DT)
         return { entities = entities, stage = stage, systems = { sys } }
      end,
      after = clear_world,
   },

   overlap = {
      fn = function(ctx, _p)
         evo_process_with(ctx.stage, DT)
      end,
      before = function(_ctx, p)
         local entities = {}
         for i = 1, p.n_entities do
            local archetype = i % 4
            local comp_table = { [fA] = 0, [fB] = 0 }
            if archetype >= 1 then
               comp_table[fC] = 0
            end
            if archetype >= 2 then
               comp_table[fD] = 0
            end
            if archetype == 3 then
               comp_table[fD] = nil
               comp_table[fE] = 0
            end
            entities[i] = evo_spawn(comp_table)
         end

         local stage = evo_id()

         local sys1 = evo_builder()
            :group(stage)
            :include(fA, fB)
            :execute(function(chunk, _entity_list, entity_count, _dt)
               local a, b = chunk:components(fA, fB)
               for i = 1, entity_count do
                  a[i], b[i] = b[i], a[i]
               end
            end)
            :build()

         local sys2 = evo_builder()
            :group(stage)
            :include(fC, fD)
            :execute(function(chunk, _entity_list, entity_count, _dt)
               local c, d = chunk:components(fC, fD)
               for i = 1, entity_count do
                  c[i], d[i] = d[i], c[i]
               end
            end)
            :build()

         local sys3 = evo_builder()
            :group(stage)
            :include(fC, fE)
            :execute(function(chunk, _entity_list, entity_count, _dt)
               local c, e = chunk:components(fC, fE)
               for i = 1, entity_count do
                  c[i], e[i] = e[i], c[i]
               end
            end)
            :build()

         evo_process_with(stage, DT)
         return { entities = entities, stage = stage, systems = { sys1, sys2, sys3 } }
      end,
      after = clear_world,
   },

   fragmented = {
      fn = function(ctx, _p)
         evo_process_with(ctx.stage, DT)
      end,
      before = function(_ctx, p)
         local entities = {}
         for i = 1, p.n_entities do
            local buff_index = ((i - 1) % #BUFFS) + 1
            entities[i] = evo_spawn({
               [Position_x] = 0.0,
               [Position_y] = 0.0,
               [BUFFS[buff_index]] = buff_index,
            })
         end

         local sum = 0
         local stage = evo_id()

         local sys1 = evo_builder()
            :group(stage)
            :include(Position_x, Position_y)
            :execute(function(chunk, _entity_list, entity_count)
               local px, py = chunk:components(Position_x, Position_y)
               for i = 1, entity_count do
                  sum = sum + px[i] + py[i]
               end
            end)
            :build()

         local sys2 = evo_builder()
            :group(stage)
            :include(BUFFS[1])
            :execute(function(chunk, _entity_list, entity_count)
               local levels = chunk:components(BUFFS[1])
               for i = 1, entity_count do
                  sum = sum + levels[i]
               end
            end)
            :build()

         evo_process_with(stage, DT)
         return { entities = entities, stage = stage, systems = { sys1, sys2 } }
      end,
      after = clear_world,
   },

   chained = {
      fn = function(ctx, _p)
         evo_process_with(ctx.stage, DT)
      end,
      before = function(_ctx, p)
         local entities = {}
         for i = 1, p.n_entities do
            entities[i] = evo_spawn({
               [fA] = 1,
               [fB] = 0,
               [fC] = 0,
               [fD] = 0,
               [fE] = 0,
            })
         end

         local stage = evo_id()

         local sys_ab = evo_builder()
            :group(stage)
            :include(fA, fB)
            :execute(function(chunk, _entity_list, entity_count)
               local a, b = chunk:components(fA, fB)
               for i = 1, entity_count do
                  b[i] = a[i]
               end
            end)
            :build()

         local sys_bc = evo_builder()
            :group(stage)
            :include(fB, fC)
            :execute(function(chunk, _entity_list, entity_count)
               local b, c = chunk:components(fB, fC)
               for i = 1, entity_count do
                  c[i] = b[i]
               end
            end)
            :build()

         local sys_cd = evo_builder()
            :group(stage)
            :include(fC, fD)
            :execute(function(chunk, _entity_list, entity_count)
               local c, d = chunk:components(fC, fD)
               for i = 1, entity_count do
                  d[i] = c[i]
               end
            end)
            :build()

         local sys_de = evo_builder()
            :group(stage)
            :include(fD, fE)
            :execute(function(chunk, _entity_list, entity_count)
               local d, e = chunk:components(fD, fE)
               for i = 1, entity_count do
                  e[i] = d[i]
               end
            end)
            :build()

         evo_process_with(stage, DT)
         return {
            entities = entities,
            stage = stage,
            systems = { sys_ab, sys_bc, sys_cd, sys_de },
         }
      end,
      after = clear_world,
   },

   multi_20 = {
      fn = function(ctx, _p)
         evo_process_with(ctx.stage, DT)
      end,
      before = function(_ctx, p)
         local entities = {}
         for i = 1, p.n_entities do
            entities[i] = evo_spawn({
               [Comp[1]] = 0,
               [Comp[2]] = 0,
               [Comp[3]] = 0,
               [Comp[4]] = 0,
               [Comp[5]] = 0,
               [Comp[6]] = 0,
               [Comp[7]] = 0,
               [Comp[8]] = 0,
               [Comp[9]] = 0,
               [Comp[10]] = 0,
            })
         end

         local sum = 0
         local stage = evo_id()
         local systems = {}

         for c = 1, 10 do
            local frag = Comp[c]
            systems[#systems + 1] = evo_builder()
               :group(stage)
               :include(frag)
               :execute(function(chunk, _entity_list, entity_count)
                  local vals = chunk:components(frag)
                  for i = 1, entity_count do
                     sum = sum + vals[i]
                  end
               end)
               :build()

            systems[#systems + 1] = evo_builder()
               :group(stage)
               :include(frag)
               :execute(function(chunk, _entity_list, entity_count)
                  local vals = chunk:components(frag)
                  for i = 1, entity_count do
                     sum = sum + vals[i]
                  end
               end)
               :build()
         end

         evo_process_with(stage, DT)
         return { entities = entities, stage = stage, systems = systems }
      end,
      after = clear_world,
   },

   empty_systems = {
      fn = function(ctx, _p)
         evo_process_with(ctx.stage, DT)
      end,
      before = function(_ctx, p)
         local entities = {}
         for i = 1, p.n_entities do
            entities[i] = evo_spawn({ [Position_x] = 0.0, [Position_y] = 0.0 })
         end

         local stage = evo_id()
         local systems = {}

         for _ = 1, 20 do
            systems[#systems + 1] = evo_builder()
               :group(stage)
               :include(NonExistent)
               :execute(function(chunk, _entity_list, entity_count, dt)
                  local vals = chunk:components(NonExistent)
                  for i = 1, entity_count do
                     vals[i] = vals[i] + dt
                  end
               end)
               :build()
         end

         evo_process_with(stage, DT)
         return { entities = entities, stage = stage, systems = systems }
      end,
      after = clear_world,
   },
}

-- ----------------------------------------------------------------------------
-- Structural Scaling Tests
-- ----------------------------------------------------------------------------

--- Factory: returns a `before` that creates a populated world with N_SYSTEMS background systems.
--- @param make_entity? fun(): table Factory for tracked entities.
--- @return fun(_ctx: table, p: { n_entities: number }): table
local function create_scaling_world(make_entity)
   make_entity = make_entity
      or function()
         return {
            [Position_x] = 0.0,
            [Position_y] = 0.0,
            [Velocity_x] = 0.0,
            [Velocity_y] = 0.0,
            [Alive] = true,
         }
      end
   return function(_ctx, p)
      local stage = evo_id()
      local systems = {}

      for _ = 1, N_SYSTEMS do
         systems[#systems + 1] = evo_builder()
            :group(stage)
            :include(Position_x, Position_y, Velocity_x, Velocity_y)
            :execute(function() end)
            :build()
      end

      local background = {}
      for i = 1, p.n_entities * (WORLD_MULTIPLIER - 1) do
         background[i] = evo_spawn({
            [Health_current] = 100,
            [Health_max] = 100,
            [Name_value] = "monster",
            [Aggro] = true,
         })
      end

      local entities = {}
      for i = 1, p.n_entities do
         entities[i] = evo_spawn(make_entity())
      end

      shuffle(entities)
      return { entities = entities, background = background, stage = stage, systems = systems }
   end
end

--- @type luamark.Spec
local nobatch_scaling_create = {
   fn = function(ctx, p)
      local created = {}
      local b = evo_builder()
      b:set(Position_x, 0)
      b:set(Position_y, 0)
      b:set(Alive, true)
      for i = 1, p.n_entities do
         created[i] = b:build()
      end
      ctx.created = created
   end,
   before = create_scaling_world(),
   after = clear_world,
}

--- @type luamark.Spec
local batch_scaling_create = {
   fn = function(ctx, p)
      local entity_list = evo_multi_spawn(p.n_entities, {
         [Position_x] = 0,
         [Position_y] = 0,
         [Alive] = true,
      })
      ctx.created = entity_list
   end,
   before = create_scaling_world(),
   after = clear_world,
}

--- @type luamark.Spec
local nobatch_scaling_add_component = {
   fn = function(ctx)
      local entities = ctx.entities
      for i = 1, #entities do
         evo_set(entities[i], Name_value, "monster")
      end
   end,
   before = create_scaling_world(),
   after = clear_world,
}

--- @type luamark.Spec
local batch_scaling_add_component = {
   fn = function(ctx)
      evo_batch_set(ctx.query, Name_value, "monster")
   end,
   before = function(ctx, p)
      local base_before = create_scaling_world()
      local result = base_before(ctx, p)
      result.query = evo_builder():include(tbl_unpack({ Position_x })):build()
      return result
   end,
   after = clear_world,
}

--- @type luamark.Spec
local nobatch_scaling_destroy = {
   fn = function(ctx)
      local entities = ctx.entities
      for i = 1, #entities do
         evo_destroy(entities[i])
      end
   end,
   before = create_scaling_world(),
   after = clear_world,
}

--- @type luamark.Spec
local batch_scaling_destroy = {
   fn = function(ctx)
      evo_batch_destroy(ctx.query)
   end,
   before = function(ctx, p)
      local base_before = create_scaling_world()
      local result = base_before(ctx, p)
      result.query = evo_builder():include(tbl_unpack({ Position_x })):build()
      return result
   end,
   after = clear_world,
}

-- ----------------------------------------------------------------------------
-- Module Export
-- ----------------------------------------------------------------------------

--- @type VariantModule
return {
   variants = {
      ["evolved"] = {
         entity = { create_empty = create_empty },
         component = { get = get, set = set },
         tag = { has = has },
         system = system,
      },
      ["evolved-nobatch"] = {
         entity = {
            create_with_components = nobatch_create_with_components,
            destroy = nobatch_destroy,
         },
         component = { add = nobatch_add, remove = nobatch_remove },
         tag = { add = nobatch_tag_add, remove = nobatch_tag_remove },
         structural_scaling = {
            create = nobatch_scaling_create,
            add_component = nobatch_scaling_add_component,
            destroy = nobatch_scaling_destroy,
         },
      },
      ["evolved-batch"] = {
         entity = {
            create_with_components = batch_create_with_components,
            destroy = batch_destroy,
         },
         component = { add = batch_add, remove = batch_remove },
         tag = { add = batch_tag_add, remove = batch_tag_remove },
         structural_scaling = {
            create = batch_scaling_create,
            add_component = batch_scaling_add_component,
            destroy = batch_scaling_destroy,
         },
      },
   },
}
