---@type integer
local CONST_MINIMAL_SUCCESS_ITERATIONS = 10000

---@type integer
local CONST_LOG_PRINTOUT_THRESHOLD = CONST_MINIMAL_SUCCESS_ITERATIONS / 100

---@type integer
local CONST_FRAME_PRINT_RATE = 1

---@type string[]
local CONST_VISUALIZATION_OPTIONS = {
    "always",
    "from_set_moment",
    "never",
}

local config = {
    CONST_MINIMAL_SUCCESS_ITERATIONS = CONST_MINIMAL_SUCCESS_ITERATIONS,
    CONST_LOG_PRINTOUT_THRESHOLD = CONST_LOG_PRINTOUT_THRESHOLD,
    CONST_FRAME_PRINT_RATE = CONST_FRAME_PRINT_RATE,
    CONST_VISUALIZATION_MODE = CONST_VISUALIZATION_OPTIONS[2]
}

return config
