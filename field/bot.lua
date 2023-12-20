---@class bot
---@field private _brain integer
local bot = {}
bot.__index = bot

---@public
---@param value integer
---@return bot
---@nodiscard
function bot.new(value --[[@as integer]])
    ---@type bot
    local self = setmetatable({
            _brain = value
        },
        bot)

    return self
end

---@public
---@param environment integer[]
---@return integer, integer
---@nodiscard
function bot:get_direction(environment --[=[@as integer[] ]=])
    assert(#environment == 9)

    local resultx = math.random(0, 2) - 1
    local resulty = math.random(0, 2) - 1
    return resultx, resulty
end

return bot
