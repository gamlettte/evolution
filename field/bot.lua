-- local cell = require("field.cell")
---@class bot
---@field private _weight_layer_1 number[][]
---@field private _weight_layer_2 number[][]
---@field private _direction_x integer
---@field private _direction_y integer
local bot = {}
bot.__index = bot

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
        for j = 1, 4 do
            weight_row[j] = math.random(-10, 10)
        end

        weight_layer_1[i] = weight_row
    end

    ---@type integer[][]
    local weight_layer_2 = {}
    for i = 1, 4 do

        weight_row = {}
        for j = 1, 2 do
            weight_row[j] = math.random(-10, 10)
        end

        weight_layer_2[i] = weight_row
    end

    ---@type bot
    local self = setmetatable({
            _direction_y = math.random(-1, 1),
            _direction_x = math.random(-1, 1),
            _weight_layer_1 = weight_layer_1,
            _weight_layer_2 = weight_layer_2
        },
        bot)

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
    local x = math.exp(input)

    return x / (x + 1)
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

        table.insert(result_vector, norm(row_sum))
    end

    return result_vector
end

---@private
---@param input_vector integer[]
---@return integer[]
---@nodiscard
function bot:brain_response(input_vector)
    ---@type integer[]
    local r1 = pass_layer(input_vector, self._weight_layer_1)

    ---@type integer[]
    local r2 = pass_layer(r1, self._weight_layer_2)
    assert(r2[1])

    for index, value in ipairs(r2) do
        if value < 0.3 and value > 0 then
            r2[index] = -1
        elseif value < 0.7 then
            r2[index] = 0
        elseif value < 1 then
            r2[index] = 1
        end
    end

    return r2
end

---@public
---@param observed_cell cell
---@return integer, integer
---@nodiscard
function bot:get_direction(observed_cell)

    ---@type integer[]
    local input_data = {}

    table.insert(input_data, self._direction_x)
    table.insert(input_data, self._direction_y)
    table.insert(input_data, observed_cell:has_bot() and 1 or 0)
    table.insert(input_data, observed_cell:get_energy())

    ---@type integer[]
    local result = self:brain_response(input_data)
    assert(#result == 2)
    assert(result[2])

    return result[1], result[2]
end

return bot
