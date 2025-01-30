
---@type fun(input: number): number
local function sigmoid(input_value)

    if input_value > 40 then
        return 1
    end

    if input_value < -40 then
        return 0
    end

    ---@type number
    local x = math.exp(input_value)

    ---@type number
    local result = x / (x + 1)

    assert(result >= 0 and result <= 1, "input = " .. input_value)

    return result
end


---@type fun(input: number): number
local function sigmoid_derivative(input)
    return input * (1 - input)
end


---@type fun(input: number): number
local function re_lu(input)
    return input > 0 and input or 0
end


---@type fun(input: number): number
local function re_lu_derivative(input)
    return input > 0 and 1 or 0
end


local ACTIVATION_FUNCTIONS = {
    ---@enum ACTIVATION_FUNCTIONS
    ENUM = {
        SIGMOID = {
            FUNCTION = sigmoid,
            DERIVATIVE = sigmoid_derivative
        },
        RE_LU = {
            FUNCTION = re_lu,
            DERIVATIVE = re_lu_derivative
        }
    }
}


return ACTIVATION_FUNCTIONS
