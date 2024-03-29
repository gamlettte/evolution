---@class test_runner
---@field private _is_errors boolean
---@field private _test_cases table
---@field private __index any
local test_runner = {}
test_runner.__index = test_runner


---@public
---@return test_runner
---@nodiscard
function test_runner.new()
	local self = setmetatable(
		{
			---@type boolean
			_is_errors = false,

			---@type table
			_test_cases = {}
		},
		test_runner)

	return self
end

---@public
---@param name string
---@param case function
---@return nil
function test_runner:add_test_case(name --[[@as string]],
								   case --[[@as function]])
	assert(name, 'Test name is not selected')
	assert(case, 'Test method is not selected')

	self._test_cases[name] = case
end

---@private
---@return nil
function test_runner:test()
	for name, case in pairs(self._test_cases) do
		assert(name, 'name is empty')
		assert(case, 'case is set to nil')

		local status, error = pcall(case)

		print("[" .. name .. "]")
		if not status then
			self._is_errors = true
			print("FAILED : " .. error .. "\n")
		else
			print("PASSED" .. "\n")
		end
	end
end

---@public
---@return nil
function test_runner:evaluate()
	self:test()
	if self._is_errors == true then
		print("errors found")
	else
		print("errors not found")
	end
end

return test_runner
