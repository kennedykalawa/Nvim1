return {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        "nvim-tree/nvim-web-devicons",
        -- Theme switcher with persist (this is what telescope is kept for)
        "andrew-george/telescope-themes",
    },
    config = function()
        local telescope = require("telescope")
        local actions   = require("telescope.actions")
        local builtin   = require("telescope.builtin")

        telescope.setup({
            defaults = {
                path_display = { "smart" },
                mappings = {
                    i = {
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                    },
                },
            },
            extensions = {
                themes = {
                    enable_previewer   = true,
                    enable_live_preview = true,
                    persist = {
                        enabled = true,
                        -- Points to current-theme.lua, NOT colorscheme.lua (bug fix)
                        path = vim.fn.stdpath("config") .. "/lua/current-theme.lua",
                    },
                },
            },
        })

        pcall(telescope.load_extension, "fzf")
        telescope.load_extension("themes")

        -- Only keep things Snacks picker can't do
        -- CWORD grep (full <cWORD>)
        vim.keymap.set("n", "<leader>pWs", function()
            builtin.grep_string({ search = vim.fn.expand("<cWORD>") })
        end, { desc = "Grep WORD under cursor" })

        -- Theme switcher (persists to current-theme.lua)
        vim.keymap.set("n", "<leader>uT", "<cmd>Telescope themes<CR>", { desc = "Theme switcher (persist)" })
    end,
}
