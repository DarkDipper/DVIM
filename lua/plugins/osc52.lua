return {
  "ojroques/nvim-osc52",
  config = function()
    local osc52 = require("osc52")

    osc52.setup({
      max_length = 0, -- no limit
      silent = true,
      trim = false,
    })

    -- Copy with leader+y (normal + visual)
    vim.keymap.set("n", "<leader>y", osc52.copy_operator, { desc = "Copy (OSC52)" })
    vim.keymap.set("n", "<leader>yy", function()
      osc52.copy_line()
    end, { desc = "Copy line (OSC52)" })
    vim.keymap.set("v", "<leader>y", osc52.copy_visual, { desc = "Copy selection (OSC52)" })
  end,
}
