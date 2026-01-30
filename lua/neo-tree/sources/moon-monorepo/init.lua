local renderer = require("neo-tree.ui.renderer")
local moon = require("neo-tree.sources.moon-monorepo.moon")
local constants = require("neo-tree.sources.moon-monorepo.constants")
local config = require("neo-tree.sources.moon-monorepo.config")
local nil_safe = moon.nil_safe

local M = {
	name = constants.source_name,
	display_name = "☾ moon",
	default_config = require("neo-tree.sources.moon-monorepo.defaults"),
}

M.is_supported = function()
	return moon.is_moon_monorepo()
end

M.navigate = function(state, path)
	if path == nil then
		path = vim.fn.getcwd()
	end
	state.path = path

	-- Get both project tasks and tag organization
	local projectTasks = moon.get_project_tasks()
	local tagData = moon.get_projects_by_tags()

	local items = {}

	-- Add Tags section if there are any tagged projects
	if tagData and tagData.tags and next(tagData.tags) ~= nil then
		local tagItems = {}

		for tagName, projects in pairs(tagData.tags) do
			local projectChildren = {}

			for _, project in ipairs(projects) do
				local taskItems = {}

				local project_id = nil_safe(project.id, project.source:match("([^/]+)$"))

				for _, task in ipairs(project.tasks) do
					table.insert(taskItems, {
						id = "tag_" .. tagName .. "_" .. project_id .. ":" .. task,
						name = task,
						type = "task",
						extra = {
							moon_cmd = project_id .. ":" .. task,
						},
					})
				end

				local display_name = nil_safe(project.alias, project_id)

				table.insert(projectChildren, {
					id = "tag_" .. tagName .. "_" .. project_id,
					name = display_name,
					type = "directory",
					children = taskItems,
					extra = {
						root = project.root,
					},
				})
			end

			table.insert(tagItems, {
				id = "tag_" .. tagName,
				name = tagName,
				type = "directory",
				children = projectChildren,
			})
		end

		table.insert(items, {
			id = "by_tags",
			name = config.options.icons.tags_header .. " Tags",
			type = "directory",
			children = tagItems,
		})
	end

	-- Add Projects section
	local projectItems = {}
	for project, data in pairs(projectTasks) do
		local taskItems = {}
		for _, t in ipairs(data.tasks) do
			table.insert(taskItems, {
				id = project .. ":" .. t,
				name = t,
				type = "task",
				extra = {
					moon_cmd = project .. ":" .. t,
				},
			})
		end
		table.insert(taskItems, {
			id = data.root .. "/moon.yml",
			name = "moon.yml",
			type = "file",
		})

		local display_name = nil_safe(data.alias, project)
		table.insert(projectItems, {
			id = project,
			name = display_name,
			type = "directory",
			children = taskItems,
			extra = {
				root = data.root,
			},
		})
	end

	table.insert(items, {
		id = "projects",
		name = config.options.icons.projects_header .. " Projects",
		type = "directory",
		children = projectItems,
	})

	renderer.show_nodes(items, state)
end

M.setup = function(opts, global_config)
	config.setup(opts)
end

return M
