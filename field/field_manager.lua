local field = require("field.field")
---@class field_manager
---@field private _field_arr field[]
---@field private _is_first_field_used boolean
local field_manager = {}
field_manager.__index = field_manager


---@public
---@param height integer field width
---@param width integer field height
---@param population integer spawn rate of bots in promile
---@return field_manager
---@nodiscard
function field_manager.new(height, width, population)
    assert(height > 0)
    assert(width > 0)
    assert(population > 0 and population <= 1000)

    ---@type field[]
    local field_arr = {}

    field_arr[1] = field.new(height, width, population)
    field_arr[2] = field.new_default(field_arr[1])

    ---@type field_manager
    local self = setmetatable({
        _field_arr = field_arr,
        _is_first_field_used = true,
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

    ---@type integer[][]
    local return_data = {}
    if is_first_field_used then
        return_data = self._field_arr[1]:get_iteration(self._field_arr[2])
    else
        return_data = self._field_arr[2]:get_iteration(self._field_arr[1])
    end

    self._is_first_field_used = not is_first_field_used

    return return_data
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

return field_manager
