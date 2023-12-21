local bot = require("field.bot")

---@class cell
---@field private _bot_place bot|nil
---@field public _energy integer
local cell = {}
cell.__index = cell

---@public
---@param is_bot boolean does contain bot initially
---@return cell
---@nodiscard
function cell.new(is_bot)
    ---@type cell
    local self = setmetatable({
        _bot_place = is_bot and bot.new() or nil,
        _energy = math.random(3)
    },
    cell)
    return self
end

---@public
---@param environment integer[]
---@return integer, integer
---@nodiscard
function cell:get_direction(environment)
    assert(self:has_bot())

    return self._bot_place:get_direction(environment)
end

---@public
---@return boolean
---@nodiscard
function cell:has_bot()
    return self._bot_place ~= nil
end

---@public
---@param new_energy integer
---@return nil
function cell:add_energy(new_energy)
    self._energy = self._energy + new_energy
end

---@public
---@return integer, integer
---@nodiscard
function cell:get_bot_pov()
    assert(self:has_bot())
    return self._bot_place:get_pov()
end

---@public
---@return integer
---@nodiscard
function cell:get_energy()
    return self._energy
end

return cell
