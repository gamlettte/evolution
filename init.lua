local field = require("field.field")
local curses = require("curses")

math.randomseed(os.clock())

---@type integer
local size = 115

---@type integer
local y_size = size

---@type integer
local x_size = 475

local stdscr = curses.initscr()
stdscr:clear()

-- while true do

---@type field
local a = field.new(y_size, x_size, 500)

while true do
    ---@type integer
    local start_time_2 = os.clock()

    a:get_iteration()

    local grid = a:to_print()
    stdscr:clear()
    for i = 1, y_size do stdscr:mvaddstr(i, 0, grid[i]) end
    stdscr:refresh()

    ---@type integer
    local bot_count = a:count_bots()
    if bot_count == 0 then
        break
    end

    ---@type integer
    local end_time_2 = os.clock()
    -- print("bc = "..bot_count)
end
-- end
