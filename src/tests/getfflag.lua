local reportResult, failureMap, failureFlag, environment = ...

return function()
	local ok, err = environment.pcall(function()
		local found = false
		for _, name in environment.ipairs({ "DebugDisplayFPS", "TaskSchedulerTargetFps", "DebugGraphicsPreferVulkan" }) do
			local readable, value = environment.pcall(environment.getfflag, name)
			if readable and value ~= nil then
				local valueType = environment.type(value)
				if valueType ~= "string" and valueType ~= "boolean" and valueType ~= "number" then
					environment.error("Expected a string, boolean, or number for '" .. name .. "', got " .. valueType, 0)
				end
				if environment.getfflag(name) ~= value then
					environment.error("Returned inconsistent values for the unchanged flag '" .. name .. "'", 0)
				end
				found = true
				break
			end
		end
		if not found then
			environment.error("Could not read any known FastFlag on this client build", 0)
		end
		local readable, value = environment.pcall(environment.getfflag, "sUNC_NonexistentFlag_" .. environment.game:GetService("HttpService"):GenerateGUID(false))
		if readable and value ~= nil then
			environment.error("Returned a value for a nonexistent FastFlag: " .. environment.tostring(value), 0)
		end
	end)
	if not ok then
		reportResult(false, "getfflag", environment.tostring(err))
		if failureMap.getfflag then
			failureFlag[1] = true
		end
	end
end
