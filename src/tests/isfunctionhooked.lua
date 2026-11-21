local reportResult, failureMap, failureFlag, environment = ...

return function()
	local original
	local function target()
		return "original"
	end
	local function untouched()
		return "untouched"
	end
	local function replacement()
		return "hooked"
	end
	local ok, err = environment.pcall(function()
		if environment.type(environment.hookfunction) ~= "function" then
			environment.error("'hookfunction' is needed to create a controlled hook", 0)
		end
		if environment.isfunctionhooked(target) ~= false then
			environment.error("Did not return false for an unhooked function", 0)
		end
		original = environment.hookfunction(target, replacement)
		if target() ~= "hooked" then
			environment.error("'hookfunction' did not install the probe hook; cannot verify hook state", 0)
		end
		if environment.isfunctionhooked(target) ~= true then
			environment.error("Did not return true for a hooked function", 0)
		end
		if environment.isfunctionhooked(untouched) ~= false then
			environment.error("Reported an unrelated function as hooked", 0)
		end
		if failureMap.restorefunction and environment.type(environment.restorefunction) == "function" then
			environment.restorefunction(target)
			if environment.isfunctionhooked(target) ~= false or target() ~= "original" then
				environment.error("Did not report a restored function as unhooked", 0)
			end
			original = nil
		end
	end)
	if original then
		if environment.type(environment.restorefunction) == "function" then
			environment.pcall(environment.restorefunction, target)
		else
			environment.pcall(environment.hookfunction, target, original)
		end
	end
	if not ok then
		reportResult(false, "isfunctionhooked", environment.tostring(err))
		if failureMap.isfunctionhooked then
			failureFlag[1] = true
		end
	end
end
