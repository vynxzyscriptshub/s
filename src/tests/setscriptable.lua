local reportResult, checkpointLogger, environment = ...

return function()
	local part = environment.Instance.new("Part")
	local untouched = environment.Instance.new("Part")
	local function check(condition, message)
		if not condition then
			environment.error(message, 0)
		end
	end
	local function waitForAccess(expected)
		local deadline = environment.os.clock() + 2
		repeat
			local readable, value = environment.pcall(function()
				return part.formFactorRaw
			end)
			if readable == expected then
				return true, value
			end
			environment.task.wait()
		until environment.os.clock() >= deadline
		return false
	end
	local ok, err = environment.pcall(function()
		-- A nonexistent property must never become indexable.
		environment.pcall(environment.setscriptable, part, "siz", true)
		check(not environment.pcall(function()
			return part.siz
		end), "Made the nonexistent property 'siz' accessible")

		environment.setscriptable(part, "formFactorRaw", false)
		check(waitForAccess(false), "'formFactorRaw' remained accessible after setting scriptable to false")
		local previous = environment.setscriptable(part, "formFactorRaw", true)
		check(previous == false, "Expected the previous scriptability to be false, got " .. environment.tostring(previous))
		local readable, value = waitForAccess(true)
		check(readable, "Could not index 'formFactorRaw' after setting scriptable to true (timed out)")
		check(value == environment.Enum.FormFactor.Brick, "Unexpected 'formFactorRaw' value: " .. environment.tostring(value))
		check(not environment.pcall(function()
			return untouched.formFactorRaw
		end), "Changed scriptability on an unrelated Part")

		previous = environment.setscriptable(part, "formFactorRaw", false)
		check(previous == true, "Expected the previous scriptability to be true, got " .. environment.tostring(previous))
		check(waitForAccess(false), "Could still index 'formFactorRaw' after restoring scriptability to false")
	end)
	environment.pcall(environment.setscriptable, part, "formFactorRaw", false)
	part:Destroy()
	untouched:Destroy()
	if not ok then
		checkpointLogger(err)
		reportResult(false, "setscriptable", environment.tostring(err))
	end
end
