--luacheck: ignore
---@diagnostic disable: unused-local
local Benchmark = require("src.Benchmark")
local class = require("pl.class")

local function fix_haxe_lua(path, variables)
   local file = assert(io.open(path, "r"))
   local content = file:read("*a")
   file:close()

   -- Modify the content: remove 'local' keyword from each specified variable
   for _, var in ipairs(variables) do
      content = content:gsub("local%s+" .. var, var)
   end

   local fixed_file = assert(io.open(path, "w"))
   fixed_file:write(content)
   fixed_file:close()
end

local haxe_path = "src/haxe/transpiled.lua"
fix_haxe_lua(haxe_path, {
   "HaxeBenchmark",
   "AddEmptyEntity",
   "AddEntities",
   "RemoveEntities",
   "GetComponent",
   "GetComponents",
   "AddComponent",
   "AddComponents",
   "RemoveComponent",
   "RemoveComponents",
   "SystemUpdate",
})
dofile(haxe_path)

local EchoesBenchmark = class(Benchmark)

function EchoesBenchmark:iteration_teardown()
   self.benchmark.iteration_teardown()
end

function EchoesBenchmark:run()
   self.benchmark:run()
end

local add_empty_entity = class(EchoesBenchmark)

function add_empty_entity:iteration_setup()
   self.benchmark = AddEmptyEntity.new(self.n_entities)
end

local add_entities = class.add_entities(EchoesBenchmark)

function add_entities:iteration_setup()
   self.benchmark = AddEntities.new(self.n_entities)
end

local remove_entities = class(EchoesBenchmark)

function remove_entities:iteration_setup()
   self.benchmark = RemoveEntities.new(self.n_entities)
end

local get_component = class(EchoesBenchmark)

function get_component:iteration_setup()
   self.benchmark = GetComponent.new(self.n_entities)
end

local get_components = class(EchoesBenchmark)
function get_components:iteration_setup()
   self.benchmark = GetComponents.new(self.n_entities)
end

local add_component = class(EchoesBenchmark)

function add_component:iteration_setup()
   self.benchmark = AddComponent.new(self.n_entities, true)
end

local add_components = class(EchoesBenchmark)

function add_components:iteration_setup()
   self.benchmark = AddComponents.new(self.n_entities, true)
end

local remove_component = class(EchoesBenchmark)

function remove_component:iteration_setup()
   self.benchmark = RemoveComponent.new(self.n_entities)
end

local remove_components = class(EchoesBenchmark)

function remove_components:iteration_setup()
   self.benchmark = RemoveComponents.new(self.n_entities)
end

local system_update = class(Benchmark)

function system_update:global_setup()
   self.benchmark = SystemUpdate.new(self.n_entities)
end

function system_update:global_teardown()
   self.benchmark.iteration_teardown()
end

function system_update:run()
   self.benchmark:run()
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
