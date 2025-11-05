return {
    "neovim/nvim-lspconfig",
    opts = {
        diagnostics = {
            virtual_text = false, -- disable inline diagnostics
            float = {
                border = "rounded",
            },
            -- underline = true,     -- keep underlines
            -- signs = true,         -- keep signs in the gutter
            -- update_in_insert = false,
            -- severity_sort = true,
        },
        servers = {
            html = {}
        }
    },
}
