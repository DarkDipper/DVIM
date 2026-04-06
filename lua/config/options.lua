-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.winbar = "%=%m %f"
vim.g.lazyvim_picker = "telescope"
vim.opt.wrap = true
vim.g.autoformat = false
vim.opt.exrc = true
vim.opt.secure = true

-- Change ident space/tab
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.softtabstop = 2
vim.o.autoindent = true
vim.lsp.config("cssls", {
    capabilities = capabilities,
})
--- filetype
vim.filetype.add({
  extension = {
    cshtml = "razor",
    razor = "razor",
  },
})
vim.opt.clipboard = "unnamed"
-- Change backspace to normal behavior
vim.opt.backspace = { "indent", "eol", "start" }
--
-- -- error/warning
-- vim.diagnostic.config({
--     virtual_text = false
-- })
