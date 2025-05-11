---@module "socket"
local socket = require "socket"

---@module "field.field"
local field = require("field.field")

---@module "field.bot_actions"
local bot_actions = require("field.bot_actions")

---@module "field.field_manager"
local field_manager = require("field.field_manager")

---@module "curses"
local curses = require("curses")

---@module "configs.tui_config"
local tui_config = require("configs.tui_config")

---@module "configs.field_config"
local field_config = require("configs.field_config")

---@module "argparse"
local argparse = require("argparse")


---@private
---@param is_visualize_argument string
---@param iteration_counter integer
---@param MINIMAL_SUCCESS_ITERATIONS integer
---@param CONST_FRAME_PRINT_RATE integer
---@return boolean
---@nodiscard
local function is_field_visualized(is_visualize_argument,
                                   iteration_counter,
                                   MINIMAL_SUCCESS_ITERATIONS,
                                   CONST_FRAME_PRINT_RATE)
    local match = {
        ["always"] = iteration_counter % CONST_FRAME_PRINT_RATE == 0,
        ["from_set_moment"] = iteration_counter > MINIMAL_SUCCESS_ITERATIONS and
            iteration_counter % CONST_FRAME_PRINT_RATE == 0,
        ["never"] = false
    }

    return match[is_visualize_argument] or false
end


---@private
---@param a_stdscr stdscr
---@param a_field_manager field_manager
---@param a_CONST_VISUALIZATION_MODE string
local function update_screen(a_stdscr, a_field_manager, a_CONST_VISUALIZATION_MODE)

    ---@type integer
    local iteration_counter = a_field_manager:get_iteration_count()

    if is_field_visualized(
        a_CONST_VISUALIZATION_MODE,
        iteration_counter,
        tui_config.CONST_MINIMAL_SUCCESS_ITERATIONS,
        tui_config.CONST_FRAME_PRINT_RATE) then
        ---@type string[]
        local grid = a_field_manager:to_print()

        a_stdscr:clear()

        local y_field_size, _ = a_field_manager:get_field_sizes()
        for i = 1, y_field_size do
            a_stdscr:mvaddstr(i, 0, grid[i] .. " " .. i)
        end

        a_stdscr:mvaddstr(y_field_size + 1, 0,
                        " iterations = " .. iteration_counter)
        a_stdscr:refresh()

        socket.sleep(tui_config.CONST_FRAME_PERIOD)

    elseif iteration_counter % tui_config.CONST_LOG_PRINTOUT_THRESHOLD == 0 then
        ---@type number
        local percent_done = iteration_counter 
            / tui_config.CONST_LOG_PRINTOUT_THRESHOLD

        print(math.floor(percent_done) .. " % done\r")
    end
end


local parser = argparse()

parser:option("--visualize"):choices({"always", "from_set_moment", "never"})

parser:option("--print_frame_rate")

local parsed_arguments = parser:parse()


---@type string
local CONST_VISUALIZATION_MODE = parsed_arguments.visualize or
                                tui_config.CONST_VISUALIZATION_MODE

math.randomseed( 
    -- 0
    os.clock()
)

---@type stdscr
local stdscr = curses.initscr()

stdscr:clear()

---@type integer
local y_screen_size = curses.lines()

---@type integer
local x_screen_size = curses.cols()

---@type integer
local y_field_size = 100 -- y_screen_size - 3

---@type integer
local x_field_size = 190 -- x_screen_size - 5

---@type integer
local epoch_counter = 0
while epoch_counter < 1000 do
    epoch_counter = epoch_counter + 1
    ---@type field_manager
    local my_field_manager = field_manager.new(
        y_field_size,
        x_field_size,
        field_config.CONST_INITIAL_PLACEMENT_PROMILE)

    while true do
        ---@type integer[]
        local action_data = my_field_manager:get_iteration()

        ---@type string[]
        local action_data_string = {}
        for index, value in pairs(action_data) do
            table.insert(action_data_string, index .. " = " .. value)
        end

        update_screen(stdscr, my_field_manager, CONST_VISUALIZATION_MODE)

        if my_field_manager:count_bots() < 10 then
            print(epoch_counter .. "FAILED!!!\r")
            break
        end
    end
end

print("FINFISHED!!")
