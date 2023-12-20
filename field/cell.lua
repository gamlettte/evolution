local bot = require("field.bot")

---@class cell
---@field _bot_place bot|nil
---@field _energy integer
local cell = {}
cell.__index = cell

---@public
---@param is_bot boolean does contain bot initially
---@return cell
---@nodiscard
function cell.new(is_bot --[[@as boolean]])
    ---@type cell
    local self = setmetatable({
        _bot_place = is_bot and bot.new(9) or nil,
        _energy = 3
    },
    cell)
    return self
end

---@public
---@param environment integer[]
---@return integer, integer
---@nodiscard
function cell:get_direction(environment --[=[@as integer[] ]=])
    assert(self:has_bot())

    return self._bot_place:get_direction(environment)
end

---@public
---@return boolean
---@nodiscard
function cell:has_bot()
    return self._bot_place ~= nil
end

return cell
