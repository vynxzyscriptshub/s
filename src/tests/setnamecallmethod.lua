local reportResult, failureMap, failureFlag, environment = ...

return function()
	local target = environment.Instance.new("Folder")
	target.Name = "sUNC_setnamecallmethod_probe"
	local metatable, originalNamecall, readonly, installed
	local reached, redirected = false, false
	local ok, err = environment.pcall(function()
		if environment.type(environment.getrawmetatable) ~= "function" or environment.type(environment.setreadonly) ~= "function" or environment.type(environment.getnamecallmethod) ~= "function" then
			environment.error("'getrawmetatable', 'setreadonly', and 'getnamecallmethod' are needed to test", 0)
		end
		metatable = environment.getrawmetatable(target)
		originalNamecall = metatable.__namecall
		readonly = true
		if environment.type(environment.isreadonly) == "function" then
			readonly = environment.isreadonly(metatable)
		end
		environment.setreadonly(metatable, false)
		metatable.__namecall = function(self, ...)
			if self == target and environment.getnamecallmethod() == "GetChildren" then
				reached = true
				environment.setnamecallmethod("GetFullName")
				redirected = environment.getnamecallmethod() == "GetFullName"
			end
			return originalNamecall(self, ...)
		end
		installed = true
		local result = target:GetChildren()
		if not reached or not redirected then
			environment.error("Did not change the active namecall method from GetChildren to GetFullName", 0)
		end
		if result ~= target.Name then
			environment.error("The namecall still invoked the original method after redirection (got " .. environment.tostring(result) .. ")", 0)
		end
	end)
	local restored, restoreError = environment.pcall(function()
		if metatable then
			environment.setreadonly(metatable, false)
			if installed then
				metatable.__namecall = originalNamecall
			end
			environment.setreadonly(metatable, readonly)
		end
	end)
	target:Destroy()
	if not ok or not restored then
		reportResult(false, "setnamecallmethod", environment.tostring(not ok and err or restoreError))
		if failureMap.setnamecallmethod then
			failureFlag[1] = true
		end
	end
end
