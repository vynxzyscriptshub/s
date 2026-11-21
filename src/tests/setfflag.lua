local reportResult, failureMap, failureFlag, environment = ...

return function()
	local flagName, original
	local function encode(value)
		return environment.tostring(value)
	end
	local ok, err = environment.pcall(function()
		if not failureMap.getfflag or environment.type(environment.getfflag) ~= "function" then
			environment.error("Cannot verify writes because 'getfflag' is not working reliably", 0)
		end
		-- Only use display/FPS flags, and restore before yielding to the game.
		for _, name in environment.ipairs({ "DebugDisplayFPS", "TaskSchedulerTargetFps" }) do
			local readable, value = environment.pcall(environment.getfflag, name)
			if readable and value ~= nil then
				local text = environment.string.lower(encode(value))
				if text == "true" or text == "false" or environment.tonumber(value) ~= nil then
					flagName, original = name, value
					break
				end
			end
		end
		if not flagName then
			environment.error("No readable display/FPS FastFlag is available for a reversible write test", 0)
		end
		local text = environment.string.lower(encode(original))
		local probe
		if text == "true" or text == "false" then
			probe = text == "true" and "false" or "true"
		else
			probe = environment.tonumber(original) == 61 and "62" or "61"
		end
		environment.setfflag(flagName, probe)
		local actual = environment.getfflag(flagName)
		if environment.string.lower(encode(actual)) ~= probe then
			environment.error("Expected '" .. flagName .. "' to be " .. probe .. ", got " .. encode(actual), 0)
		end
	end)
	local restored, restoreError = true, nil
	if flagName then
		restored, restoreError = environment.pcall(function()
			environment.setfflag(flagName, encode(original))
			local actual = environment.getfflag(flagName)
			if environment.string.lower(encode(actual)) ~= environment.string.lower(encode(original)) then
				environment.error("Could not restore the original value of '" .. flagName .. "'", 0)
			end
		end)
	end
	if not ok or not restored then
		reportResult(false, "setfflag", environment.tostring(not ok and err or restoreError))
		if failureMap.setfflag then
			failureFlag[1] = true
		end
	end
end
