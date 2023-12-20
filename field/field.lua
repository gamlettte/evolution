local cell = require("field.cell")

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
function field.new(height --[[@as integer]],
                   width --[[@as integer]],
                   population --[[@as integer]])
    assert(height > 0)
    assert(width > 0)
    population = population >= 0 and population or 0

    ---@type cell[][]
    local grid = {}

    for i = 1, height do
        ---@type cell[]
        local row = {}

        for j = 1, width do
            if population > 0 then
                row[j] = cell.new(population > math.random(100))
            else
                row[j] = cell.new(false)
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
---@operator eq(field):boolean
---@param other field
---@return boolean
---@nodiscard
function field:__eq(other --[[@as field]])
    if self._height ~= other._height or self._width ~= other._width then return false end
    for i = 1, self._height do
        for j = 1, self._width do
            if self._grid[i][j] ~= other._grid[i][j] then
                return false
            end
        end
    end
    return true
end

---@public
---@return nil
function field:get_iteration()
    ---@type field
    local result = field.new(self._height, self._width, 0)
    for i = 2, self._height - 1 do
        for j = 2, self._width - 1 do

            ---@type integer[]
            local direction_info = {
                self._grid[i - 1][j - 1]:has_bot() and 0 or 1,
                self._grid[i - 1][j    ]:has_bot() and 0 or 1,
                self._grid[i - 1][j + 1]:has_bot() and 0 or 1,
                self._grid[i    ][j - 1]:has_bot() and 0 or 1,
                self._grid[i    ][j    ]:has_bot() and 0 or 1,
                self._grid[i    ][j + 1]:has_bot() and 0 or 1,
                self._grid[i + 1][j - 1]:has_bot() and 0 or 1,
                self._grid[i + 1][j    ]:has_bot() and 0 or 1,
                self._grid[i + 1][j + 1]:has_bot() and 0 or 1,
            }

            if self._grid[i][j]:has_bot() then
                ---@type integer, integer
                local new_x, new_y = self._grid[i][j]:get_direction(direction_info)
            result._grid[i + new_x][j + new_y] = self._grid[i][j]
            end
        end
    end
    assert(result._grid ~= nil)
    self._grid = result._grid
end

return field
