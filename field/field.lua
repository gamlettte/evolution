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
---@param population integer spawn rate of bots in %
---@return field
---@nodiscard
function field.new(height, width, population)
    assert(height > 0)
    assert(width > 0)

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
function field.new_default(other) -- research if other is not a copy alr..
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
            if self._grid[i][j]:get_energy() < 80 then
                self._grid[i][j]:add_energy(14)
            end
        end
    end
end

---@private
---@param current_cell cell
---@param bot_action BOT_ACTION
---@param observed_cell cell
---@return cell, cell, bot|nil -- current cell, observed cell, new bot
function field.process_cells(current_cell, bot_action, observed_cell)

    ---@type bot|nil
    local child_bot = nil

    if bot_action == bot_actions.ENUM.MOVE
    then
        if not observed_cell:has_bot() then
            observed_cell:accept_bot(current_cell:get_bot())
            current_cell:kill_bot()
        end

    elseif bot_action == bot_actions.ENUM.CONSUME_ENERGY
    then
        current_cell:feed_bot()

    elseif
        bot_action == bot_actions.ENUM.CONSUME_BOT
        --false
    then
        ---@type integer
        local energy = observed_cell:kill_bot()
        if current_cell:has_bot() then
            current_cell:feed_bot(energy)
            observed_cell:accept_bot(current_cell:get_bot())
            current_cell:kill_bot()
        end

    elseif bot_action == bot_actions.ENUM.MULTIPLY
    then
        if
            current_cell:get_bot_energy() <= 10
        then
            current_cell:kill_bot()
        else
            child_bot = current_cell:get_child()
        end
    end

    return current_cell, observed_cell, child_bot
end

---@public
---@return nil
function field:get_iteration()
    self:update_energy()

    ---@type field
    local result = field.new_default(self)

    for i = 2, self._height - 1 do
        for j = 2, self._width - 1 do
            ---@type integer[]
            if self._grid[i][j]:has_bot() then
                ---@type cell
                local current_cell = self._grid[i][j]

                ---@type integer, integer
                local dir_y, dir_x = current_cell:get_bot_pov()

                assert(dir_x <= 1 and dir_x >= -1)
                assert(dir_y <= 1 and dir_y >= -1)
                assert(dir_y + i <= self._height)
                assert(self._grid[i])
                assert(self._grid[i + dir_y], "i=" .. i .. " dy=" .. dir_y)

                ---@type cell
                local observed_cell = self._grid[i + dir_y][j + dir_x]

                ---@type BOT_ACTION
                local bot_action = current_cell:get_action(observed_cell)

                ---@type bot|nil
                local child_bot

                current_cell,
                observed_cell,
                child_bot = field.process_cells(current_cell,
                                                bot_action,
                                                observed_cell)
                if child_bot then
                    result._grid[i + math.random(-1, 1)]
                                [j + math.random(-1, 1)]
                        :accept_bot(child_bot)
                end

                result._grid[i + dir_y][j + dir_x] = observed_cell
                result._grid[i][j] = current_cell
                result._grid[i][j]._energy = self._grid[i][j]._energy
            end
        end
    end

    assert(result._grid[1] ~= nil)
    self._grid = result._grid
end


---@public
---@return string[]
---@nodiscard
function field:to_print()
    ---@type string[]
    local result = {}

    for _, value in ipairs(self._grid) do

        ---@type string[]
        local res_table = {}

        for i, box in ipairs(value) do
                res_table[i] = box:has_bot() and "@" or " "
        end

        result[#result + 1] = table.concat(res_table)
    end

    return result
end


return field
