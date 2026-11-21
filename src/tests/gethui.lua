local failedTests, reportResult, environment = ...

return function()
	if failedTests.setthreadidentity or not environment.setthreadidentity then
		reportResult(false, "gethui", "setthreadidentity is needed in order to test")
		return
	end
	local frame, connection
	local ok, err = environment.pcall(function()
		local hui = environment.gethui()
		if environment.typeof(hui) ~= "Instance" then
			environment.error("Expected a hidden UI Instance, got " .. environment.typeof(hui), 0)
		end
		if environment.gethui() ~= hui then
			environment.error("Returned different hidden UI containers on consecutive calls", 0)
		end
		local coreGui = environment.game:GetService("CoreGui")
		if hui == coreGui or hui:IsDescendantOf(coreGui) then
			environment.error("The hidden UI container is exposed in the CoreGui hierarchy", 0)
		end
		frame = environment.Instance.new("Frame")
		frame.Name = "sUNC_gethui_probe"
		connection = coreGui.DescendantAdded:Connect(function(descendant)
			if descendant == frame or descendant.Name == frame.Name then
				reportResult(false, "gethui", "Hidden UI probe was exposed through CoreGui.DescendantAdded: " .. descendant.Name .. " (" .. descendant.ClassName .. ")")
			end
		end)
		frame.Parent = hui
		environment.task.wait()
		if frame.Parent ~= hui then
			environment.error("The probe could not remain parented to the hidden UI container", 0)
		end
		if frame:IsDescendantOf(coreGui) then
			environment.error("UI parented to gethui() is visible as a CoreGui descendant", 0)
		end
	end)
	if connection then
		connection:Disconnect()
	end
	if frame then
		frame:Destroy()
	end
	if not ok then
		reportResult(false, "gethui", environment.tostring(err))
	end
end
