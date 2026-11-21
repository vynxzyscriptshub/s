local reportResult, failureMap, failureFlag, environment = ...

return function()
	local fileName = "sUNC_asset_" .. environment.game:GetService("HttpService"):GenerateGUID(false) .. ".png"
	-- A complete 1x1 PNG, kept inline so the test does not depend on an HTTP download.
	local TestImage = "\137PNG\13\10\26\10\0\0\0\13IHDR\0\0\0\1\0\0\0\1\8\4\0\0\0\181\28\12\2\0\0\0\11IDAT\120\218\99\100\248\15\0\1\5\1\1\39\24\227\102\0\0\0\0IEND\174\66\96\130"
	local ok, err = environment.pcall(function()
		if not failureMap.isfile or not failureMap.delfile then
			environment.error("Cannot verify and clean up the asset because 'isfile' or 'delfile' is not working reliably", 0)
		end
		local assetId = environment.writecustomasset(fileName, TestImage)
		local exists = environment.isfile(fileName)
		if not exists then
			environment.error("The file wasn't written", 0)
		end
		if environment.typeof(assetId) ~= "string" or not environment.string.find(assetId, "^rbxasset://") then
			environment.error("Expected an rbxasset:// id, got '" .. environment.tostring(assetId) .. "'", 0)
		end
		local provider = environment.game:GetService("ContentProvider")
		local fetchStatus
		provider:PreloadAsync({ assetId }, function(_, status)
			fetchStatus = status
		end)
		if fetchStatus == nil then
			fetchStatus = provider:GetAssetFetchStatus(assetId)
		end
		if fetchStatus ~= environment.Enum.AssetFetchStatus.Success then
			environment.error("Expected the asset loading status to be Success, got " .. environment.tostring(fetchStatus), 0)
		end
	end)
	local removed, removeError = true, nil
	if environment.type(environment.delfile) == "function" and environment.type(environment.isfile) == "function" then
		removed, removeError = environment.pcall(function()
			if environment.isfile(fileName) then
				environment.delfile(fileName)
			end
		end)
	end
	if not ok or not removed then
		reportResult(false, "writecustomasset", environment.tostring(not ok and err or removeError))
		if failureMap.writecustomasset then
			failureFlag[1] = true
		end
	end
end
