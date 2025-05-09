-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.winbar = "%=%m %f"
vim.g.lazyvim_picker = "telescope"
vim.opt.wrap = true
vim.g.autoformat = false

-- Change ident space/tab
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.softtabstop = 4

-- Change backspace to normal behavior
vim.opt.backspace = {'indent', 'eol', 'start'}
