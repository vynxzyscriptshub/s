local reportResult, failureMap, failureFlag, environment = ...

local function fail(message)
	reportResult(false, "sethiddenproperty", message)
	if failureMap.sethiddenproperty then
		failureFlag[1] = true
	end
end

return function()
	local fire = environment.Instance.new("Fire")
	local original
	local ok, err = environment.pcall(function()
		if not failureMap.gethiddenproperty or environment.type(environment.gethiddenproperty) ~= "function" then
			environment.error("Cannot verify writes because 'gethiddenproperty' is not working reliably", 0)
		end
		original = environment.gethiddenproperty(fire, "size_xml")
		if environment.type(original) ~= "number" then
			environment.error("Expected a numeric 'size_xml' value, got " .. environment.type(original), 0)
		end
		local visibleMatches = fire.Size == original
		local probe = original == 7.25 and 3.5 or 7.25
		environment.sethiddenproperty(fire, "size_xml", probe)
		local deadline = environment.os.clock() + 2
		local actual
		repeat
			actual = environment.gethiddenproperty(fire, "size_xml")
			if actual == probe then
				break
			end
			environment.task.wait()
		until environment.os.clock() >= deadline
		if actual ~= probe then
			environment.error("Expected 'size_xml' to be " .. probe .. ", got " .. environment.tostring(actual), 0)
		end
		if visibleMatches and fire.Size ~= probe then
			environment.error("Fire.Size did not reflect the hidden write: expected " .. probe .. ", got " .. environment.tostring(fire.Size), 0)
		end
		environment.sethiddenproperty(fire, "size_xml", original)
		local restored = environment.gethiddenproperty(fire, "size_xml")
		if restored ~= original then
			environment.error("Failed to restore 'size_xml': expected " .. original .. ", got " .. environment.tostring(restored), 0)
		end
	end)
	if original ~= nil then
		environment.pcall(environment.sethiddenproperty, fire, "size_xml", original)
	end
	fire:Destroy()
	if not ok then
		fail(environment.tostring(err))
	end
end
