local bot_actions = require("field.bot_actions")

local perceptron = require("field.perceptron.perceptron")
local activation_functions = require("field.perceptron.activation_functions")


_G.bot_brain_count = 0
local const_brain_structure = {5, 5, 5}

---@class bot
---@field private _brain perceptron
---@field private _direction_x integer
---@field private _direction_y integer
---@field private _energy integer
---@field private _gene integer
---@field private _life_counter integer
local bot = {}
bot.__index = bot

---@type integer
local CONST_WEIGHT_DEVIATION = 10

---@type integer
local CONST_BRAIN_MUTATION_SPAWN_PROB = 5

---@type integer
local CONST_BRAIN_MUTATION_ACTION_PROB = 10

---@type integer
local CONST_MAX_BOT_AGE = 200

---@type integer
local CONST_MAX_GENE_VALUE = 94


---@public
---@return bot
---@nodiscard
function bot:get_child()

    ---@type bot
    local child = setmetatable({
        _direction_y = math.random(-1, 1),
        _direction_x = math.random(-1, 1),
        _brain = self._brain:new_deep_copy(),
        _energy = math.random(3) + 15,
        _gene = self._gene,
        _life_counter = 0
    }, bot)

    self._energy = self._energy - 11

    if math.random(15) == 1 then
        child._gene = child._gene + math.random(-1, 1)
    end

    if math.random(CONST_BRAIN_MUTATION_SPAWN_PROB) == 1 then
        child._brain:mutate()
    end

    return child
end


---@public
---@return bot
---@nodiscard
function bot.new()

    ---@type integer
    local gene = math.random(CONST_MAX_GENE_VALUE)

    ---@type bot
    local self = setmetatable({
        _direction_y = math.random(-1, 1),
        _direction_x = math.random(-1, 1),
        _brain = perceptron.new(const_brain_structure, activation_functions.ENUM.RE_LU.FUNCTION,
                                                 activation_functions.ENUM.RE_LU.DERIVATIVE),
        _energy = math.random(3) + 5,
        _gene = gene,
        _life_counter = 0
    }, bot)

    return self
end


---@public
---@return integer, integer
---@nodiscard
function bot:get_pov()
    return self._direction_y, self._direction_x
end

---@private
---@param input_vector integer[]
---@return BOT_ACTION
---@nodiscard
function bot:brain_response(input_vector)
    local r2 = self._brain:run(input_vector)

    ---@type integer[]
    local direction_vector = {}
    table.insert(direction_vector, table.remove(r2, #r2))
    table.insert(direction_vector, table.remove(r2, #r2))

    for index, value in ipairs(direction_vector) do
        if value < 0.25 and value > 0 then
            direction_vector[index] = -1
        elseif value < 0.75 then
            direction_vector[index] = 0
        else
            direction_vector[index] = 1
        end
    end

    self._direction_y = direction_vector[1]
    self._direction_x = direction_vector[2]

    ---@type integer
    local max_ind = -1

    ---@type number
    local max_val = 0.0

    assert(#r2 == bot_actions.ACTION_SIZE - 1, "r2 = "..#r2.." bas = "..bot_actions.ACTION_SIZE)

    for index, value in ipairs(r2) do
        -- assert(value >= 0 and value <= 1, "value = " .. value)
        if max_val < value then
            max_ind = index
            max_val = value
        end
    end
    assert(max_ind <= bot_actions.ACTION_SIZE,
           "mi = " .. max_ind .. " bs = " .. bot_actions.ACTION_SIZE)

    return max_ind + 1 --[[@as BOT_ACTION]]
end


---@public
---@param observed_cell cell
---@return BOT_ACTION?
---@nodiscard
function bot:get_action(observed_cell)
    if self._life_counter == CONST_MAX_BOT_AGE then
        return nil
    end

    if math.random(CONST_BRAIN_MUTATION_ACTION_PROB) then
        self._brain:mutate()
    end

    self._life_counter = self._life_counter + 1

    self._energy = self._energy - 1

    ---@type integer[]
    local input_data = {}

    local observed_cell_has_bot = (observed_cell:has_bot() and
                                      not (self._direction_x == 0
                                           and self._direction_y == 0))
                                  and 1 or 0

    table.insert(input_data, math.min(self._energy / 30, 1))
    table.insert(input_data, self._direction_x)
    table.insert(input_data, self._direction_y)
    table.insert(input_data, observed_cell_has_bot)
    table.insert(input_data, math.min(observed_cell:get_energy() / 10, 1))

    do
        ---@type number
        local max = -math.huge
        for _, value in ipairs(input_data) do
            if value > max then
                max = value
            end
        end
        assert(max <= 1.0, "max = "..max)
    end

    ---@type BOT_ACTION
    return self:brain_response(input_data)
end


---@public
---@param new_energy integer
---@return nil
function bot:add_energy(new_energy)
    self._energy = self._energy + new_energy
end


---@public
---@return integer
---@nodiscard
function bot:get_energy()
    return self._energy
end


return bot
