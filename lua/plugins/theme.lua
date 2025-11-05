return {
    { "EdenEast/nightfox.nvim" },
    { "oxfist/night-owl.nvim"},
    { "olivercederborg/poimandres.nvim"},
    {
		"craftzdog/solarized-osaka.nvim",
		lazy = true,
		priority = 1000,
		opts = function()
			return {
				transparent = true,
			}
		end,
	},
    -- Configure LazyVim to load theme
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "carbonfox",
        },
    },
}
