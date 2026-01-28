local M = {}

-- Cache for moon query results
local cache = {
	projects_data = nil, -- Raw decoded JSON from moon query projects
	last_refresh = 0,
	refresh_interval = 30000, -- 30 seconds in ms
}

local function cmd(command)
	local handle = io.popen(command .. " 2>&1")
	local result = handle:read("*a")
	handle:close()
	return result
end

local function should_refresh_cache()
	local now = vim.loop.now()
	return cache.last_refresh == 0 or (now - cache.last_refresh) > cache.refresh_interval
end

local function fetch_projects_data()
	local project_result = cmd("moon query projects --json")

	-- Handle empty or error responses
	if not project_result or project_result == "" or project_result:match("Error:") then
		return nil
	end

	local success, projects_data = pcall(vim.fn.json_decode, project_result)
	if not success or not projects_data or not projects_data.projects then
		return nil
	end

	return projects_data
end

local function refresh_cache_async()
	vim.schedule(function()
		local projects_data = fetch_projects_data()
		if projects_data then
			cache.projects_data = projects_data
			cache.last_refresh = vim.loop.now()
		end
	end)
end

local function get_cached_projects_data()
	-- If cache is empty, fetch synchronously
	if not cache.projects_data then
		local projects_data = fetch_projects_data()
		if projects_data then
			cache.projects_data = projects_data
			cache.last_refresh = vim.loop.now()
		else
			-- Set empty fallback
			cache.projects_data = { projects = {} }
			cache.last_refresh = vim.loop.now()
		end
	else
		-- If cache is stale, refresh async
		if should_refresh_cache() then
			refresh_cache_async()
		end
	end

	return cache.projects_data
end

local function invalidate_cache()
	cache.last_refresh = 0
	refresh_cache_async()
end

-- Public API
M.get_projects_data = function()
	return get_cached_projects_data()
end

M.refresh = function()
	invalidate_cache()
end

return M
