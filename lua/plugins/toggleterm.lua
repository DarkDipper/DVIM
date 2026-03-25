return {
  "akinsho/toggleterm.nvim",
  config = function()
    require("toggleterm").setup({
      open_mapping = [[<c-\>]],
      shade_terminals = false,
      -- add --login so ~/.zprofile is loaded
      -- https://vi.stackexchange.com/questions/16019/neovim-terminal-not-reading-bash-profile/16021#16021
      -- shell = "bash --login",
    })
  end,
  keys = {
    { [[<C-\>]] },
    { "<leader>0", "<Cmd>2ToggleTerm<Cr>", desc = "Terminal #2" },
  },
}
