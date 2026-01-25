---@diagnostic disable: unused-local
local nata = require("lib.nata.nata")
local shuffle = require("src.lib.utils").shuffle

local nata_new = nata.new

-- ----------------------------------------------------------------------------
-- Setup
-- ----------------------------------------------------------------------------

--- Create a new pool.
--- @return { pool: table } Context with pool.
local function create_pool()
   return { pool = nata_new() }
end

--- Create a pool populated with entities (with components).
--- @param _ctx table Unused previous context.
--- @param p { n_entities: number } Benchmark parameters.
--- @return { pool: table, entities: table[] } Context with pool and entities.
local function create_populated_pool(_ctx, p)
   local pool = nata_new()
   local entities = {}
   for i = 1, p.n_entities do
      entities[i] = pool:queue({
         Position = { x = 0.0, y = 0.0 },
         Velocity = { x = 0.0, y = 0.0 },
         Optional = {},
      })
   end
   shuffle(entities)
   pool:flush()
   return { pool = pool, entities = entities }
end

--- Create a pool populated with empty entities.
--- @param _ctx table Unused previous context.
--- @param p { n_entities: number } Benchmark parameters.
--- @return { pool: table, entities: table[] } Context with pool and entities.
local function create_empty_entities(_ctx, p)
   local pool = nata_new()
   local entities = {}
   for i = 1, p.n_entities do
      entities[i] = pool:queue({})
   end
   shuffle(entities)
   pool:flush()
   return { pool = pool, entities = entities }
end

--- Clear the pool.
--- @param ctx { pool: table } Context with pool.
local function clear_pool(ctx)
   ctx.pool = nil
end

-- ----------------------------------------------------------------------------
-- Tests
-- ----------------------------------------------------------------------------

--- @type BenchmarkModule
return {
   add_empty_entity = {
      max_entities = 1000,
      fn = function(ctx, p)
         local pool = ctx.pool
         for _ = 1, p.n_entities do
            pool:queue({})
         end
         pool:flush()
      end,
      before = create_pool,
      after = clear_pool,
   },

   add_entities = {
      max_entities = 1000,
      fn = function(ctx, p)
         local pool = ctx.pool
         for _ = 1, p.n_entities do
            pool:queue({
               Position = { x = 0.0, y = 0.0 },
               Velocity = { x = 0.0, y = 0.0 },
            })
         end
         pool:flush()
      end,
      before = create_pool,
      after = clear_pool,
   },

   get_component = {
      max_entities = 1000,
      fn = function(ctx, _p)
         local entities = ctx.entities
         for i = 1, #entities do
            local _ = entities[i].Position
         end
      end,
      before = create_populated_pool,
      after = clear_pool,
   },

   get_components = {
      max_entities = 1000,
      fn = function(ctx, _p)
         local entities = ctx.entities
         for i = 1, #entities do
            local entity = entities[i]
            local _ = entity.Position
            _ = entity.Velocity
            _ = entity.Optional
         end
      end,
      before = create_populated_pool,
      after = clear_pool,
   },

   add_component = {
      max_entities = 1000,
      fn = function(ctx, _p)
         local pool, entities = ctx.pool, ctx.entities
         for i = 1, #entities do
            local entity = entities[i]
            entity.Position = { x = 0.0, y = 0.0 }
            pool:queue(entity)
         end
         pool:flush()
      end,
      before = create_empty_entities,
      after = clear_pool,
   },

   add_components = {
      max_entities = 1000,
      fn = function(ctx, _p)
         local pool, entities = ctx.pool, ctx.entities
         for i = 1, #entities do
            local entity = entities[i]
            entity.Position = { x = 0.0, y = 0.0 }
            entity.Velocity = { x = 0.0, y = 0.0 }
            entity.Optional = {}
            pool:queue(entity)
         end
         pool:flush()
      end,
      before = create_empty_entities,
      after = clear_pool,
   },

   remove_component = {
      max_entities = 1000,
      fn = function(ctx, _p)
         local pool, entities = ctx.pool, ctx.entities
         for i = 1, #entities do
            local entity = entities[i]
            entity.Position = nil
            pool:queue(entity)
         end
         pool:flush()
      end,
      before = create_populated_pool,
      after = clear_pool,
   },

   remove_components = {
      max_entities = 1000,
      fn = function(ctx, _p)
         local pool, entities = ctx.pool, ctx.entities
         for i = 1, #entities do
            local entity = entities[i]
            entity.Position = nil
            entity.Velocity = nil
            entity.Optional = nil
            pool:queue(entity)
         end
         pool:flush()
      end,
      before = create_populated_pool,
      after = clear_pool,
   },

   remove_entities = {
      max_entities = 1000,
      fn = function(ctx, _p)
         local pool, entities = ctx.pool, ctx.entities
         local entity_set = {}
         for i = 1, #entities do
            entity_set[entities[i]] = true
         end
         pool:remove(function(e)
            return entity_set[e]
         end)
      end,
      before = create_populated_pool,
      after = clear_pool,
   },

   system_update = {
      max_entities = 1000,
      fn = function(ctx, _p)
         ctx.pool:emit("update", 1 / 60)
      end,
      before = function(_ctx, p)
         local MovementSystem = {}

         function MovementSystem:update(dt)
            for _, e in pairs(self.pool.groups.move.entities) do
               local position, velocity = e.Position, e.Velocity
               position.x = position.x + velocity.x * dt
               position.y = position.y + velocity.y * dt
            end
         end

         local pool = nata_new({
            groups = { move = { filter = { "Position", "Velocity" } } },
            systems = { MovementSystem },
         })

         for i = 1, p.n_entities do
            local entity = pool:queue({
               Position = { x = 0.0, y = 0.0 },
               Velocity = { x = 0.0, y = 0.0 },
            })

            local padding = i % 4
            if padding == 1 then
               entity.Padding1 = {}
            elseif padding == 2 then
               entity.Padding2 = {}
            elseif padding == 3 then
               entity.Padding3 = {}
            end

            local should_shuffle = (i + 1) % 4
            if should_shuffle == 0 then
               entity.Position = nil
            elseif should_shuffle == 1 then
               entity.Velocity = nil
            end
         end
         pool:flush()
         return { pool = pool }
      end,
      after = clear_pool,
   },
}
