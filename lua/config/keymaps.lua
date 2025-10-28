-- return {
--   {
--     "williamboman/mason.nvim",
--     opts = {
--       registries = {
--         "github:mason-org/mason-registry",
--         "github:Crashdummyy/mason-registry",
--       },
--       ensure_installed = {
--         "roslyn",
--         "rzls",
--       },
--     },
--   },
-- }
function FormatModifiedLines()
  local bufnr = vim.api.nvim_get_current_buf()
  local ok, gitsigns = pcall(require, "gitsigns")
  local ih_ok, inlay_hint = pcall(vim.lsp.inlay_hint, bufnr, nil)

  -- disable inlay hints temporarily (Neovim 0.11+)
  if ih_ok then
    pcall(vim.lsp.inlay_hint.enable, false, { bufnr = bufnr })
  end

  if not ok or not gitsigns.get_hunks then
    vim.lsp.buf.format({ async = true })
  else
    local hunks = gitsigns.get_hunks()
    if not hunks or vim.tbl_isempty(hunks) then
      vim.lsp.buf.format({ async = true })
    else
      for _, hunk in ipairs(hunks) do
        vim.lsp.buf.format({
          async = true,
          range = {
            ["start"] = { hunk.added.start - 1, 0 },
            ["end"] = { hunk.added.start + hunk.added.count - 1, 0 },
          },
        })
      end
    end
  end

  -- re-enable inlay hints after formatting
  if ih_ok then
    vim.defer_fn(function()
      pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
    end, 100)
  end
end

-- Optional keymap to trigger it
vim.keymap.set("n", "<leader>fm", FormatModifiedLines, { desc = "Format modified lines only" })
