-- ─────────────────────────────────────────────────────────────────────────────
-- Terminal Theme Sync — keeps terminal colors in sync with Neovim theme
-- ─────────────────────────────────────────────────────────────────────────────

return {
    {
        "folke/snacks.nvim",
        optional = true,
        init = function()
            vim.api.nvim_create_autocmd("ColorScheme", {
                pattern = "*",
                callback = function()
                    vim.cmd("highlight! SnacksTerminal guibg=NONE gui=NONE")
                    vim.cmd("highlight! SnacksTerminalNormal guibg=NONE")
                    vim.cmd("highlight! SnacksTerminalBorder guibg=NONE")
                    vim.cmd("highlight! SnacksTerminalTitle guibg=NONE")
                    
                    vim.cmd("set pumblend=0")
                    vim.cmd("set winblend=0")
                    
                    local term_bufs = vim.tbl_filter(
                        function(buf)
                            return vim.bo[buf].filetype == "snacks_terminal"
                        end,
                        vim.api.nvim_list_bufs()
                    )
                    
                    for _, buf in ipairs(term_bufs) do
                        local wins = vim.fn.win_findbuf(buf)
                        for _, win in ipairs(wins) do
                            vim.api.nvim_win_set_option(win, "winhighlight", "Normal:Normal,FloatBorder:FloatBorder")
                        end
                    end
                end,
            })
        end,
    },
}
