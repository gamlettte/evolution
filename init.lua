local field = require("field.field")

math.randomseed(os.clock())

---@type integer
local size = 200

---@type integer
local y_size = size

---@type integer
local x_size = size

---@type integer
local bot_decrease_verifier = y_size * x_size

---@type field
local a = field.new(y_size, x_size, 1)

for _ = 1, 100 do

    ---@type integer
    local start_time_2 = os.clock()

    a:get_iteration()

    ---@type integer
    local bot_count = a:count_bots()

    assert(bot_count <= bot_decrease_verifier)
    bot_decrease_verifier = bot_count
    print("rate = ", bot_count)

    ---@type integer
    local end_time_2 = os.clock()

    print("size " .. size .. " = "
          .. (end_time_2 - start_time_2))
end
