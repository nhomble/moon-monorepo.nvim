local M = {}
local moon_state = require("neo-tree.sources.moon-monorepo.moon_state")

--- Convert vim.NIL to actual nil (or fallback value)
--- JSON decode returns vim.NIL for null values, which doesn't compare equal to nil
---@param value any
---@param fallback any?
---@return any
local function nil_safe(value, fallback)
	if value == nil or value == vim.NIL then
		return fallback
	end
	return value
end

M.nil_safe = nil_safe

local function basename(path)
	return path:match("^.+/(.+)$")
end

local function run_command_in_new_buffer(command)
	-- Create a new terminal window at the bottom
	vim.cmd('botright split')
	vim.cmd('resize 15')
	vim.cmd('terminal ' .. command)
end

local function dir_exists(path)
	local ok, err, code = os.rename(path, path)
	if not ok then
		if code == 13 then
			-- Permission denied, but it exists
			return true
		end
	end
	return ok, err
end


M.is_moon_monorepo = function()
	return dir_exists(".moon")
end


M.get_project_tasks = function()
	local projects_data = moon_state.get_projects_data()

	local project_tasks = {}
	for _, p in ipairs(projects_data.projects) do
		local tasks = {}
		for t, _ in pairs(p.tasks) do
			table.insert(tasks, t)
		end

		local key = nil_safe(p.config.id, basename(p.root))

		project_tasks[key] = {
			tasks = tasks,
			root = p.root,
			alias = p.alias,
			source = p.source,
			config = {
				id = p.config.id
			}
		}
	end

	return project_tasks
end

M.get_projects_by_tags = function()
	local projects_data = moon_state.get_projects_data()

	local tags = {}
	local untagged = {}

	for _, p in ipairs(projects_data.projects) do
		local project_data = {
			id = p.config.id,
			alias = p.alias,
			root = p.root,
			source = p.source,
			tasks = {}
		}

		-- Extract tasks
		for task_name, _ in pairs(p.tasks) do
			table.insert(project_data.tasks, task_name)
		end

		if p.config.tags and #p.config.tags > 0 then
			project_data.tags = p.config.tags

			for _, tag in ipairs(p.config.tags) do
				if not tags[tag] then
					tags[tag] = {}
					table.insert(tags[tag], project_data)
				else
					-- Check if project is already in this tag group
					local already_added = false
					for _, existing_project in ipairs(tags[tag]) do
						if existing_project == project_data then
							already_added = true
							break
						end
					end
					if not already_added then
						table.insert(tags[tag], project_data)
					end
				end
			end
		else
			project_data.tags = {}
			table.insert(untagged, project_data)
		end
	end

	return {
		tags = tags,
		untagged = untagged
	}
end

M.refresh_cache = function()
	moon_state.refresh()
end

M.run = function(moonArgs)
	run_command_in_new_buffer("moon " .. moonArgs)
end

return M
