local reportResult, failureMap, failureFlag, environment = ...

return function()
	local ok, err = environment.pcall(function()
		if environment.type(environment.debug.getinfo) ~= "function" then
			environment.error("'debug.getinfo' is needed to verify debug metadata changes", 0)
		end
		local function target()
			return "sUNC_debug_setinfo"
		end
		local metadata = {
			source = "@sUNC_setinfo_probe.lua",
			short_src = "sUNC_setinfo_probe.lua",
			name = "sUNC_setinfo_probe",
			currentline = 123,
		}
		environment.debug.setinfo(target, metadata)
		local info = environment.debug.getinfo(target)
		if environment.type(info) ~= "table" then
			environment.error("debug.getinfo did not return a metadata table after the update", 0)
		end
		for field, expected in environment.pairs(metadata) do
			if info[field] ~= expected then
				environment.error("Expected '" .. field .. "' to be " .. environment.tostring(expected) .. ", got " .. environment.tostring(info[field]), 0)
			end
		end
		if target() ~= "sUNC_debug_setinfo" then
			environment.error("Updating debug metadata changed the function's behavior", 0)
		end
		if environment.pcall(environment.debug.setinfo, environment.math.abs, metadata) then
			environment.error("Accepted a C closure instead of rejecting unsupported metadata changes", 0)
		end
	end)
	if not ok then
		reportResult(false, "debug.setinfo", environment.tostring(err))
		if failureMap["debug.setinfo"] then
			failureFlag[1] = true
		end
	end
end
