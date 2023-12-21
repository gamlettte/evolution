local cell = require("field.cell")

---@class field
---@field private _height integer
---@field private _width integer
---@field private _grid cell[][]
---@field private _grid_help integer[]
local field = {}
field.__index = field

---@public
---@param height integer field width
---@param width integer field height
---@param population integer spawn rate of bots in %
---@return field
---@nodiscard
function field.new(height,
                   width,
                   population)
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
                row[j] = cell.new(population >= math.random(100))
            end
        end

        grid[i] = row
    end

    ---@type field
    local self = setmetatable({
            _height = height,
            _width = width,
            _grid = grid
        },
        field)

    return self
end

---@public
---@param other field
---@return field
---@nodiscard
function field.new_cp(other) --research if other is not a copy alr..
    ---@type cell[][]
    local grid = {}

    for i = 1, other._height do
        ---@type cell[]
        local row = {}

        for j = 1, other._width do
            row[j] = cell.new(false)
            row[j]._energy = other._grid[i][j]:get_energy()
        end

        grid[i] = row
    end

    ---@type field
    local self = setmetatable({
            _height = other._height,
            _width = other._width,
            _grid = grid
        },
        field)

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
            self._grid[i][j]:add_energy(math.random(2))
        end
    end
end


---@public
---@return nil
function field:get_iteration()
    self:update_energy()

    ---@type field
    local result = field.new_cp(self)
    assert(result:count_bots() == 0)

    for i = 2, self._height - 1 do
        for j = 2, self._width - 1 do
            ---@type integer[]
            if self._grid[i][j]:has_bot() then
                ---@type integer, integer
                local dir_y, dir_x = self._grid[i][j]
                    :get_bot_pov()
                assert(dir_x)
                assert(dir_y)
                result._grid[dir_y + i][dir_x + j] = self._grid[i][j]
            end
        end
    end

    assert(result._grid ~= nil)
    self._grid = result._grid
end

return field
