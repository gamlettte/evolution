---@private
---@param x integer
---@param y integer
---@return integer, integer -- x, y
---@nodiscard
local function reverse(x, y)
    assert(x == -1 or x == 0 or x == 1)
    assert(y == -1 or y == 0 or y == 1)
    return -x, -y
end


---@private
---@param x integer
---@param y integer
---@return integer, integer -- x, y
---@nodiscard
local function rotate_90(x, y)
    assert(x == -1 or x == 0 or x == 1)
    assert(y == -1 or y == 0 or y == 1)
    local table = {
        [-1] = {
            [-1] = {-1,  1},
            [ 0] = { 0,  1},
            [ 1] = { 1,  1},
        },
        [ 0] = {
            [-1] = {-1,  0},
            [ 0] = { 0,  0},
            [ 1] = { 1,  0},
        },
        [ 1] = {
            [-1] = { 1, -1},
            [ 0] = { 0, -1},
            [ 1] = { 1, -1},
        },
    }
    local result = table[x][y]
    return result[1], result[2]
end


---@private
---@param x integer
---@param y integer
---@return integer, integer -- x, y
---@nodiscard
local function rotate_45(x, y)
    assert(x == -1 or x == 0 or x == 1)
    assert(y == -1 or y == 0 or y == 1)
    local table = {
        [-1] = {
            [-1] = {-1,  0},
            [ 0] = {-1,  1},
            [ 1] = { 0,  1},
        },
        [ 0] = {
            [-1] = {-1, -1},
            [ 0] = { 0,  0},
            [ 1] = { 1,  1},
        },
        [ 1] = {
            [-1] = { 0, -1},
            [ 0] = { 1, -1},
            [ 1] = { 1,  0},
        },
    }
    local result = table[x][y]
    return result[1], result[2]
end


local rotations = {
    reverse = reverse,
    rotate_90 = rotate_90,
    rotate_45 = rotate_45,
}

return rotations
