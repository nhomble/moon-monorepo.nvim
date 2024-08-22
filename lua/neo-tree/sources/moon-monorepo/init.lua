local renderer = require("neo-tree.ui.renderer")
local moon = require("neo-tree.sources.moon-monorepo.moon")
local M = {
	name = "moon-monorepo",
	display_name = "🌙 moon",
	default_config = require("neo-tree.sources.moon-monorepo.defaults"),
}

M.is_supported = function()
	return moon.is_moon_monorepo()
end

M.navigate = function(state, path)
	local projectTasks = moon.get_project_tasks()
	local items = {}
	for project, data in pairs(projectTasks) do
		local taskItems = {}
		for _, t in ipairs(data.tasks) do
			table.insert(taskItems, {
				id = project .. ":" .. t,
				name = t,
				type = "task",
				extra = {
					moon_cmd = project .. ":" .. t,
				}
			})
		end
		table.insert(taskItems, {
			id = data.root .. "/moon.yml",
			name = "moon.yml",
			type = "file",
		})

		local display_name = data.alias
		-- TODO not leak vim.NIL
		if display_name == vim.NIL then
			display_name = project
		end
		table.insert(items, {
			id = project,
			name = display_name,
			type = "directory",
			children = taskItems,
			extra = {
				root = data.root,
			},
		})
	end

	renderer.show_nodes(items, state)
end

M.setup = function(config, global_config) end

return M
