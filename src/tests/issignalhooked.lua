local reportResult, failureMap, failureFlag, environment = ...

return function()
	local event = environment.Instance.new("BindableEvent")
	local untouched = environment.Instance.new("BindableEvent")
	local connection
	local ok, err = environment.pcall(function()
		if environment.type(environment.hooksignal) ~= "function" then
			environment.error("'hooksignal' is needed to create a controlled signal hook", 0)
		end
		if environment.issignalhooked(event.Event) ~= false then
			environment.error("Did not return false for an unhooked signal", 0)
		end
		local called = false
		connection = event.Event:Connect(function() end)
		environment.hooksignal(event.Event, function(info, ...)
			called = true
			return true
		end)
		event:Fire()
		local deadline = environment.os.clock() + 2
		repeat
			environment.task.wait()
		until called or environment.os.clock() >= deadline
		if not called then
			environment.error("'hooksignal' did not install the probe hook; cannot verify signal hook state", 0)
		end
		if environment.issignalhooked(event.Event) ~= true then
			environment.error("Did not return true for a hooked signal", 0)
		end
		if environment.issignalhooked(untouched.Event) ~= false then
			environment.error("Reported an unrelated signal as hooked", 0)
		end
	end)
	if connection then
		connection:Disconnect()
	end
	event:Destroy()
	untouched:Destroy()
	if not ok then
		reportResult(false, "issignalhooked", environment.tostring(err))
		if failureMap.issignalhooked then
			failureFlag[1] = true
		end
	end
end
