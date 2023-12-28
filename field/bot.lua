local bot_actions = require("field.bot_actions")
---@class bot
---@field private _weight_layer_1 integer[][]
---@field private _weight_layer_2 integer[][]
---@field private _direction_x integer
---@field private _direction_y integer
---@field private _energy integer
---@field private _genes integer[]
local bot = {}
bot.__index = bot

---@type integer
local WEIGHT_DEVIATION = 6

---@type integer
local BRAIN_MUTATION_PROB = 10

---@public
---@return bot
---@nodiscard
function bot:get_child()
    ---@type bot
    local child = setmetatable({
        _direction_y = math.random(-1, 1),
        _direction_x = math.random(-1, 1),
        _weight_layer_1 = self._weight_layer_1,
        _weight_layer_2 = self._weight_layer_2,
        _energy = math.random(5) + 5,
        _genes = self._genes
    }, bot)

    -- gene mutation
    if math.random(5) == 1 then
        ---@type integer
        local index = math.random(3)
        child._genes[index] = child._genes[index] + math.random(-1, 1)
    end

    -- brain mutation
    if math.random(BRAIN_MUTATION_PROB) == 1 then
        child._weight_layer_1[math.random(#child._weight_layer_1)][math.random(
            #child._weight_layer_1[1])] = math.random(
                                              -WEIGHT_DEVIATION,
                                              WEIGHT_DEVIATION)
    end
    if math.random(BRAIN_MUTATION_PROB) == 1 then
        child._weight_layer_2[math.random(#child._weight_layer_2)][math.random(
            #child._weight_layer_2[1])] = math.random(
                                              -WEIGHT_DEVIATION,
                                              WEIGHT_DEVIATION)
    end

    assert(child._weight_layer_1)
    assert(child._weight_layer_2)

    return child
end


---@public
---@return bot
---@nodiscard
function bot.new()

    ---@type integer[]
    local weight_row = {}

    ---@type integer[][]
    local weight_layer_1 = {}
    for i = 1, 4 do

        weight_row = {}
        for j = 1, 5 do
            weight_row[j] = math.random(-WEIGHT_DEVIATION,
                                        WEIGHT_DEVIATION)
        end

        weight_layer_1[i] = weight_row
    end

    ---@type integer[][]
    local weight_layer_2 = {}
    for i = 1, bot_actions.ACTION_SIZE + 2 - 1 do

        weight_row = {}
        for j = 1, 4 do
            weight_row[j] = math.random(-WEIGHT_DEVIATION,
                                        WEIGHT_DEVIATION)
        end

        weight_layer_2[i] = weight_row
    end

    ---@type integer[]
    local genes = {
        math.random(255),
        math.random(255),
        math.random(255)
    }

    ---@type bot
    local self = setmetatable({
        _direction_y = math.random(-1, 1),
        _direction_x = math.random(-1, 1),
        _weight_layer_1 = weight_layer_1,
        _weight_layer_2 = weight_layer_2,
        _energy = math.random(5) + 5,
        _genes = genes
    }, bot)

    assert(self._weight_layer_1)
    assert(self._weight_layer_2)

    return self
end


---@public
---@return integer, integer
---@nodiscard
function bot:get_pov()
    return self._direction_y, self._direction_x
end


---@private
---@param input number
---@return number
---@nodiscard
local function norm(input)
    if input > 40 then
        return 1
    end
    local x = math.exp(input)

    local result = x / (x + 1)
    assert(result >= 0 and result <= 1, "input = " .. input)
    return result
end


---@private
---@param vector number[]
---@param matrix number[][]
---@return number[]
---@nodiscard
local function pass_layer(vector, matrix)
    ---@type integer[]
    local result_vector = {}

    for _, row in ipairs(matrix) do
        ---@type number
        local row_sum = 0

        for i, v in ipairs(row) do
            row_sum = row_sum + (v * vector[i])
        end

        ---@type number
        local norm_sum = norm(row_sum)

        assert(norm_sum <= 1 and norm_sum >= 0)

        table.insert(result_vector, norm_sum)
    end

    return result_vector
end


---@private
---@param input_vector integer[]
---@return BOT_ACTION
---@nodiscard
function bot:brain_response(input_vector)
    ---@type integer[]
    local r1 = pass_layer(input_vector, self._weight_layer_1)

    ---@type integer[]
    local r2 = pass_layer(r1, self._weight_layer_2)
    assert(r2[1])

    ---@type integer[]
    local direction_vector = {table.remove(r2, #r2)}
    table.insert(direction_vector, table.remove(r2, #r2))

    for index, value in ipairs(direction_vector) do
        if value < 0.3 and value > 0 then
            direction_vector[index] = -1
        elseif value < 0.7 then
            direction_vector[index] = 0
        elseif value < 1 then
            direction_vector[index] = 1
        end
    end

    self._direction_y = direction_vector[1]
    self._direction_x = direction_vector[2]

    ---@type integer
    local max_ind = -1

    ---@type number
    local max_val = 0.0

    assert(#r2 == bot_actions.ACTION_SIZE - 1)

    for index, value in ipairs(r2) do
        assert(value >= 0 and value <= 1, "value = " .. value)
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
---@return BOT_ACTION
---@nodiscard
function bot:get_action(observed_cell)
    self._energy = self._energy - 2

    ---@type integer[]
    local input_data = {}

    table.insert(input_data, self._energy / 5)
    table.insert(input_data, self._direction_x)
    table.insert(input_data, self._direction_y)
    table.insert(input_data, observed_cell:has_bot() and 1 or 0)
    table.insert(input_data, observed_cell:get_energy() / 5)

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
