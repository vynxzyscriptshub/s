local reportResult, failureMap, failureFlag, environment = ...

return function()
	local event = environment.Instance.new("BindableEvent")
	local connection
	local ok, err = environment.pcall(function()
		local hookCalls, callbackCalls = 0, 0
		local hookArgs, callbackArgs
		local allow = true
		connection = event.Event:Connect(function(...)
			callbackCalls += 1
			callbackArgs = { n = environment.select("#", ...), ... }
		end)
		environment.hooksignal(event.Event, function(info, ...)
			hookCalls += 1
			hookArgs = { n = environment.select("#", ...), ... }
			return allow
		end)
		event:Fire("sUNC", nil, false)
		local deadline = environment.os.clock() + 2
		repeat
			environment.task.wait()
		until (hookCalls > 0 and callbackCalls > 0) or environment.os.clock() >= deadline
		if hookCalls ~= 1 or callbackCalls ~= 1 then
			environment.error("Expected one hook call and one original callback, got " .. hookCalls .. " and " .. callbackCalls, 0)
		end
		for _, args in environment.ipairs({ hookArgs, callbackArgs }) do
			if args.n ~= 3 or args[1] ~= "sUNC" or args[2] ~= nil or args[3] ~= false then
				environment.error("The signal hook did not preserve event arguments and nils", 0)
			end
		end
		allow = false
		event:Fire("blocked")
		deadline = environment.os.clock() + 2
		repeat
			environment.task.wait()
		until hookCalls >= 2 or environment.os.clock() >= deadline
		environment.task.wait(0.1)
		if hookCalls ~= 2 or callbackCalls ~= 1 then
			environment.error("Returning false from the hook did not suppress the original signal callback", 0)
		end
	end)
	if connection then
		connection:Disconnect()
	end
	event:Destroy()
	if not ok then
		reportResult(false, "hooksignal", environment.tostring(err))
		if failureMap.hooksignal then
			failureFlag[1] = true
		end
	end
end
