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

-- Format only modified lines (conform-aware)
local function merge_ranges(ranges)
  if #ranges == 0 then return ranges end
  table.sort(ranges, function(a,b) return a[1] < b[1] end)
  local merged = { ranges[1] }
  for i = 2, #ranges do
    local last = merged[#merged]
    local cur = ranges[i]
    if cur[1] <= last[2] + 1 then
      last[2] = math.max(last[2], cur[2])
    else
      table.insert(merged, cur)
    end
  end
  return merged
end

local function FormatModifiedLines()
  local bufnr = vim.api.nvim_get_current_buf()
  local ok, gitsigns = pcall(require, "gitsigns")

  -- Temporarily disable inlay hints (Neovim 0.11+)
  local ih_ok = type(vim.lsp.inlay_hint) == "function"
  if ih_ok then
    pcall(vim.lsp.inlay_hint.enable, false, { bufnr = bufnr })
  end

  -- detect attached LSP clients that support document range formatting
  local clients = vim.lsp.get_active_clients({ bufnr = bufnr }) or {}
  local supports_range = false
  for _, c in ipairs(clients) do
    local caps = c.server_capabilities or c.resolved_capabilities
    if caps and (caps.documentRangeFormattingProvider or caps.rangeFormattingProvider) then
      supports_range = true
      break
    end
  end

  -- if gitsigns missing -> full-format fallback
  if not ok or not gitsigns.get_hunks then
    vim.lsp.buf.format({ async = true })
  else
    local hunks = gitsigns.get_hunks()
    if not hunks or vim.tbl_isempty(hunks) then
      vim.lsp.buf.format({ async = true })
    else
      local ranges = {}
      for _, h in ipairs(hunks) do
        local start_row, end_row
        if h.added and h.added.start and h.added.count then
          start_row = h.added.start - 1
          end_row = start_row + (h.added.count - 1)
        elseif h.start and h.count then
          start_row = h.start - 1
          end_row = start_row + (h.count - 1)
        end

        if start_row and end_row and end_row >= start_row then
          table.insert(ranges, { start_row, end_row })
        end
      end

      if vim.tbl_isempty(ranges) then
        vim.lsp.buf.format({ async = true })
      else
        local merged = merge_ranges(ranges)

        -- Try to use LSP range formatting if available
        if supports_range then
          for _, r in ipairs(merged) do
            local s, e = r[1], r[2]
            local max_line = vim.api.nvim_buf_line_count(bufnr) - 1
            if e > max_line then e = max_line end
            -- LSP range uses 0-index rows/cols
            vim.lsp.buf.format({
              async = true,
              range = {
                start = { s, 0 },
                ["end"] = { e + 1, 0 },
              },
            })
          end
        else
          -- No LSP range support: use conform if available (conform uses 1-indexed rows)
          local okc, conform = pcall(require, "conform")
          if okc and conform and type(conform.format) == "function" then
            for _, r in ipairs(merged) do
              local s, e = r[1], r[2]
              local max_line = vim.api.nvim_buf_line_count(bufnr) - 1
              if e > max_line then e = max_line end
              -- conform expects 1-indexed rows, and {row, col} tuple
              conform.format({
                bufnr = bufnr,
                async = true,
                range = {
                  start = { s + 1, 0 },       -- +1: convert 0-index -> 1-index
                  ["end"] = { e + 1, 0 },
                },
                -- optional: choose how conform uses LSP. default is "never".
                -- lsp_format = "fallback",
              })
            end
          else
            -- last resort: full document format
            vim.notify("No LSP range support and conform not available; doing full document format", vim.log.levels.WARN)
            vim.lsp.buf.format({ async = true })
          end
        end
      end
    end
  end

  -- re-enable inlay hints after a small delay
  if ih_ok then
    vim.defer_fn(function()
      pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
    end, 100)
  end
end

-- Optional keymap to trigger it
vim.keymap.set("n", "<leader>fm", FormatModifiedLines, { desc = "Format modified lines only" })
vim.keymap.set("n", "<C-D>", "<C-D>zz", { noremap = true, silent = true} )
vim.keymap.set("n", "<C-U>", "<C-U>zz", { noremap = true, silent = true} )
vim.keymap.set("n", "<leader>i", "cit<CR><Esc>O<C-f>", { noremap = true, silent = true, desc = "For enter downline and indent html"} )
