local components = require("src.components")
local math = require("math")

local M = {}

--- @param e table
function M.update_position(e, dt)
   e.position.x = e.position.x + e.velocity.x * dt
   e.position.y = e.position.y + e.velocity.y * dt
end

--- @param e table
function M.update_direction(e)
   if e.data.float_value % 10 == 0 then
      if e.position.x > e.position.y then
         e.direction.x = math.random(-5, 5)
         e.direction.y = math.random(-10, 10)
      else
         e.direction.x = math.random(-10, 10)
         e.direction.y = math.random(-5, 5)
      end
   end
end

--- @param e table
function M.update_health(e)
   local status = components.COMPONENTS.STATUS
   if e.health.hp <= 0 then
      e.health.hp = 0
      e.health.status = status.dead
   elseif e.health.hp > e.health.maxhp then
      e.health.hp = e.health.maxhp
   elseif e.health.status == status.dead and e.health.hp == 0 then
      e.health.hp = e.health.maxhp
      e.health.status = status.spawn
   else
      e.health.status = status.alive
   end
end

--- @param e table
function M.update_damage(e)
   local total_damage = e.damage.atk - e.damage.def
   if total_damage > 0 then
      e.health.hp = e.health.hp - total_damage
   end
end

--- @param e table
--- @param dt number
function M.update_data(e, dt)
   e.data.int_value = e.data.int_value + 1
   e.data.float_value = e.data.float_value + 0.0001 + dt
   e.data.bool_value = not e.data.bool_value
   local string_value = string.format("%.2f", e.data.float_value)
   e.data.string_value = string_value:sub(1, math.min(string.len(string_value), 16))
end

return M
