local highlights = require("neo-tree.ui.highlights")
local common = require("neo-tree.sources.common.components")

local M = {}

M.task = function(config, node, state)
	local text = node.extra.custom_text or ""
	local highlight = highlights.DIM_TEXT
	return {
		text = text .. "nicolas",
		highlight = highlight,
	}
end

M.icon = function(config, node, state)
	local icon = config.default or " "
	local padding = config.padding or " "
	local highlight = config.highlight or highlights.FILE_ICON
	if node.type == "directory" then
		highlight = highlights.DIRECTORY_ICON
		if node:is_expanded() then
			icon = config.folder_open or "-"
		else
			icon = config.folder_closed or "+"
		end
	else
		if node.type == "task" then
			icon = [[⚙️"]]
			highlight = highlights.TASK_ICON
		end
	end
	return {
		text = icon .. padding,
		highlight = highlight,
	}
end

M.name = function(config, node, state)
	local highlight = config.highlight or highlights.FILE_NAME
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
