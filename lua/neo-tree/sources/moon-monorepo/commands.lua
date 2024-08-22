local cc = require("neo-tree.sources.common.commands")
local moon = require("neo-tree.sources.moon-monorepo.moon")
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

cc._add_common_commands(M)
return M
