--- Print markdown table of submodule versions for README.md

--- Execute shell command and return trimmed output.
--- @param cmd string Shell command to execute.
--- @return string|nil result Command output or nil on failure.
local function run(cmd)
   local handle = io.popen(cmd)
   if not handle then
      return nil
   end
   local result = handle:read("*a"):gsub("%s+$", "")
   handle:close()
   return result
end

--- Get sorted list of submodule paths from .gitmodules.
--- @return string[] paths Array of submodule paths.
local function get_submodule_paths()
   local output = run("git config --file .gitmodules --get-regexp path")
   if not output or output == "" then
      return {}
   end

   local paths = {}
   for path in output:gmatch("submodule%.[^%s]+%.path%s+([^\n]+)") do
      table.insert(paths, path)
   end
   table.sort(paths)
   return paths
end

local force_table = arg[1] == "--table" or arg[1] == "-t"
local staged = run("git diff --cached --name-only") or ""
local paths = get_submodule_paths()

local updated_count = 0
for _, path in ipairs(paths) do
   local name = path:match("[^/]+$")
   -- Submodule appears in staged changes if it was updated by `git submodule update --remote`
   local is_updated = staged:find(path, 1, true) ~= nil
   if is_updated then
      updated_count = updated_count + 1
   end
   print(string.format("%s: %s", name, is_updated and "Updated" or "Up to date"))
end

if updated_count == 0 then
   print("→ All submodules already at latest.")
else
   print(string.format("→ %d submodule(s) updated.", updated_count))
end

if updated_count == 0 and not force_table then
   return
end

print("\nUpdate README.md with:\n")
print("| Library | Commit |")
print("|---------|--------|")

for _, path in ipairs(paths) do
   local name = path:match("[^/]+$")
   local sha = run("git -C " .. path .. " rev-parse HEAD")
   local url = run("git config --file .gitmodules --get submodule." .. path .. ".url")
   if sha and url then
      url = url:gsub("%.git$", "")
      print(string.format("| [%s](%s) | [`%s`](%s/tree/%s) |", name, url, sha:sub(1, 7), url, sha))
   end
end
