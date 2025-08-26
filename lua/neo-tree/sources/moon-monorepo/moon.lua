local M = {}
local moon_state = require("neo-tree.sources.moon-monorepo.moon_state")

local function basename(path)
	return path:match("^.+/(.+)$")
end

local function run_command_in_new_buffer(command)
	-- Create a new terminal window at the bottom
	vim.cmd('botright split')
	vim.cmd('resize 15')
	vim.cmd('terminal ' .. command)
end

function dir_exists(path)
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

		local key = p.config.id
		if key == vim.NIL then
			key = basename(p.root)
		end

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

		-- Group by tags
		if p.config.tags and #p.config.tags > 0 then
			for _, tag in ipairs(p.config.tags) do
				if not tags[tag] then
					tags[tag] = {}
				end
				table.insert(tags[tag], project_data)
			end
		else
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
