local reportResult, failureMap, failureFlag, environment = ...

return function()
	local ok, err = environment.pcall(function()
		if environment.type(environment.debug.getproto) ~= "function" or environment.type(environment.hookproto) ~= "function" then
			environment.error("'debug.getproto' and 'hookproto' are needed to create a controlled prototype hook", 0)
		end
		local function parent()
			local function child()
				return "original_proto"
			end
			return child
		end
		local function untouchedParent()
			local function child()
				return "untouched_proto"
			end
			return child
		end
		parent()
		untouchedParent()
		local proto = environment.debug.getproto(parent, 1)
		local untouched = environment.debug.getproto(untouchedParent, 1)
		local stateOk, state = environment.pcall(environment.isprotohooked, proto)
		local indexed = not stateOk
		if indexed then
			stateOk, state = environment.pcall(environment.isprotohooked, parent, 1)
		end
		if not stateOk or state ~= false then
			environment.error("Expected false for an unhooked prototype, got " .. environment.tostring(state), 0)
		end
		local function replacement()
			return "hooked_proto"
		end
		local hooked, hookError = environment.pcall(environment.hookproto, proto, replacement)
		if not hooked then
			hooked, hookError = environment.pcall(environment.hookproto, parent, 1, replacement)
		end
		if not hooked or parent()() ~= "hooked_proto" then
			environment.error("Could not install the prototype hook; cannot verify its state: " .. environment.tostring(hookError), 0)
		end
		local hookedState, untouchedState
		if indexed then
			hookedState = environment.isprotohooked(parent, 1)
			untouchedState = environment.isprotohooked(untouchedParent, 1)
		else
			hookedState = environment.isprotohooked(proto)
			untouchedState = environment.isprotohooked(untouched)
		end
		if hookedState ~= true then
			environment.error("Did not return true for a hooked prototype", 0)
		end
		if untouchedState ~= false then
			environment.error("Reported an unrelated prototype as hooked", 0)
		end
	end)
	if not ok then
		reportResult(false, "isprotohooked", environment.tostring(err))
		if failureMap.isprotohooked then
			failureFlag[1] = true
		end
	end
end
