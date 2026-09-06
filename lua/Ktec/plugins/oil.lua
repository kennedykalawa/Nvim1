return {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local oil = require("oil")

        oil.setup({
            default_file_explorer = true,
            columns = { "icon", "size" },
            keymaps = {
                ["<C-h>"] = false,
                ["<C-c>"] = false,
                ["<CR>"]  = "actions.select",
                ["q"]     = "actions.close",
                ["<C-p>"] = "actions.preview",
            },
            delete_to_trash = true,
            view_options = {
                show_hidden = true,
            },
            skip_confirm_for_simple_edits = true,
            float = {
                padding = 2,
                border  = "rounded",
            },
        })

        vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
        vim.keymap.set("n", "<leader>-", function()
            oil.toggle_float()
        end, { desc = "Oil float" })

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "oil",
            callback = function() vim.opt_local.cursorline = true end,
        })
    end,
}
