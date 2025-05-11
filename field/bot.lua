---@module "field.bot_actions"
local bot_actions = require("field.bot_actions")

---@module "field.perceptron.perceptron"
local perceptron = require("field.perceptron.perceptron")

---@module "field.perceptron.activation_functions"
local activation_functions = require("field.perceptron.activation_functions")

---@module "configs.bot_config"
local bot_config = require("configs.bot_config")

---@module "field.bot_rotation"
local rotation = require("field.bot_rotation")


---@class bot
---@field private _brain perceptron
---@field private _direction_x integer
---@field private _direction_y integer
---@field private _energy integer
---@field private _gene integer
---@field private _life_counter integer
---@field private _action integer
local bot = {}
bot.__index = bot


---@public
---@return bot
---@nodiscard
function bot:get_child()

    ---@type bot
    local child = setmetatable({
        _direction_y = math.random(-1, 1),
        _direction_x = math.random(-1, 1),
        _brain = self._brain:new_deep_copy(),
        _energy = math.random(
            bot_config.CONST_INITIAL_MIN_ENERGY,
            bot_config.CONST_INITIAL_MAX_ENERGY),
        _gene = self._gene,
        _life_counter = 0,
        _action = 0,
    }, bot)

    self._energy = self._energy - bot_config.CONST_MULTIPLY_COST

    if math.random(bot_config.CONST_GENE_MUTATION_SPAWN_PROB) == 1 then
        local new_gene = child._gene + math.random(-1, 1)
        if new_gene > bot_config.CONST_MAX_GENE_VALUE then
            new_gene = bot_config.CONST_MIN_GENE_VALUE
        end

        if new_gene < bot_config.CONST_MIN_GENE_VALUE then
            new_gene = bot_config.CONST_MAX_GENE_VALUE
        end
        child._gene = new_gene
    end

    if math.random(bot_config.CONST_BRAIN_MUTATION_SPAWN_PROB) == 1 then
        child._brain:mutate()
    end

    return child
end


---@public
---@return bot
---@nodiscard
function bot.new()

    ---@type integer
    local gene = math.random(
        bot_config.CONST_MIN_GENE_VALUE,
        bot_config.CONST_MAX_GENE_VALUE)

    ---@type bot
    local self = setmetatable({
        _direction_y = math.random(-1, 1),
        _direction_x = math.random(-1, 1),
        _brain = perceptron.new(
            bot_config.CONST_BRAIN_STRUCTURE,
            activation_functions.ENUM.RE_LU.FUNCTION,
            activation_functions.ENUM.RE_LU.DERIVATIVE),
        _energy = math.random(
            bot_config.CONST_INITIAL_MIN_ENERGY,
            bot_config.CONST_INITIAL_MAX_ENERGY),
        _gene = gene,
        _life_counter = 0,
        _action = 0,
    }, bot)

    return self
end


---@public
---@return integer, integer
---@nodiscard
function bot:get_pov()
    return self._direction_y, self._direction_x
end


---@public
---@return integer
---@nodiscard
function bot:get_action_data()
    return self._action
end


---@private
---@param input_vector integer[]
---@return BOT_ACTION
---@nodiscard
function bot:parse_brain_response(input_vector)

    ---@type number[]
    local response_array = self._brain:run(input_vector)

    ---@type number
    local temp_x = self._direction_x

    ---@type number
    local temp_y = self._direction_y

    ---@type number
    local to_reverse = table.remove(response_array, #response_array)
    if to_reverse > 0.5 then
        temp_x, temp_y = rotation.reverse(temp_x, temp_y)
    end

    ---@type number
    local to_rotate_90 = table.remove(response_array, #response_array)
    if to_rotate_90 > 0.5 then
        temp_x, temp_y = rotation.rotate_90(temp_x, temp_y)
    end

    ---@type number
    local to_rotate_45 = table.remove(response_array, #response_array)
    if to_rotate_45 > 0.5 then
        temp_x, temp_y = rotation.rotate_45(temp_x, temp_y)
    end

    self._direction_y = temp_x
    self._direction_x = temp_y


    assert(#response_array == bot_actions.ACTION_SIZE,
        "r2 = "..#response_array.." bas = "..bot_actions.ACTION_SIZE)

    ---@type integer
    local max_ind = -1

    ---@type number
    local max_val = -math.huge

    for index, value in ipairs(response_array) do
        if max_val < value then
            max_ind = index
            max_val = value
        end
    end
    assert(max_ind <= bot_actions.ACTION_SIZE and max_ind > 0,
           "mi = " .. max_ind .. " bs = " .. bot_actions.ACTION_SIZE)

    self._action = max_ind

    return self._action --[[@as BOT_ACTION]]
end


---@public
---@param observed_cell cell
---@return BOT_ACTION?
---@nodiscard
function bot:get_action(observed_cell)
    if self._life_counter == bot_config.CONST_MAX_BOT_AGE then
        return nil
    end

    if math.random(bot_config.CONST_BRAIN_MUTATION_ACTION_PROB) then
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
    table.insert(input_data, math.min(self._life_counter / bot_config.CONST_MAX_BOT_AGE, 1))

    table.insert(input_data, observed_cell_has_bot)
    table.insert(input_data, math.min(observed_cell:get_energy() / 10, 1))

    for index, value in ipairs(input_data) do
        assert(value <= 1.0, "input_data[" .. index .."] = " .. value)
    end

    ---@type BOT_ACTION
    return self:parse_brain_response(input_data)
end


---@public
---@param new_energy integer
---@return nil
function bot:add_energy(new_energy)
    self._energy = self._energy + new_energy
end


---@public
---@param energy integer
---@return nil
function bot:subtract_energy(energy)
    self._energy = math.max(0, self._energy - energy)
end


---@public
---@return integer
---@nodiscard
function bot:get_energy()
    return self._energy
end


return bot
