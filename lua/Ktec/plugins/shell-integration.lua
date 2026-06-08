-- ─────────────────────────────────────────────────────────────────────────────
-- Shell Integration — makes terminal feel like native shell
-- ─────────────────────────────────────────────────────────────────────────────

return {
    {
        "folke/snacks.nvim",
        optional = true,
        init = function()
            vim.api.nvim_create_autocmd("TermOpen", {
                pattern = "*",
                callback = function(ev)
                    local buf = ev.buf
                    
                    vim.api.nvim_chan_send(vim.bo[buf].channel, "clear\n")

                    local win = vim.api.nvim_get_current_win()
                    vim.api.nvim_win_set_option(win, "wrap", true)
                    vim.api.nvim_win_set_option(win, "linebreak", true)
                    vim.api.nvim_win_set_option(win, "breakindent", true)
                    vim.api.nvim_win_set_option(win, "breakindentopt", "shift:2,sbr")
                    vim.api.nvim_win_set_option(win, "showbreak", "> ")
                    vim.api.nvim_win_set_option(win, "scrolloff", 0)
                    vim.api.nvim_win_set_option(win, "sidescrolloff", 0)
                    vim.api.nvim_win_set_option(win, "number", false)
                    vim.api.nvim_win_set_option(win, "relativenumber", false)
                    
                    vim.cmd("startinsert")
                end,
            })
            
            vim.api.nvim_set_keymap("t", "<Esc>", "<C-\\><C-n>", { noremap = true })
            vim.api.nvim_set_keymap("t", "<C-h>", "<C-\\><C-n><C-w>h", { noremap = true })
            vim.api.nvim_set_keymap("t", "<C-j>", "<C-\\><C-n><C-w>j", { noremap = true })
            vim.api.nvim_set_keymap("t", "<C-k>", "<C-\\><C-n><C-w>k", { noremap = true })
            vim.api.nvim_set_keymap("t", "<C-l>", "<C-\\><C-n><C-w>l", { noremap = true })
        end,
    },
}
