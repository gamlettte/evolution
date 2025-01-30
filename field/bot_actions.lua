local BOT_ACTION = {

    ---@enum BOT_ACTION
    ENUM = {
        MOVE = 1,
        CONSUME_BOT = 2,
        MULTIPLY = 3,
        CONSUME_ENERGY = 4,
    },

    ACTION_SIZE = 4,

    ---@private
    REVERSE_ENUM = {
        "MOVE",
        "CONSUME_BOT",
        "MULTIPLY",
        "CONSUME_ENERGY",
    }
}

---@public
---@param bot_action integer
---@return string?
---@nodiscard
function BOT_ACTION.to_string(bot_action)
    if bot_action > BOT_ACTION.ACTION_SIZE then
        return nil
    else
        return BOT_ACTION.REVERSE_ENUM[bot_action]
    end
end

return BOT_ACTION
