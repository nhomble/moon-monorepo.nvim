local highlights = require("neo-tree.ui.highlights")
local common = require("neo-tree.sources.common.components")
local config = require("neo-tree.sources.moon-monorepo.config")

local M = {}

M.task = function(component_config, node, state)
	local text = node.extra.custom_text or ""
	local highlight = highlights.DIM_TEXT
	return {
		text = text,
		highlight = highlight,
	}
end

M.icon = function(component_config, node, state)
	local icons = config.options.icons
	local icon = " "
	local padding = component_config.padding or " "
	local highlight = component_config.highlight or highlights.FILE_ICON
	if node.type == "directory" then
		highlight = highlights.DIRECTORY_ICON
		if node:is_expanded() then
			icon = icons.folder_open
		else
			icon = icons.folder_closed
		end
	elseif node.type == "task" then
		icon = icons.task
		highlight = highlights.TASK_ICON
	elseif node.type == "file" then
		local success, web_devicons = pcall(require, "nvim-web-devicons")
		if success then
			local devicon, hl = web_devicons.get_icon(node.name, node.ext)
			icon = devicon or icon
			highlight = hl or highlight
		end
	end
	return {
		text = icon .. padding,
		highlight = highlight,
	}
end

M.name = function(component_config, node, state)
	local highlight = component_config.highlight or highlights.FILE_NAME
	if node.type == "directory" then
		highlight = highlights.DIRECTORY_NAME
	end
	if node:get_depth() == 1 then
		highlight = highlights.ROOT_NAME
	end
	return {
		text = node.name,
		highlight = highlight,
	}
end

return vim.tbl_deep_extend("force", common, M)
