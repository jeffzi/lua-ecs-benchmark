local math_random = math.random

local utils = {}

-- Lua 5.1/5.2+ compatibility (unpack is global in 5.1, table.unpack in 5.2+)
---@diagnostic disable-next-line: deprecated
utils.unpack = rawget(_G, "unpack") or table.unpack -- luacheck: ignore 143

local PATH_SEP = package.config:sub(1, 1)

--- Shuffle array elements in place using Fisher-Yates algorithm.
--- @param arr any[] Array to shuffle.
--- @return any[] The shuffled array.
function utils.shuffle(arr)
   local n = #arr
   for i = n, 2, -1 do
      local j = math_random(i)
      arr[i], arr[j] = arr[j], arr[i]
   end
   return arr
end

--- Print formatted string.
--- @param fmt string Format string.
--- @param ... any Format arguments.
function utils.printf(fmt, ...)
   print(string.format(fmt, ...))
end

--- Get keys of a table as an array.
--- @param t table Table to get keys from.
--- @return any[] Array of keys.
function utils.keys(t)
   local result = {}
   for k in pairs(t) do
      result[#result + 1] = k
   end
   return result
end

--- Concatenate two arrays into a new array.
--- @param a any[] First array.
--- @param b any[] Second array.
--- @return any[] New array containing elements from both.
function utils.concat(a, b)
   local result = {}
   for i = 1, #a do
      result[#result + 1] = a[i]
   end
   for i = 1, #b do
      result[#result + 1] = b[i]
   end
   return result
end

--- Write rows to a CSV file.
--- @param rows (string|number)[][] Array of rows.
--- @param filepath string Output file path.
--- @param headers string[] Column headers.
--- @param sep string Field separator.
function utils.write_csv(rows, filepath, headers, sep)
   local file = assert(io.open(filepath, "w"))
   file:write(table.concat(headers, sep) .. "\n")
   for i = 1, #rows do
      file:write(table.concat(rows[i], sep) .. "\n")
   end
   file:close()
end

--- Ensure parent directory exists for a filepath.
--- @param filepath string File path.
--- @return string The input filepath.
function utils.mkdir(filepath)
   local pattern = "(.+)" .. PATH_SEP .. "[^" .. PATH_SEP .. "]+$"
   local dir = filepath:match(pattern)
   if dir then
      local cmd = PATH_SEP == "\\" and ('mkdir "%s" 2>nul'):format(dir)
         or ('mkdir -p "%s"'):format(dir)
      os.execute(cmd)
   end
   return filepath
end

--- Expand names, resolving aliases to their variants.
--- @param names string[] Names (may include aliases).
--- @param aliases table<string, string[]> Alias name -> variant names mapping.
--- @return string[] Expanded list with aliases replaced by variants.
function utils.expand_names(names, aliases)
   local expanded = {}
   local seen = {}
   for _, name in ipairs(names) do
      local to_add = aliases[name] or { name }
      for _, n in ipairs(to_add) do
         if not seen[n] then
            seen[n] = true
            expanded[#expanded + 1] = n
         end
      end
   end
   return expanded
end

return utils
