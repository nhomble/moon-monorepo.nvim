local cc = require("neo-tree.sources.common.commands")
local moon = require("neo-tree.sources.moon-monorepo.moon")
local constants = require("neo-tree.sources.moon-monorepo.constants")
local manager = require("neo-tree.sources.manager")

local M = {}

-- if you <cr> on a task, then run it
-- otherwise default behavior
M.open = function(state, toggle_directory)
	local tree = state.tree
	local node = tree:get_node()
	if node.type == "task" then
		moon.run(node.extra.moon_cmd)
	else
		cc.open(state, toggle_directory)
	end
end

M.refresh = function(state)
	manager.refresh(constants.source_name, state)
end

M.show_debug_info = function(state)
	print(vim.inspect(state))
end

cc._add_common_commands(M)
return M
