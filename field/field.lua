local cell = require("field.cell")
local bot_actions = require("field.bot_actions")

---@class field
---@field private _height integer
---@field private _width integer
---@field private _grid cell[][]
local field = {}
field.__index = field

---@public
---@param height integer field width
---@param width integer field height
---@param population integer spawn rate of bots in promile
---@return field
---@nodiscard
function field.new(height, width, population)

    assert(type(height) == 'number', "Error: height must be a number.")
    assert(type(width) == 'number', "Error: width must be a number.")
    assert(type(population) == 'number', "Error: population must be a number.")
    assert(height > 0, "Error: height must be greater than zero.")
    assert(width > 0, "Error: width must be greater than zero.")
    assert(population > 0 and population <= 1000, "Error: population must be between 1 and 1000 (inclusive).")

    ---@type cell[][]
    local grid = {}

    for i = 1, height do
        ---@type cell[]
        local row = {}

        for j = 1, width do
            if population <= 0 then
                row[j] = cell.new(false)
            else
                row[j] = cell.new(population >= math.random(1000))
            end
        end

        grid[i] = row
    end

    ---@type field
    local self = setmetatable({
        _height = height,
        _width = width,
        _grid = grid}
    ,field)

    return self
end


---@public
---@param other field
---@return field
---@nodiscard
function field.new_default(other)
    ---@type cell[][]
    local grid = {}

    for i = 1, other._height do
        ---@type cell[]
        local row = {}

        for j = 1, other._width do
            row[j] = cell.new(false)
            row[j]._energy = 0
        end

        grid[i] = row
    end

    ---@type field
    local self = setmetatable({
        _height = other._height,
        _width = other._width,
        _grid = grid
    }, field)

    return self
end


---@public
---@return integer
---@nodiscard
function field:count_bots()
    ---@type integer
    local bot_counter = 0

    for i = 1, self._height do
        for j = 1, self._width do
            if self._grid[i][j]:has_bot() then
                bot_counter = bot_counter + 1
            end
        end
    end

    return bot_counter
end


---@public
---@return integer
---@nodiscard
function field:count_bots_rate()
    return self:count_bots() / (self._height * self._width)
end


---@public
---@param other field
---@return boolean
---@nodiscard
function field:__eq(other)
    if self._height ~= other._height or self._width ~= other._width then
        return false
    end

    for i = 1, self._height do
        for j = 1, self._width do
            if self._grid[i][j] ~= other._grid[i][j] then
                return false
            end
        end
    end
    return true
end


---@private
---@return nil
function field:update_energy()
    for i = 1, self._height do
        for j = 1, self._width do
            if self._grid[i][j]:get_energy() < 11 then
                self._grid[i][j]:add_energy(3)
            end
        end
    end
end

---@private
---@param current_cell cell
---@param bot_action BOT_ACTION?
---@param observed_cell cell
---@return cell, cell, bot? -- current cell, observed cell, new bot
function field.process_cells(current_cell, bot_action, observed_cell)

    ---@type bot?
    local child_bot = nil

    local action_table = {
        [bot_actions.ENUM.MOVE] = function()
            if not observed_cell:has_bot() then
                observed_cell:accept_bot(current_cell:get_bot())
                current_cell:kill_bot()
            end
        end,
        [bot_actions.ENUM.CONSUME_ENERGY] = function()
            current_cell:feed_bot()
        end,
        [bot_actions.ENUM.CONSUME_BOT] = function()
            ---@type integer
            local energy = observed_cell:kill_bot()

            if current_cell:has_bot() then
                current_cell:feed_bot(energy)
                observed_cell:accept_bot(current_cell:get_bot())
                current_cell:kill_bot()
            end
        end,
        [bot_actions.ENUM.MULTIPLY] = function ()
            if current_cell:get_bot_energy() <= 10 then
                current_cell:kill_bot()
            else
                child_bot = current_cell:get_child()
            end
        end,
    }
    
    if bot_action then
        action_table[bot_action]()
    end

    return current_cell, observed_cell, child_bot
end


---@private
---@param position integer
---@param shift integer
---@param max integer
---@return integer
---@nodiscard
local function get_shifted(position, shift, max)
    return (position - shift + max - 1) % max + 1
end

---@public
---@param result field
---@return integer[] action_data
---@nodiscard
function field:get_iteration(result)

    self:update_energy()

    ---@type integer[]
    local action_data = {}

    for _ = 1, bot_actions.ACTION_SIZE do
        table.insert(action_data, 0)
    end

    for i = 1, self._height do
        for j = 1, self._width do

            ---@type integer[]
            if self._grid[i][j]:has_bot() then

                ---@type cell
                local current_cell = self._grid[i][j]

                ---@type integer, integer
                local d_y, d_x = current_cell:get_bot_pov()

                ---@type integer
                local direction_y = get_shifted(i, d_y, self._height)

                ---@type integer
                local direction_x = get_shifted(j, d_x, self._width)

                assert(self._grid[i])
                assert(self._grid[direction_y], direction_y .. " " .. direction_x)

                ---@type cell
                local observed_cell = self._grid[direction_y][direction_x]

                ---@type BOT_ACTION?
                local bot_action = current_cell:get_action(observed_cell)

                if bot_action ~= nil then
                    assert(action_data[bot_action] ~= nil, "action_data, " .. bot_action)
                    action_data[bot_action] = action_data[bot_action] + 1
                end

                ---@type bot?
                local child_bot

                current_cell,
                observed_cell,
                child_bot = field.process_cells(current_cell,
                                                bot_action,
                                                observed_cell)
                if child_bot then
                    result._grid[get_shifted(i, math.random(-1, 1), self._height)]
                                [get_shifted(j, math.random(-1, 1), self._width)]
                        :accept_bot(child_bot)
                end

                result._grid[direction_y][direction_x] = observed_cell
                result._grid[i][j] = current_cell
            end
        end
    end

    assert(result._grid[1] ~= nil)
    self._grid = result._grid

    return action_data
end


---@public
---@return string[]
---@nodiscard
function field:to_print()

    ---@type string[]
    local result = {}

    for _, row in ipairs(self._grid) do

        ---@type string[]
        local res_table = {}

        for i, box in ipairs(row) do
                res_table[i] = box:has_bot() and string.char(box:get_bot()._gene) or " "
        end

        result[#result + 1] = table.concat(res_table)
    end

    return result
end


return field
