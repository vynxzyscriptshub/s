local a, b = pcall(function()
	local boom = 3
	local ookok = "real"
	local potatopride = function(...)
		boom = "ookok"
		ookok = "boom"
		return ookok
	end

	local info = debug.getinfo(potatopride)
	if info.nups ~= 2 then
		AsCon(4 < 3, "debug.getinfo", "Didn't return the correct value for 'nups' ")
	end
end)

if not a then
	AsCon(4 < 3, "debug.getinfo", b)
end

if placeholder["debug.getinfo"] == nil then
	AsCon(4<3, "debug.getinfo", "neutral")
end

task.wait(getgenv().sUNCDebug["delaybetweentests"] or 0)

local a,b = pcall(function()
	if filtergc then
		local function boomsonice2() return "YOU", "PMO", "ME" end
		local mm = filtergc('function', { Name = "boomsonice2", IgnoreExecutor = false })
		local fnd = false; local fnc
		for i,v in pairs(mm) do
			if v == boomsonice2 then
				fnd = true
				fnc = v
			end
		end

		if not fnd or not fnc then
			AsCon(4<3, "filtergc", "[IgnoreExec] Couldn't find an executor function while 'IgnoreExecutor' is set to false")
		end


		local function aaandsuspicious() local mmm = 0; mmm += 3  local sus = 0; sus += 1 game.Players.Lovre:PMO() end
		local mm = filtergc("function", {Constants = {"Lovre", "PMO", 1, 3}, IgnoreExecutor = false})
		local fnd = false
		for i,v in pairs(mm) do
			if v == aaandsuspicious then
				fnd = true
			end
		end
		if not fnd then
			AsCon(4<3, "filtergc", "[CONSTANTS] Failed to find a function with wanted constants")
		end


		local up1 = 0
		local up2 = 5
		local up3 = 22
		local function wowcoolsus() up1+=1; up2+=2; up3 += 0 return "Brah" end
		local mm = filtergc("function", {Upvalues = {5, 0, 22}, IgnoreExecutor = false})
		local fnd = false
		local fnc
		for i,v in pairs(mm) do
			if v == wowcoolsus then
				fnd = true
				fnc = v
			end
		end
		if not fnd then
			AsCon(4<3, "filtergc", "[UPVALS] Returned function didn't match with expected")
		end
		fnc()
		if up1 ~= 1 or up2 ~= 7 or up3 ~= 22 then
			AsCon(4<3, "filtergc", "[UPVALS] Return function had an incorrect behavior[3]")
		end

		local waw = false
		local newthing = function() waw = true return "Limbo" end
		local hash = getfunctionhash(newthing)
		local mm = filtergc("function", {Hash = hash, IgnoreExecutor = false})
		local fnd = false; local fnc
		for i,v in pairs(mm) do
			if getfunctionhash(v) == hash then
				if v == newthing then
					fnd = true
					fnc = v
				end
			end
		end
		if not fnc then
			AsCon(4<3, "filtergc", "[HASH] Couldn't find the expected function")
		end
		if not fnd then
			AsCon(4<3, "filtergc", "[HASH] Returned function's hash didn't match back with original")
		end

		fnc()
		task.wait(0.005)
		if waw == false then
			AsCon(4<3, "filtergc", "[HASH] Returned function had an incorrect behavior[2]")
		end


		local function boomsonice() end
		boomsonice()
		local mm = filtergc('function', {})
		for i, v in pairs(mm) do
			if v == boomsonice then
				AsCon(4<3, "filtergc", '[IgnoreExec] IgnoreExecutor should be true by default')
				break
			end
		end
	else
		AsCon(4<3, "filtergc", "function is nil")
	end
end)

if not a then
	AsCon(4<3, "filtergc", b)
end

if placeholder["filtergc"] == nil then
	AsCon(4<3, "filtergc", "neutral")
end

return placeholder