local M = {}

local defaults = {
	icons = {
		tags_header = "",
		projects_header = "",
		task = "",
		folder_open = "",
		folder_closed = "",
	},
}

M.options = vim.deepcopy(defaults)

M.setup = function(opts)
	M.options = vim.tbl_deep_extend("force", defaults, opts or {})
end

return M
