return {
  {
    "pontusk/cmp-sass-variables",
    ft = { "scss", "sass" },
    config = function()
      local cmp = require("cmp")
      cmp.setup.filetype({ "scss", "sass" }, {
        sources = cmp.config.sources({
          {
            name = "sass_variables",
            option = {
              -- Add Bootstrap’s SCSS include path
              include_paths = { "node_modules/bootstrap/scss" },
            },
          },
          { name = "nvim_lsp" },
          { name = "buffer" },
        }),
      })
    end,
  },
}
