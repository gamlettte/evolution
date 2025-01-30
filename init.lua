---@module "field.field"
local field = require("field.field")

---@module "field.bot_actions"
local bot_actions = require("field.bot_actions")

---@module "field.field_manager"
local field_manager = require("field.field_manager")

---@module "curses"
local curses = require("curses")

---@module "argparse"
local argparse = require("argparse")

local parser = argparse()

parser:option("--visualize")
    :choices({
        "always",
        "from_set_moment",
        "never"
    })

parser:option("--print_frame_rate")

local parsed_arguments = parser:parse()
for index, value in pairs(parsed_arguments) do
    print(index .. " ^ " .. value)
end


---@private
---@param a_is_visualize_argument string
---@param a_iteration_counter integer
---@param a_MINIMAL_SUCCESS_ITERATIONS integer
---@return boolean
---@nodiscard
local function is_visualized(a_is_visualize_argument,
                             a_iteration_counter,
                             a_MINIMAL_SUCCESS_ITERATIONS)
    if a_is_visualize_argument == "always" then
        return true
    elseif a_is_visualize_argument == "from_set_moment" then
        return a_iteration_counter > a_MINIMAL_SUCCESS_ITERATIONS
    elseif a_is_visualize_argument == "never" then
        return false
    end

    return false
end


math.randomseed(os.clock())

---@type stdscr
local stdscr = curses.initscr()

stdscr:clear()

---@type integer
local y_screen_size = curses.lines()

---@type integer
local x_screen_size = curses.cols()

---@type integer
local y_size = y_screen_size - 3

---@type integer
local x_size = x_screen_size - 3

---@type integer
local CONST_MINIMAL_SUCCESS_ITERATIONS = 10000

---@type integer
local CONST_INITIAL_PLACEMENT_PROMILE = 1

---@type integer
local CONST_LOG_PRINTOUT_THRESHOLD = CONST_MINIMAL_SUCCESS_ITERATIONS / 100

---@type string
local CONST_IS_VISUALIZED = parsed_arguments.visualize

---@type integer
local CONST_FRAME_PRINT_RATE = tonumber(parsed_arguments.print_frame_rate, 10)

while true do
    ---@type field_manager
    local my_field_manager = field_manager.new(y_size, x_size,
        CONST_INITIAL_PLACEMENT_PROMILE)

    ---@type integer
    local iteration_counter = 0

    while true do
        --socket.sleep(0.1)
        ---@type integer
        local start_time_1 = os.clock()

        ---@type integer[]
        local action_data = my_field_manager:get_iteration()

        ---@type string[]
        local action_data_string = {}
        for index, value in pairs(action_data) do
            table.insert(action_data_string, index .. " = " .. value)
        end
        -- print(table.concat(action_data_string, " ") .. "\n\r")

        iteration_counter = iteration_counter + 1

        if iteration_counter % CONST_LOG_PRINTOUT_THRESHOLD <
            (iteration_counter - 1) % CONST_LOG_PRINTOUT_THRESHOLD
        then
            print(math.floor(iteration_counter / CONST_LOG_PRINTOUT_THRESHOLD) .. " % done\r")
        end

        if
            is_visualized(CONST_IS_VISUALIZED, iteration_counter, CONST_MINIMAL_SUCCESS_ITERATIONS)
            -- iteration_counter > MINIMAL_SUCCESS_ITERATIONS
            -- true
            -- false
            and
            iteration_counter % CONST_FRAME_PRINT_RATE == 0
        then
            local grid = my_field_manager:to_print()

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
        local bots_count = my_field_manager:count_bots()

        if bots_count == 0 then
            print("FAILED!!!\r")
            break
        else
            if false and iteration_counter % CONST_FRAME_PRINT_RATE == 0 then
                print("current bot count = " .. bots_count)
            end
        end

        ---@type integer
        local end_time_2 = os.clock()
    end
end
