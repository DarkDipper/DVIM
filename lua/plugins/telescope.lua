local function filenameFirst(_, path)
	local tail = vim.fs.basename(path)
	local parent = vim.fs.dirname(path)
	if parent == "." then return tail end
	return string.format("%s\t\t%s", tail, parent)
end

return {
   "nvim-telescope/telescope.nvim",
    opts = {
        pickers = {
            git_status = { path_display = filenameFirst, },
            find_files = { path_display = filenameFirst, },
        },
        defaults = {
            layout_strategy = "vertical",
        }
    }
}
