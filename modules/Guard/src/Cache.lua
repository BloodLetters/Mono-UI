local Cache = {}

function Cache.getCacheFilename(configName)
	return "guard_key_" .. tostring(configName) .. ".txt"
end

function Cache.loadCachedKey(configName)
	local filename = Cache.getCacheFilename(configName)
	if isfile and isfile(filename) then
		local ok, key = pcall(readfile, filename)
		if ok and key then
			key = key:match("^%s*(.-)%s*$")
			return key
		end
	end
	return nil
end

function Cache.saveCachedKey(configName, key)
	local filename = Cache.getCacheFilename(configName)
	if writefile then
		pcall(writefile, filename, key)
	end
end

return Cache
