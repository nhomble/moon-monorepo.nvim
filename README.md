# moon-monorepo (plugin)

neovim tooling for [moon](https://moonrepo.dev/moon) via [neo-tree](https://github.com/nvim-neo-tree/neo-tree.nvim) sources

## Installation

[lazy](https://github.com/folke/lazy.nvim)

```lua
{
	"nhomble/moon-monorepo.nvim",
	dependencies = {
		"nvim-neo-tree/neo-tree.nvim",
		opts = function(_, opts)
			local moon = require("neo-tree.sources.moon-monorepo")
			table.insert(opts.sources, moon.name)

			if moon.is_supported() then
				table.insert(opts.source_selector.sources, {
					display_name = moon.display_name,
					source = moon.name,
				})
			end
		end,
	},
}
```
