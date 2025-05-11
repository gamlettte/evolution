local field = require("field.field")

---@class field_manager
---@field private _field_arr field[]
---@field private _is_first_field_used boolean
---@field private _iteration_counter integer
local field_manager = {}
field_manager.__index = field_manager


---@public
---@param height integer field width
---@param width integer field height
---@param population integer spawn rate of bots in promile
---@return field_manager
---@nodiscard
function field_manager.new(height, width, population)
    assert(type(height) == 'number', "Error: height must be a number.")
    assert(type(width) == 'number', "Error: width must be a number.")
    assert(type(population) == 'number', "Error: population must be a number.")
    assert(height > 0, "Error: height must be greater than zero.")
    assert(width > 0, "Error: width must be greater than zero.")
    assert(population > 0 and population <= 1000, "Error: population must be between 1 and 1000 (inclusive).")

    ---@type field[]
    local field_arr = {}

    field_arr[1] = field.new(height, width, population)
    field_arr[2] = field.new_default(field_arr[1])

    ---@type field_manager
    local self = setmetatable({
        _field_arr = field_arr,
        _is_first_field_used = true,
        _iteration_counter = 0,
    }
    ,field_manager)

    return self
end

---@public
---@return integer[] action_data
---@nodiscard
function field_manager:get_iteration()

    ---@type boolean
    local is_first_field_used = self._is_first_field_used

    ---@type integer[]
    local return_data = nil
    if is_first_field_used then
        return_data = self._field_arr[1]:get_iteration(self._field_arr[2])
    else
        return_data = self._field_arr[2]:get_iteration(self._field_arr[1])
    end

    assert(return_data, "return_data is "..type(return_data))

    self._is_first_field_used = not is_first_field_used

    self._iteration_counter = self._iteration_counter + 1

    return return_data
end


---@public
---@return integer
---@nodiscard
function field_manager:get_iteration_count()
    return self._iteration_counter
end


---@public
---@return integer, integer y, x
---@nodiscard
function field_manager:get_field_sizes()
    return self._field_arr[1]._height, self._field_arr[1]._width -- TODO add getter
end


---@public
---@return string[]
---@nodiscard
function field_manager:to_print()

    if  self._is_first_field_used then
        return self._field_arr[1]:to_print()
    else
        return self._field_arr[2]:to_print()
    end
end


---@public
---@return integer
---@nodiscard
function field_manager:count_bots()

    if  self._is_first_field_used then
        return self._field_arr[1]:count_bots()
    else
        return self._field_arr[2]:count_bots()
    end
end


---@public
---@return (integer?)[][]
---@nodiscard
function field_manager:get_action_data_matrix()

    if  self._is_first_field_used then
        return self._field_arr[1]:get_action_data_matrix()
    else
        return self._field_arr[2]:get_action_data_matrix()
    end
end

return field_manager
