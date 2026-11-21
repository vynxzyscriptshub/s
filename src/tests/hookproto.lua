local reportResult, failureMap, failureFlag, environment = ...

return function()
	local ok, err = environment.pcall(function()
		if environment.type(environment.debug.getproto) ~= "function" then
			environment.error("'debug.getproto' is needed to obtain a prototype", 0)
		end
		local function parent()
			local function child()
				return "original_proto"
			end
			return child
		end
		local before = parent()
		if before() ~= "original_proto" then
			environment.error("The prototype fixture did not return its original value", 0)
		end
		local proto = environment.debug.getproto(parent, 1)
		local function replacement()
			return "hooked_proto"
		end
		-- Executors expose either a prototype handle or a parent/index overload.
		local hooked, hookError = environment.pcall(environment.hookproto, proto, replacement)
		if not hooked then
			hooked, hookError = environment.pcall(environment.hookproto, parent, 1, replacement)
		end
		if not hooked then
			environment.error("Could not hook the child prototype: " .. environment.tostring(hookError), 0)
		end
		local after = parent()
		if environment.type(after) ~= "function" or after() ~= "hooked_proto" then
			environment.error("A newly instantiated child did not execute the prototype hook", 0)
		end
		if parent()() ~= "hooked_proto" then
			environment.error("The prototype hook did not persist for subsequent child closures", 0)
		end
	end)
	if not ok then
		reportResult(false, "hookproto", environment.tostring(err))
		if failureMap.hookproto then
			failureFlag[1] = true
		end
	end
end
