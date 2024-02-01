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
   "CreateEmptyEntity",
   "CreateEntities",
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

function EchoesBenchmark:teardown()
   self.benchmark.teardown()
end
function EchoesBenchmark:run()
   self.benchmark:run()
end

local create_empty_entity = class(EchoesBenchmark)

function create_empty_entity:setup()
   self.benchmark = CreateEmptyEntity.new(self.n_entities)
end

local create_entities = class.create_entities(EchoesBenchmark)

function create_entities:setup()
   self.benchmark = CreateEntities.new(self.n_entities)
end

local remove_entities = class(EchoesBenchmark)

function remove_entities:setup()
   self.benchmark = RemoveEntities.new(self.n_entities)
end

local get_component = class(EchoesBenchmark)

function get_component:setup()
   self.benchmark = GetComponent.new(self.n_entities)
end

local get_components = class(EchoesBenchmark)
function get_components:setup()
   self.benchmark = GetComponents.new(self.n_entities)
end

local add_component = class(EchoesBenchmark)

function add_component:setup()
   self.benchmark = AddComponent.new(self.n_entities, true)
end

local add_components = class(EchoesBenchmark)

function add_components:setup()
   self.benchmark = AddComponents.new(self.n_entities, true)
end

local remove_component = class(EchoesBenchmark)

function remove_component:setup()
   self.benchmark = RemoveComponent.new(self.n_entities)
end

local remove_components = class(EchoesBenchmark)

function remove_components:setup()
   self.benchmark = RemoveComponents.new(self.n_entities)
end

local system_update = class(EchoesBenchmark)

function system_update:setup()
   self.benchmark = SystemUpdate.new(self.n_entities)
end

return {
   create_empty_entity = create_empty_entity,
   create_entities = create_entities,
   remove_entities = remove_entities,
   get_component = get_component,
   get_components = get_components,
   add_component = add_component,
   add_components = add_components,
   remove_component = remove_component,
   remove_components = remove_components,
   system_update = system_update,
}
