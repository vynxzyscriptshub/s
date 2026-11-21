local integrityMarkers, reportResult, failureMap, failureFlag, checkpointLogger, _packResults, _unpackResults, environment =
	...

local function fail(message)
	reportResult(false, "getcallbackvalue", message)
	if failureMap.getcallbackvalue then
		failureFlag[1] = true
	end
end

return function()
	-- The program checks this marker after the test to make sure it actually ran
	integrityMarkers.whytheystoptostare = true

	local gotCallback, invalidCallback = environment.pcall(function()
		return environment.getcallbackvalue("", "OnInvoke")
	end)
	if gotCallback and environment.type(invalidCallback) == "function" then
		reportResult(false, "getcallbackvalue", "Was able to get a callback from an invalid instance")
		if failureMap.getcallbackvalue then
			failureFlag[1] = true
		end
	end

	-- Members that are not callbacks must not crash the executor; errors are ignored
	environment.pcall(function()
		environment.getcallbackvalue(environment.game, "Close")
		environment.getcallbackvalue(environment.game, "IsA")
		environment.getcallbackvalue(environment.game, "GetPropertyChangedSignal")
		environment.getcallbackvalue(environment.game, "\n\n\n\n\n\n\t")
		environment.getcallbackvalue(environment.game, environment.string.rep("0", 0))
		local part = environment.Instance.new("Part")
		environment.pcall(environment.getcallbackvalue, part, "SetPredictionMode")
		part:Destroy()
	end)

	local invoked = false
	local bindable = environment.Instance.new("BindableFunction")
	local function onInvoke()
		invoked = true
	end
	bindable.OnInvoke = onInvoke

	local callbackOk, callback = environment.pcall(environment.getcallbackvalue, bindable, "OnInvoke")
	if not callbackOk then
		fail("Could not retrieve BindableFunction.OnInvoke: " .. environment.tostring(callback))
	elseif callback ~= onInvoke then
		fail("The retrieved OnInvoke callback does not match the assigned callback")
	else
		checkpointLogger(callback)
		callback()
		if not invoked then
			fail("The retrieved OnInvoke callback did not invoke the assigned function")
		end
	end
	bindable:Destroy()

	-- DataModel.OnClose is also a write-only callback, not the Close signal.
	local originalOk, originalOnClose = environment.pcall(environment.getcallbackvalue, environment.game, "OnClose")
	local closeInvoked = false
	local function onClose(...)
		closeInvoked = true
		environment.warn(".")
	end
	local assigned, assignmentError = environment.pcall(function()
		environment.game.OnClose = onClose
	end)
	if not assigned then
		fail("Could not assign game.OnClose for the callback test: " .. environment.tostring(assignmentError))
		return
	end
	local closeOk, closeError = environment.pcall(function()
		local closeCallback = environment.getcallbackvalue(environment.game, "OnClose")
		checkpointLogger(closeCallback)
		if closeCallback ~= onClose then
			environment.error("The retrieved game.OnClose callback does not match the assigned callback (got " .. environment.tostring(closeCallback) .. ")", 0)
		end
		closeCallback()
		if not closeInvoked then
			environment.error("The retrieved game.OnClose callback did not invoke the assigned function", 0)
		end
	end)
	local restored, restoreError = environment.pcall(function()
		if originalOk and (originalOnClose == nil or environment.type(originalOnClose) == "function") then
			environment.game.OnClose = originalOnClose
		else
			environment.game.OnClose = nil
		end
	end)
	if not closeOk then
		fail(environment.tostring(closeError))
	elseif not restored then
		fail("Could not restore game.OnClose after the callback test: " .. environment.tostring(restoreError))
	end
end
