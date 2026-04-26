return {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("oil").setup({
            default_file_explorer = true,
            columns = { "icon", "size" },
            keymaps = {
                ["<C-h>"] = false,
                ["<C-c>"] = false,
                ["<M-h>"] = "actions.select_split",
                ["q"]     = "actions.close",
                ["<C-p>"] = "actions.preview",
            },
            delete_to_trash = true,
            view_options = {
                show_hidden = true,
                is_hidden_file = function(name, _)
                    return vim.startswith(name, ".")
                end,
            },
            skip_confirm_for_simple_edits = true,
            float = {
                padding = 2,
                border  = "rounded",
            },
        })

        vim.keymap.set("n", "-",        "<CMD>Oil<CR>",              { desc = "Open parent directory" })
        vim.keymap.set("n", "<leader>-", require("oil").toggle_float, { desc = "Oil float" })

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "oil",
            callback = function() vim.opt_local.cursorline = true end,
        })
    end,
}
