return {
    {
        "tpope/vim-fugitive",
        config = function()
            vim.keymap.set("n", "<leader>gg", vim.cmd.Git, { desc = "Fugitive" })

            local group = vim.api.nvim_create_augroup("myFugitive", {})
            vim.api.nvim_create_autocmd("BufWinEnter", {
                group = group,
                pattern = "*",
                callback = function()
                    if vim.bo.ft ~= "fugitive" then return end
                    local bufnr = vim.api.nvim_get_current_buf()
                    local o = { buffer = bufnr, remap = false }
                    -- Use <leader>gP (capital P) for push to avoid conflict with picker <leader>p
                    vim.keymap.set("n", "<leader>gP", function() vim.cmd.Git("push") end, o)
                    vim.keymap.set("n", "<leader>gpl", function() vim.cmd.Git({ "pull", "--rebase" }) end, o)
                    vim.keymap.set("n", "<leader>gt", ":Git push -u origin ", o)
                end,
            })
        end,
    },
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns
                local function map(mode, l, r, desc)
                    vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
                end

                map("n", "]h", gs.next_hunk,     "Next hunk")
                map("n", "[h", gs.prev_hunk,     "Prev hunk")
                map("n", "<leader>ghs", gs.stage_hunk,  "Stage hunk")
                map("n", "<leader>ghr", gs.reset_hunk,  "Reset hunk")
                map("v", "<leader>ghs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage hunk")
                map("v", "<leader>ghr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset hunk")
                map("n", "<leader>ghS", gs.stage_buffer,          "Stage buffer")
                map("n", "<leader>ghR", gs.reset_buffer,          "Reset buffer")
                map("n", "<leader>ghu", gs.undo_stage_hunk,       "Undo stage hunk")
                map("n", "<leader>ghp", gs.preview_hunk,          "Preview hunk")
                map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame line")
                map("n", "<leader>ghB", gs.toggle_current_line_blame, "Toggle blame")
                map("n", "<leader>ghd", gs.diffthis,              "Diff this")
                map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff this ~")
                map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
            end,
        },
    },
}
