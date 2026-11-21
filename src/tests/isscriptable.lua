local failureMap, reportResult, environment = ...

return function()
	local part = environment.Instance.new("Part")
	local untouched = environment.Instance.new("Part")
	local function check(condition, message)
		if not condition then
			environment.error(message, 0)
		end
	end
	local function expectState(expected)
		local deadline = environment.os.clock() + 2
		local state
		repeat
			state = environment.isscriptable(part, "formFactorRaw")
			check(environment.type(state) == "boolean", "Expected boolean scriptability for 'formFactorRaw', got " .. environment.type(state))
			if state == expected then
				return
			end
			environment.task.wait()
		until environment.os.clock() >= deadline
		environment.error("Expected scriptability " .. environment.tostring(expected) .. ", got " .. environment.tostring(state) .. " (timed out)", 0)
	end
	local ok, err = environment.pcall(function()
		check(environment.isscriptable(part, "Name") == true, "Returned a non-true value for the scriptable property 'Name'")
		local missing = environment.isscriptable(part, "siz")
		check(missing == nil or missing == false, "Returned " .. environment.tostring(missing) .. " for the nonexistent property 'siz'")
		expectState(false)
		if not failureMap.setscriptable or environment.type(environment.setscriptable) ~= "function" then
			environment.error("Cannot verify scriptability changes because 'setscriptable' is not working reliably", 0)
		end
		environment.setscriptable(part, "formFactorRaw", true)
		expectState(true)
		check(environment.isscriptable(untouched, "formFactorRaw") == false, "Reported a scriptability change on an unrelated Part")
		environment.setscriptable(part, "formFactorRaw", false)
		expectState(false)
	end)
	if environment.type(environment.setscriptable) == "function" then
		environment.pcall(environment.setscriptable, part, "formFactorRaw", false)
	end
	part:Destroy()
	untouched:Destroy()
	if not ok then
		reportResult(false, "isscriptable", environment.tostring(err))
	end
end
