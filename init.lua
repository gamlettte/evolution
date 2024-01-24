local field = require("field.field")
local curses = require("curses")

math.randomseed(os.clock())

---@type integer
local size = 115

---@type stdscr
local stdscr = curses.initscr()

stdscr:clear()

---@type integer
local y_screen_size = curses.lines()

---@type integer
local x_screen_size = curses.cols()

---@type integer
local y_size = y_screen_size - 2

---@type integer
local x_size = x_screen_size - 3

---@type integer
local MINIMAL_SUCCESS_ITERATIONS = 500

---@type integer
local INITIAL_PLACEMENT_PROMILE = 100

-- while true do

while true do
    ---@type field
    local a = field.new(y_size, x_size,
                        INITIAL_PLACEMENT_PROMILE)

    ---@type integer
    local iteration_counter = 0
    while true do
        ---@type integer
        local start_time_1 = os.clock()

        a:get_iteration()
        iteration_counter = iteration_counter + 1

        if -- iteration_counter > MINIMAL_SUCCESS_ITERATIONS
        true -- false
        then
            local grid = a:to_print()

            stdscr:clear()
            for i = 1, y_size do
                stdscr:mvaddstr(i, 0, grid[i] .. " " .. i)
            end

            stdscr:mvaddstr(y_size + 1, 0,
                            " iterations = " ..
                                iteration_counter)
            stdscr:refresh()
        end

        ---@type integer
        local bot_count = a:count_bots()
        if bot_count == 0 then
            print("FAILED!!!\r")
            break
        end

        ---@type integer
        local end_time_2 = os.clock()
    end
end
