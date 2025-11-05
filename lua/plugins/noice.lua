return {
    "folke/noice.nvim",
    opts = function(_, opts)
        -- ensure opts.lsp exists
        opts.lsp = opts.lsp or {}
        opts.lsp.progress = vim.tbl_deep_extend("force", opts.lsp.progress or {}, {
            enabled = false, -- disable LSP progress
        })

        table.insert(opts.routes, {
            filter = {
                event = "notify",
                find = "No information available",
            },
            opts = { skip = true },
        })
        -- enable border preset
        opts.presets = opts.presets or {}
        opts.presets.lsp_doc_border = true
    end,
}

