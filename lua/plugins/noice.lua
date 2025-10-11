return {
    "folke/noice.nvim",
    opts = {
        lsp = {
        progress = {
            enabled = false, -- disable LSP progress to avoid the Roslyn token crash
        },
        },
    },
}