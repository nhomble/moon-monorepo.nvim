local M = {}

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

function cmd(command)
	local handle = io.popen(command)
	local result = handle:read("*a")
	handle:close()
	return result
end

M.is_moon_monorepo = function()
	return dir_exists(".moon")
end

M.get_project_tasks = function()
	local project = cmd("FORCE_COLOR=1 moon query projects --json")
	local project_info = vim.fn.json_decode(project)
	local ret = {}
	for _, p in ipairs(project_info.projects) do
		local tasks = {}
		for t, _ in pairs(p.tasks) do
			table.insert(tasks, t)
		end

		local key = p.config.id
		if key == vim.NIL then
			key = basename(p.root)
		end
		
		ret[key] = {
			tasks = tasks,
			root = p.root,
			alias = p.alias,
			source = p.source,
			config = {
				id = p.config.id
			}
		}
	end

	return ret
end

M.run = function(moonArgs)
	run_command_in_new_buffer("moon " .. moonArgs)
end

return M
