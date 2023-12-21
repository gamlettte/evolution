local test_runner = require("misc.test_runner")
local bot = require("field.bot")

---@type test_runner
local tr = test_runner.new()

tr:add_test_case("smoke test", function ()

end)


tr:add_test_case("bot:new", function ()

    ---@type bot
    local bot_a = bot:new()
    assert(bot_a)
end)

tr:add_test_case("get_direction", function ()

    ---@type bot
    local bot_a = bot:new()

    ---@type integer[]
    local input = {}
    for i = 1, 18 do
        table.insert(input, i)
    end

    local y, x = bot_a:get_direction(input)
    assert(y <= 1 and y >= -1)
    assert(x <= 1 and x >= -1)
end)

tr:evaluate()
