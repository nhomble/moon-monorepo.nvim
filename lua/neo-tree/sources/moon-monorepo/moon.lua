local M = {}

local function basename(path)
	return path:match("^.+/(.+)$")
end

local function run_command_in_new_buffer(command)
	-- Create a new buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
		command,
		"",
		"================",
	})
	vim.api.nvim_open_win(buf, true, { relative = "editor", width = 80, height = 20, row = 10, col = 10 })

	-- Start a job to run the command
	vim.fn.jobstart(command, {
		on_stdout = function(_, data, _)
			-- Append stdout to the buffer
			if data then
				vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
			end
		end,
		on_stderr = function(_, data, _)
			-- Handle stderr if needed
			if data then
				vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "Error: " .. table.concat(data, "\n") })
			end
		end,
		on_exit = function(_, exit_code, _)
			if exit_code ~= 0 then
				vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "Command failed with exit code " .. exit_code })
			end
		end,
		stdout_buffered = true,
	})
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
	local project = cmd(" moon query projects --json")
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
