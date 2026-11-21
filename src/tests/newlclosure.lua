local reportResult, failureMap, failureFlag, environment = ...

return function()
	local ok, err = environment.pcall(function()
		if environment.type(environment.islclosure) ~= "function" then
			environment.error("'islclosure' is needed to verify the returned closure", 0)
		end
		local function target(...)
			return environment.select("#", ...), ...
		end
		local closure = environment.newlclosure(target)
		if environment.type(closure) ~= "function" or environment.islclosure(closure) ~= true then
			environment.error("Did not return a Lua closure for a Lua function", 0)
		end
		local count, first, second, third = closure("sUNC", nil, false)
		if count ~= 3 or first ~= "sUNC" or second ~= nil or third ~= false then
			environment.error("The Lua closure did not preserve arguments, nils, and return values", 0)
		end
		local wrappedC = environment.newlclosure(environment.math.abs)
		if environment.type(wrappedC) ~= "function" or environment.islclosure(wrappedC) ~= true or wrappedC(-7) ~= 7 then
			environment.error("Did not wrap a C function in a working Lua closure", 0)
		end
		if environment.pcall(environment.newlclosure, {}) then
			environment.error("Accepted a non-function argument", 0)
		end
	end)
	if not ok then
		reportResult(false, "newlclosure", environment.tostring(err))
		if failureMap.newlclosure then
			failureFlag[1] = true
		end
	end
end
