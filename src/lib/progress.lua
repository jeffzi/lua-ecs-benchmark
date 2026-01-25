--- Minimal progress bar library (indicatif-inspired).
--- Single-line progress bars with template-based formatting.
---
--- @example
--- local Progress = require("src.lib.progress")
--- local bar = Progress({ total = 100 })
--- bar:start()
--- for i = 1, 100 do
---     bar:update(i)
--- end
--- bar:stop("Done!")

local clear = require("terminal.clear")
local cursor = require("terminal.cursor")
local terminal = require("terminal")

local math_floor = math.floor
local string_format = string.format
local string_rep = string.rep

--- Format a duration in seconds to human-readable string.
--- @param seconds number Duration in seconds.
--- @return string Formatted string (e.g., "1.5h", "2.3m", "45s").
local function _format_duration(seconds)
   if seconds >= 3600 then
      return string_format("%.1fh", seconds / 3600)
   end
   if seconds >= 60 then
      return string_format("%.1fm", seconds / 60)
   end
   return string_format("%.0fs", seconds)
end

--- Format a progress bar string.
--- @param pct number Percentage (0-1).
--- @param width number Total bar width in characters.
--- @return string Formatted bar (e.g., "[████░░░░░░]").
local function _format_bar(pct, width)
   local inner_width = width - 2 -- account for brackets
   local filled = math_floor(pct * inner_width)
   local empty = inner_width - filled
   return string_format(
      "[%s%s]",
      string_rep("█", filled),
      string_rep("░", empty)
   )
end

--- ProgressBar class.
--- @class ProgressBar
--- @field total number Total number of items.
--- @field pos number Current position.
--- @field template string Template string with placeholders.
--- @field width number Bar width in characters.
--- @field disable boolean Whether output is disabled.
--- @field msg string|nil Custom message for {msg} placeholder.
--- @field start_time number|nil Start time (os.clock()).
local ProgressBar = {}
ProgressBar.__index = ProgressBar

--- Create a new progress bar.
--- @param opts table Options: total (required), template, width, disable.
--- @return ProgressBar
local function new(opts)
   assert(opts.total, "progress.new: 'total' is required")
   local len_width = #tostring(opts.total)
   return setmetatable({
      total = opts.total,
      pos = 0,
      template = opts.template or "{bar} {pos}/{len} [{elapsed}<{eta}]",
      width = opts.width or 40,
      disable = opts.disable or false,
      _len_width = len_width,
   }, ProgressBar)
end

--- Compute ETA string based on progress.
--- @param elapsed number Elapsed time in seconds.
--- @param pos number Current position.
--- @param total number Total items.
--- @return string ETA string.
local function _compute_eta(elapsed, pos, total)
   if pos >= total then
      return "0s"
   end
   if pos == 0 then
      return "?"
   end
   return _format_duration((elapsed / pos) * (total - pos))
end

--- Format the progress bar using the template.
--- @param template? string Optional template override.
--- @return string Formatted string.
function ProgressBar:_format(template)
   local elapsed = self.start_time and (os.clock() - self.start_time) or 0
   local pct = self.total > 0 and (self.pos / self.total) or 0

   local w = self._len_width
   local vars = {
      bar = _format_bar(pct, self.width),
      pos = string_format("%" .. w .. "d", self.pos),
      len = string_format("%" .. w .. "d", self.total),
      pct = string_format("%3d%%", math_floor(pct * 100)),
      elapsed = _format_duration(elapsed),
      eta = _compute_eta(elapsed, self.pos, self.total),
      msg = self.msg or "",
   }
   return ((template or self.template):gsub("{(%w+)}", vars))
end

--- Clear the current line and move cursor to start.
local function _clear_line()
   io.write("\r")
   clear.line()
end

--- Render the progress bar to the terminal.
function ProgressBar:_render()
   if self.disable then return end
   _clear_line()
   io.write(self:_format())
   io.flush()
end

--- Initialize the terminal and start tracking time.
function ProgressBar:start()
   if self.disable then return end
   self.start_time = os.clock()
   local ok = pcall(function()
      terminal.initialize()
      cursor.visible.set(false)
   end)
   if not ok then
      self.disable = true
   end
end

--- Update the progress bar position.
--- @param pos number New position.
--- @param msg? string Optional message for {msg} placeholder.
function ProgressBar:update(pos, msg)
   if self.disable then return end
   self.pos = pos
   self.msg = msg
   self:_render()
end

--- Stop the progress bar and restore the terminal.
--- @param final_msg? string Optional final message (supports template vars).
function ProgressBar:stop(final_msg)
   if self.disable then return end
   _clear_line()
   if final_msg then
      io.write(self:_format(final_msg))
   end
   io.write("\n")
   io.flush()
   pcall(function()
      cursor.visible.set(true)
      terminal.shutdown()
   end)
end

return new
