local bot = require("field.bot")
local bot_actions = require("field.bot_actions")

---@class cell
---@field private _bot_place bot?
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
    }, cell)
    return self
end


---@public
---@param observed_cell cell
---@return BOT_ACTION?
---@nodiscard
function cell:get_action(observed_cell)
    assert(self:has_bot())

    if self._bot_place:get_energy() <= 0 then
        self._bot_place = nil
        return nil
    end

    ---@type BOT_ACTION?
    local result = self._bot_place:get_action(observed_cell)

    if result == nil then
        self._bot_place = nil
    end

    return result
end


---@public
---@return bot
---@nodiscard
function cell:get_child()
    assert(self:has_bot())

    return self._bot_place:get_child()
end


---@public
---@param new_bot bot
---@return nil
function cell:accept_bot(new_bot)
    self._bot_place = new_bot
end


---@public
---@return bot
---@nodiscard
function cell:get_bot()
    assert(self:has_bot())
    return self._bot_place
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
---@param new_energy integer?
---@return nil
function cell:feed_bot(new_energy)
    assert(self:has_bot())
    if self:has_bot() then
        self._bot_place:add_energy(new_energy and new_energy or
                                       self._energy)
        self._energy = new_energy or 0
    end
end


---@public
---@return integer
---@nodiscard
function cell:get_bot_energy()
    return self._energy
end


---@public
---@return integer
function cell:kill_bot()
    if self._bot_place == nil then
        return 0
    end

    ---@type integer
    local result = self._bot_place:get_energy()
    self._bot_place = nil
    return result
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
